# encoding: utf-8

require 'couchbase'
require 'yajl'

conn = Couchbase.connect(:bucket => "beer-sample")
datadir = File.expand_path("#{File.dirname(__FILE__)}/..")
Dir["#{datadir}/{beers,breweries}/*.json"].each do |file|
  id = file[%r{/([^/]*)\.json$}, 1]
  conn.set(id, Yajl::Parser.parse(File.read(file)))
end
conn.save_design_doc(File.read("#{datadir}/design_docs/beer.json"))
