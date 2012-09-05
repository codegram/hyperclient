require 'hyperclient'

def print_resources(resources)
  resources.each do |name, resource|
    begin
    # if resource.is_a?(Array)
    #   print_resources(resource)
    # else
      puts %{Found #{name} at #{resource.url}}
    # end
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

api = Hyperclient::EntryPoint.new 'http://hal-shop.heroku.com', {debug: true}

puts "Let's inspect the API:"
puts "\n"

puts 'Links from the entry point:'

print_resources(api.links)

puts
puts 'Resources at the entry point:'
print_resources(api.embedded)

puts
puts "Let's see what stats we have:"
print_attributes(api.embedded.stats.attributes)

products = api.links["http://hal-shop.heroku.com/rels/products"].resource

puts 
puts "And what's the inventory of products?"
puts products.attributes['inventory_size']

puts 
puts 'What resources does products have?'
print_resources(products.embedded.products)

puts
puts 'And links?'
print_resources(products.links)

puts
puts 'Attributes of the first product?'
print_attributes(products.embedded.products.first.attributes)
