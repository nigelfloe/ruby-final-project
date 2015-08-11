require_relative '../config/environment'
require 'pry'

class CommandLine
  attr_accessor :location, :food_type, :sort
  attr_reader :params

  def initialize
    @yelp = YelpApi.new
  end

  def run_command
    width = 40
    puts "Welcome to the Yelp CommandLine!".ljust(width)
    puts
    puts "This application lets you do a simple Yelp restaurant search from your command line.".ljust(width)
    help
    command=nil
    while command != 'exit'
      command = gets.downcase.strip
      if command == 'search'
        location
        food_type
        sort
        params
        restaurant_list
        help
      elsif command == "help"
        help
      elsif command == "exit"
        puts "Goodbye"
      end
    end
  end

  def help
    puts "Input 'search' to seach for restaurants in your area.\n
          Type 'exit' at any time to stop the program\n
          or type 'help' to view this message again :)\n"
  end

  def location
    puts "Enter a location\n"
    @location = gets.strip
  end

  def food_type
    puts "Enter a food type\n"
    @food_type = gets.strip
  end

  def sort
    puts "How should we sort your results?"
    puts "Input 0 to sort by best match, 1 to sort by distance, or 2 to sort by highest rating"
    @sort = gets.strip.to_i
  end

  def params
    @params ={term: "#{@food_type}", limit: 5, category_filter: 'restaurants', sort: @sort}
  end

  def restaurant_list
    begin
      response = @yelp.client.search(@location, @params)
    rescue Yelp::Error::UnavailableForLocation
      puts "Yelp has no data for that location"
    end
    if response
      response.businesses.each do |business|
        puts business.name
        puts "Rating: #{business.rating}"
        business.location.display_address.each do |line|
          puts line
        end
        begin
          puts "#{business.phone}\n\n"
        rescue NoMethodError
          puts "no phone number listed\n\n"
        end
      end
    end
  end
end
