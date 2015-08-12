require_relative '../config/environment'
require 'pry'

class CommandLine
  attr_accessor :location, :food_type, :sort, :counter, :params, :response

  def initialize
    @yelp = YelpApi.new
    @food_type = nil
    @counter = 0
    @offset = 0
    @sort = 0
  end

  def params
    @params ={term: "#{@food_type}", limit: 5, offset: @offset, category_filter: 'restaurants', sort: @sort}
  end

  def run_command
    puts
    puts Rainbow("Welcome to the Yelp CLI!").red.bright
    puts
    puts "This application lets you do a simple Yelp restaurant search from your command line."
    help
    @command=nil
    while @command != 'exit'
      @command = gets.downcase.strip
      if @command == 'search'
        location
        food_type
        sort
        params
        restaurant_list
        help
      elsif @command == "help"
        help
      elsif @command == "exit"
        puts
        puts "Goodbye"
      else
        puts "Please input a valid command."
        help
      end
    end
  end

  def help
    puts
    puts "Input " + Rainbow("'search'").bright.blue + " to seach for restaurants in your area."
    puts "Type " + Rainbow("'exit'").bright.red + " at any time to stop the program"
    puts "or type " + Rainbow("'help'").bright.green + " to view this message again " + Rainbow(":)").bright.magenta
    puts
  end

  def location
    puts
    puts "Enter a location"
    input = gets.strip
    input.downcase == "exit" ? exit : @location = input
  end

  def food_type
    puts
    puts "Enter a food type"
    input = gets.strip
    input.downcase == "exit" ? exit : @food_type = input
  end

  def sort
    puts
    puts "How should we sort your results?"
    puts
    puts "Input 1 to sort by best match, 2 to sort by distance, or 3 to sort by highest rating"
    input = gets.strip
    while input.to_i > 3 || input.to_i < 1
      puts "Please input an integer between 1 and 3"
      input = gets.strip
      if input.downcase == "exit"
        exit
      end
    end
    @sort = input.to_i - 1
  end

  def restaurant_list
      begin
        @response = @yelp.client.search(@location, @params)
        # binding.pry
      rescue Yelp::Error::UnavailableForLocation
        puts "Yelp has no data for that location"
      end
    input = nil
    while input != 'exit' && @offset < @response.total
      if @response
        if @response.businesses.empty?
          puts "No Results found"
        else
          @response.businesses.each.with_index(1) do |business, index|
            # binding.pry
            puts
            puts "\s\s\s\s\s#{index + @offset}. #{business.name}"
            puts "\tRating: #{business.rating}"
            business.location.display_address.each do |line|
              puts "\t#{line}"
            end
            begin
              puts "\t#{business.phone}"
            rescue NoMethodError
              puts "\tno phone number listed"
            end
          end
          puts "Showing #{5 * (counter) + 1} to #{[5 * (counter + 1), @response.total].min} of #{@response.total} Products."
          puts "Type 'next' to view the next page"
          input = gets.strip
          if input == "next"
            @counter += 1
            @offset += 5
            params
            @response = @yelp.client.search(@location, @params)
          end
        end
      end
    end
  end
end
