#encoding: utf-8

require 'rubygems'
require 'yajl'
require 'active_support/all' # for String#parameterize

# make id in form "prefix.lowercased_name"
#
# Example:
#  fixup("Borsodi Sörgyár")
#  => borsodi_sorgyar
#
def fixup(*names)
  # 1) replace accented chars with their ascii equivalents and apply Unicode
  #    normalizarion
  # 2) turn unwanted chars into the separator (non alphanumeric, _ and -
  names.map{|name| name.parameterize.gsub("-", "_")}.join("-")
end

mapping = {}
datadir = File.expand_path("#{File.dirname(__FILE__)}/..")
File.open("brewery-rename.log", "w") do |log|
  Dir["#{datadir}/breweries/*.json"].each do |file|
    id = file[%r{/([^/]*)\.json$}, 1]
    item = Yajl::Parser.parse(File.read(file))
    mapping[id] = new_id = fixup(item["name"])

    log.puts "#{id} => #{new_id} (#{item["name"]})"
    File.open("#{datadir}/breweries/#{new_id}.json", "w") do |out|
      out.write(Yajl::Encoder.encode(item))
    end
    File.unlink(file)
  end
end

File.open("beer-rename.log", "w") do |log|
  Dir["#{datadir}/beers/*.json"].each do |file|
    id = file[%r{/([^/]*)\.json$}, 1]
    item = Yajl::Parser.parse(File.read(file))
    item["brewery_id"] = mapping[item["brewery_id"]]
    new_id = fixup(item["brewery_id"], item["name"])

    log.puts "#{id} => #{new_id} (#{item["name"]})"
    File.open("#{datadir}/beers/#{new_id}.json", "w") do |out|
      out.write(Yajl::Encoder.encode(item))
    end
    File.unlink(file)
  end
end
