require_relative '../config/environment'

# require 'pry'
# require 'yaml'


class YelpApi
  attr_reader :client

  def initialize
    keys = YAML.load_file('keys.yml')
    # binding.pry

    @client = Yelp::Client.new({ consumer_key: keys['CONSUMER_KEY'],
                            consumer_secret: keys['CONSUMER_SECRET'],
                            token: keys['TOKEN'],
                            token_secret: keys['TOKEN_SECRET']
                          })
  end
end
