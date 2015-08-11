require 'pry'
class CommandLine
  attr_accessor :location, :food_type
  attr_reader :args
  # def initialize
  #   @location=""
  #   @food_type""
  # end

  def run_command
    puts "Welcome to the Yelp CommandLine"
    location_command
    food_type_command
    create_search_args
  end

  def location_command
    puts "Enter a location"
    @location=gets.chomp.downcase.to_s
  end

  def food_type_command
    puts "Enter a food type"
    @food_type=gets.chomp.downcase.to_s
  end

  def create_search_args
    @args = "'#{@location}', {term: 'restaurant', limit: 5, category_filter: '#{@food_type}'}"
    binding.pry
  end
end

# david=CommandLine.new
# david.run_command
