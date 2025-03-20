require "test_helper"

# A dummy result class to simulate a Geocoder result.
class DummyGeocoderResult
  def initialize(data)
    @data = data
  end

  def empty?
    false
  end

  def first
    self
  end

  def latitude
    # Convert string to float for consistency
    @data["lat"].to_f
  end

  def longitude
    @data["lon"].to_f
  end

  def data
    @data
  end
end

class LocationIqTest < ActiveSupport::TestCase
  test "geocode returns latitude, longitude, and zip code" do
    address = "10687 W Cooper Dr."
    # Dummy data simulating a successful geocode response.
    dummy_data = {
      "place_id"    => "123",
      "lat"         => "39.0",
      "lon"         => "-105.0",
      "address"     => { "postcode" => "80127" }
    }
    dummy_result = DummyGeocoderResult.new(dummy_data)

    # Stub Geocoder.search to return an array with our dummy result.
    Geocoder.stub :search, [dummy_result] do
      location_iq = LocationIq.new
      result = location_iq.geocode(address)
      # Expected result is an array: [latitude, longitude, zip]
      assert_equal [39.0, -105.0, "80127"], result
    end
  end

  test "geocode raises an error when no result is found" do
    address = "Unknown Address"
    # Stub Geocoder.search to return an empty array.
    Geocoder.stub :search, [] do
      location_iq = LocationIq.new
      assert_raises(RuntimeError, "No geocode data found for address: #{address}") do
        location_iq.geocode(address)
      end
    end
  end
end