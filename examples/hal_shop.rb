require 'hyperclient'
require 'pp'

def print_resources(resources)
  resources.each do |name, resource|
    begin
      puts %{Found #{name} at #{resource.url}}
    rescue
      puts %{Found #{name}}
    end
  end
end

def print_attributes(attributes)
  puts "-----------------------------"
  attributes.each do |attribute, value|
    puts %{#{attribute}: #{value}}
  end
end

api = Hyperclient::EntryPoint.new 'http://hal-shop.heroku.com'

puts "Let's inspect the API:"
puts "\n"

puts 'Links from the entry point:'

print_resources(api.links)

puts
puts "Let's see what stats we have:"
print_attributes(api.embedded.stats.attributes)

products = api.links["http://hal-shop.heroku.com/rels/products"].resource

puts 
puts "And what's the inventory of products?"
puts products.attributes['inventory_size']

puts
puts 'What embedded resources does products have?'
products.embedded.products.each do |product|
  puts 'Product:'
  print_attributes(product.attributes)
  puts
end

puts 'And links?'
print_resources(products.links)

puts
puts 'Attributes of the first product?'
print_attributes(products.embedded.products.first.attributes)
