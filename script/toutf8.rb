datadir = File.expand_path("#{File.dirname(__FILE__)}/..")
Dir["#{datadir}/{beers,breweries}/*.json"].each do |file|
  if `file #{file}` =~ /ISO-8859/
    system("iconv -f ISO-8859-1 -t UTF-8 #{file} > #{file}.utf8")
    system("mv #{file}.utf8 #{file}")
  end
end
