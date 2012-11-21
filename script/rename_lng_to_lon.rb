#encoding: utf-8

require 'rubygems'
require 'yajl'

datadir = File.expand_path("#{File.dirname(__FILE__)}/..")
Dir["#{datadir}/docs/*.json"].each do |file|
  item = Yajl::Parser.parse(File.read(file))
  if item["geo"]
    item["geo"]["lon"] = item["geo"].delete("lng")
    File.open(file, "w") do |out|
      out.write(Yajl::Encoder.encode(item))
    end
  end
end
