#encoding: utf-8
#
# Dirty script to export original beer database
#
# Usage:
#
# 1. download zipballs with SQL scripts from http://openbeerdb.com/
#
#   http://openbeerdb.com/data_files/beers.zip
#   http://openbeerdb.com/data_files/breweries.zip
#   http://openbeerdb.com/data_files/cat_styles.zip
#   http://openbeerdb.com/data_files/geocodes.zip
#
# 2. unzip them all
# 3. ensure that both mysql client and server uses latin1 encoding,
#    (default-character-set=latin1 in appropriate places)
# 4. create database named 'beer' (in case of different name script below
#    need to be changed)
# 5. source all files into the database
# 6. run the script: ruby export.rb
# 7. the script will create directory out with all the stuff

require 'active_record'
require 'yajl'
require './uuid.rb'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => 'localhost',
  :username => 'root',
  :database => 'beer',
  :encoding => 'latin1'
)

class Category < ActiveRecord::Base
end

class Style < ActiveRecord::Base
end

class Beer < ActiveRecord::Base
  belongs_to :category, :foreign_key => 'cat_id'
  belongs_to :style, :foreign_key => 'style_id'
end

class Geocode < ActiveRecord::Base
  self.table_name = :breweries_geocode
end

class Brewery < ActiveRecord::Base
  has_many :geocodes, :foreign_key => 'brewery_id'
end

uuid = UUID.generator
mapping = {}

require 'fileutils'
FileUtils.mkdir_p("out/beers")
FileUtils.mkdir_p("out/breweries")

skipped = 0

Brewery.includes(:geocodes).each do |item|
  doc = item.attributes.dup
  doc["type"] = "brewery"
  doc.delete("id")
  doc.delete("filepath")
  doc.delete("add_user")
  doc["updated"] = doc.delete("last_mod").strftime("%Y-%m-%d %H:%M:%S")
  doc["description"] = doc.delete("descript")
  doc["address"] = [doc.delete("address1"), doc.delete("address2")].reject(&:blank?)
  item.geocodes.each do |geo|
    doc["geo"] = geo.attributes
    break if geo.accuracy == "ROOFTOP"
  end
  if doc["geo"]
    doc["geo"].delete("id")
    doc["geo"].delete("brewery_id")
    doc["geo"]["lat"] = doc["geo"].delete("latitude")
    doc["geo"]["lng"] = doc["geo"].delete("longitude")
  end
  id = uuid.next[22..-1]
  mapping[item.id] = id
  File.open("out/breweries/#{id}.json", "w") do |f|
    f.write(Yajl::Encoder.encode(doc))
  end
end

Beer.includes([:style, :category]).each do |item|
  doc = item.attributes.dup
  doc["type"] = "beer"
  doc.delete("id")
  doc["brewery_id"] = mapping[doc.delete("brewery_id")]
  doc.delete("cat_id")
  doc.delete("style_id")
  doc.delete("filepath")
  doc.delete("add_user")
  doc["updated"] = doc.delete("last_mod").strftime("%Y-%m-%d %H:%M:%S")
  doc["description"] = doc.delete("descript")
  doc["style"] = item.style.style_name if item.style
  doc["category"] = item.category.cat_name if item.category
  id = uuid.next[22..-1]
  File.open("out/beers/#{id}.json", "w") do |f|
    f.write(Yajl::Encoder.encode(doc))
  end
end
