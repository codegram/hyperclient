require 'hyperclient'

api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api')

api.splines.each do |spline|
  puts "#{spline.uuid}"
  puts " reticulated: #{spline.reticulated ? 'yes' : 'no'}"
  puts " thumbnail: #{spline['images:thumbnail']}"
end

api._links.splines._embedded.splines.each do |_spline|
  # ... equivalent to the above
end

puts '*' * 10

spline = api.spline(uuid: 'random-uuid')
puts "Spline #{spline.uuid} is #{spline.reticulated ? 'reticulated' : 'not reticulated'}."

# puts api._links.spline._expand(uuid: 'uuid')._resource._attributes.reticulated

# spline.to_h
