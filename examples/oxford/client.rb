require 'hyperclient'

api = Hyperclient.new(ENV.fetch('OXFORD_URL', 'http://127.0.0.1:9292/'))
api.places.each do |place|
  puts "#{place.name}: #{place.address}"
end

place = api.place(id: 'oxpoints:23232339')
puts "Followed primary_place: #{place.primary_place.name}"
place._embedded.files.each do |file|
  puts "Archived #{file.type} URL (not fetched): #{file.url}"
end
puts "CURIE: #{api._links._curies['oxford'].expand('places')}"
