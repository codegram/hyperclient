require 'hyperclient'

class Cyberscore
  include Hyperclient

  entry_point 'http://cs-api.heroku.com/api/'

  def news
    links.feeds.links.submissions.embedded.news
  end

  def submissions
    links.feeds.links.submissions.embedded.submissions
  end

  def games
    links.feeds.links.games.embedded.games
  end

  def add_game(name)
    links.feeds.links.submissions.post({name: name})
  end

  def motd
    attributes['motd']
  end
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

def print_games(games)
  games.each do |game|
    puts %{Found "#{game.attributes['name']}" at "#{game.url}" }
  end
end


api = Cyberscore.new

puts "Let's inspect the API:"
puts "\n"

puts 'Links from the entry point:'
print_resources(api.links)
puts "\n"

puts 'How is the server feeling today?'
puts api.motd
puts "\n"

puts "Let's read the feeds:"
print_resources(api.links.feeds.links)
puts "\n"

puts "I like games!"
print_games(api.games)
