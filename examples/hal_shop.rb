require 'hyperclient'

class HalShop
  include Hyperclient

  entry_point 'http://hal-shop.heroku.com'
end

def print_resources(resources)
  resources.each do |resource|
    if resource.is_a?(Array)
      print_resources(resource)
    else
      puts %{Found "#{resource.name}" at "#{resource.url}" }
    end
  end
end

def print_attributes(attributes)
  puts "-----------------------------"
  attributes.each do |attribute, value|
    puts %{#{attribute}: #{value}}
  end
end

api = HalShop.new

puts "Let's inspect the API:"
puts "\n"

puts 'Links from the entry point:'

print_resources(api.links)

puts
puts 'Resources at the entry point:'
print_resources(api.resources)

puts
puts "Let's see what stats we have:"
print_attributes(api.resources.stats.attributes)

products = api.links.send("http://hal-shop.heroku.com/rels/products").reload

puts 
puts "And what's the inventory of products?"
puts products.attributes['inventory_size']

puts 
puts 'What resources does products have?'
print_resources(products.resources.products)

puts
puts 'And links?'
print_resources(products.links)

puts
puts 'Attributes of the first product?'
print_attributes(products.resources.products.first.attributes)

p products.products
