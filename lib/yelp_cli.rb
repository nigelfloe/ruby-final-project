require_relative '../config/environment'
require 'pry'

class CommandLine
  attr_accessor :location, :term, :sort, :counter, :params, :response

  def initialize
    @yelp = YelpApi.new
    @term = nil
    @counter = 0
    @offset = 0
    @sort = 0
  end

  def run_command
    puts
    puts Rainbow("Welcome to the Yelp CLI!").red.bright
    puts
    puts "This application lets you do a simple Yelp search from your command line."
    help
    @command=nil
    while @command != 'exit'
      @command = gets.downcase.strip
      if @command == 'search'
        location
        term
        sort
        result_list
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
    puts "Input " + Rainbow("'search'").bright.blue + " to seach for businesses in your area."
    puts "Type " + Rainbow("'exit'").bright.red + " at any time to stop the program"
    puts "or type " + Rainbow("'help'").bright.green + " to view this message again " + Rainbow(":)").bright.magenta
    puts
  end

  def location
    puts
    puts "Where are you? (Zip code or address is best!)"
    input = gets.strip
    input.downcase == "exit" ? exit : @location = input
  end

  def term
    puts
    puts "What are you trying to find? (i.e.: 'restaurants', 'plumber', etc.)"
    input = gets.strip
    input.downcase == "exit" ? exit : @term = input
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

  def set_params(offset)
    @params ={term: "#{@term}", limit: 5, offset: offset, sort: @sort}
  end

  def yelp_search
    begin
      response = @yelp.client.search(@location, @params)
    rescue Yelp::Error::UnavailableForLocation
      puts "Yelp has no data for that location"
    end
    if response== nil || response.total ==0
      puts "No Results Found"
    else
      response
    end
  end

  def result_list
    set_params(0)
    response = yelp_search
    input = nil
    counter = 0
    offset = 0
    if response
      while input != 'exit' && offset < response.total
        response.businesses.each.with_index(1) do |business, index|
          puts
          puts "\s\s\s\s\s#{index + offset}. #{business.name}"
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
        puts
        puts "Showing #{5 * (counter) + 1} to #{[5 * (counter + 1), response.total].min} of #{response.total} Products."
        puts "Type 'next' to view the next page or 'exit' to return to the main menu"
        input = gets.strip
        if input == "next"
          counter += 1
          offset = counter * 5
          set_params(offset)
          response = yelp_search
        end
      end
    end
  end
end
