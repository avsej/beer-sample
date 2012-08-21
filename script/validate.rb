#encoding: utf-8

require 'yajl'

mapping = {}
datadir = File.expand_path("#{File.dirname(__FILE__)}/..")

Dir["#{datadir}/breweries/*.json"].each do |file|
  id = file[%r{/([^/]*)\.json$}, 1]
  mapping[id] = File.read(file)
end

missing = []
Dir["#{datadir}/beers/*.json"].each do |file|
  id = file[%r{/([^/]*)\.json$}, 1]
  beer = Yajl::Parser.parse(File.read(file))
  unless mapping[beer["brewery_id"]]
    missing << beer["brewery_id"]
  end
end

puts missing.uniq
puts missing.count
