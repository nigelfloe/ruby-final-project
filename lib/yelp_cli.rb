require_relative '../config/environment'

class CommandLine
  def initialize
    @params = {limit: 5}
  end

  def run_command
    puts
    puts Rainbow("Welcome to the Yelp CLI!").red.bright
    puts
    puts "This application lets you do a simple Yelp search from your command line."
    help
    command = nil
    while command != 'exit'
      command = gets.downcase.strip
      if command == 'search'
        location
        term
        sort
        result_list
        help
      elsif command == "help"
        help
      elsif command == "exit"
        exit_cli
      else
        puts
        puts Rainbow("Please input a valid command.").bright
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

  def exit_cli
    puts
    puts Rainbow("Goodbye!").bright.green
    puts
    exit
  end

  def input
    input = gets.strip
    exit_cli if input.downcase == "exit"
    input
  end

  def location
    puts
    puts "Where are you? (Zip code or address is best!)"
    @location = input
  end

  def term
    puts
    puts "What are you trying to find? (i.e.: 'restaurants', 'plumber', etc.)"
    @params[:term] = input
  end

  def sort
    puts
    puts "How should we sort your results?"
    puts
    puts "Input 1 to sort by best match, 2 to sort by distance, or 3 to sort by highest rating"
    sort = input
    while sort.to_i > 3 || sort.to_i < 1
      puts "Please input an integer between 1 and 3"
      sort = input
    end
    @params[:sort] = sort.to_i - 1
  end

  def yelp_search
    begin
      response = YelpApi.new.client.search(@location, @params)
    rescue Yelp::Error::UnavailableForLocation
      puts
      puts Rainbow("Yelp has no data for that location").bright
    end
    if response== nil || response.total ==0
      puts
      puts Rainbow("No Results Found").bright
    else
      response
    end
  end

  def result_list
    @params[:offset] = 0
    response = yelp_search
    if response
      input = nil
      counter = 0
      offset = 0
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
        puts "Showing " +  Rainbow("#{5 * (counter) + 1}").bright + " to " + Rainbow("#{[5 * (counter + 1), response.total].min}").bright + " of " + Rainbow("#{response.total}") + " Products."
        puts "Type " + Rainbow("'next'").bright.blue + " to view the next page or " + Rainbow("'exit'").bright.red + " to return to the main menu"
        input = gets.strip
        if input == "next"
          counter += 1
          offset = counter * 5
          @params[:offset] = offset
          response = yelp_search
        end
      end
    end
  end
end
