class Parser
  attr_reader :response

  def initialize(yelp_api_response)
    @response = yelp_api_response
  end

  def restaurant_list
    response.businesses.each do |business|
      puts business.name
      puts "Rating: #{business.rating}"
      business.location.display_address.each do |line|
        puts line
      end
      puts "#{business.display_phone}\n\n"
    end
  end


end
