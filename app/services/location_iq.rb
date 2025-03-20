class LocationIq

  def initialize()
    @api_key = Rails.application.credentials.dig(:locationiq, :api_key)
  end

  def geocode(address)
    result = Geocoder.search(address)

    if result.empty?
      raise "No geocode data found for address: #{address}"
    else
      lat = result.first.latitude
      lon = result.first.longitude
      # Extract the ZIP code from the structured API response.
      zip = result.first.data.dig("address", "postcode")
      [lat, lon, zip]
      
    end
  end

end