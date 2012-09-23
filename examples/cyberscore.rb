require 'hyperclient'

class Cyberscore
  include Hyperclient

  def news
    client.links.submissions.embedded.news
  end

  def submissions
    client.links..submissions.embedded.submissions
  end

  def games
    client.links.games.embedded.games
  end

  def add_game(name)
    client.links.submissions.post({name: name})
  end

  def motd
    client.attributes.motd
  end

  def method_missing(method, *args, &block)
    if client.respond_to?(method)
      client.send(method, *args, &block)
    else
      super
    end
  end

  private
  def client
    @client ||= Hyperclient::EntryPoint.new 'http://cs-api.heroku.com/api', 
                {debug: false, headers: {'content-type' => 'application/json'}}
  end
end

def print_links(links)
  links.each do |name, link|
    if link.is_a?(Array)
      print_links(link)
    else
      puts %{Found "#{name}" at "#{link.url}" }
    end
  end
end

def print_games(games)
  games.each do |game|
    puts %{Found "#{game.attributes['name']}" }
  end
end


api = Cyberscore.new

puts "Let's inspect the API:"
puts "\n"

puts 'Links from the entry point:'
print_links(api.links)
puts "\n"

puts 'How is the server feeling today?'
puts api.motd
puts "\n"

puts "Let's read the news:"
print_links(api.links.news.links)
puts "\n"

puts "I like games!"
print_games(api.games)
