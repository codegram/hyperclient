require 'hyperclient'

puts "Using Hyperclient #{Hyperclient::VERSION} ..."

# create a new client
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api')

# enumerate splines
api.splines.each do |spline|
  puts spline.uuid.to_s
  puts " reticulated: #{spline.reticulated ? 'yes' : 'no'}"
  puts " thumbnail: #{spline['images:thumbnail']}"
end

api._links.splines._embedded.splines.each do |_spline|
  # ... equivalent to the above
end

puts '*' * 10

# retrieve an existing spline
spline = api.spline(uuid: 123)
puts "Spline #{spline.uuid} is #{spline.reticulated ? 'reticulated' : 'not reticulated'}."

# puts api._links.spline._expand(uuid: 'uuid')._resource._attributes.reticulated

# spline.to_h

# create a new spline
spline = api.splines._post(spline: { reticulated: true })
puts "Created a #{spline.reticulated ? 'reticulated' : 'unreticulated'} spline #{spline.uuid}."

# update an existing spline
spline = api.spline(uuid: 123)._put(spline: { reticulated: true })
puts "Updated spline #{spline.uuid}, now #{spline.reticulated ? 'reticulated' : 'not reticulated'}."

# delete an existing spline
spline = api.spline(uuid: 123)._delete
puts "Deleted spline #{spline.uuid}."
