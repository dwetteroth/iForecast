require "test_helper"
require "minitest/mock"

# A dummy service to simulate weather API responses.
class DummyWeatherService
  def fetch_weather
    { "temperature" => 75, "condition" => "Sunny" }
  end

  def fetch_forecast
    [{ "day" => "Monday", "temperature" => 70 }]
  end
end

class WeatherControllerTest < ActionDispatch::IntegrationTest
  # Disable fixture loading if you don’t need them. Otherwise, update/remove the addresses fixture.
  # self.fixture_path = "#{Rails.root}/test/empty_fixtures"

  setup do
    Rails.cache.clear
  end

  test "should get index" do
    # Request with JSON format to avoid 406 Not Acceptable
    get weather_index_url, as: :json
    assert_response :success
  end

  test "search returns weather data with cache flag false on first call" do
    address = "10687 W Cooper Dr."

    # Create a mock for the LocationIq instance.
    location_iq_mock = Minitest::Mock.new
    # Expect geocode to be called with the given address and return a fixed array.
    location_iq_mock.expect(:geocode, [39.0, -105.0, "80127"], [address])

    # Stub LocationIq.new to return our mock.
    LocationIq.stub(:new, location_iq_mock) do
      # Stub OpenWeatherService.new so that any call returns our DummyWeatherService instance.
      OpenWeatherService.stub(:new, DummyWeatherService.new) do
        get search_weather_url, params: { address: address }, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal false, json_response["cached"], "Expected cached flag to be false on first call"

        # Verify that the location_iq_mock expectations were met.
        location_iq_mock.verify
      end
    end
  end

  test "search returns weather data with cache flag true on subsequent call" do
    address = "10687 W Cooper Dr."

    # Create a mock for LocationIq that will be used on the first call.
    location_iq_mock = Minitest::Mock.new
    location_iq_mock.expect(:geocode, [39.0, -105.0, "80127"], [address])

    # First call: stub LocationIq.new and OpenWeatherService.new.
    LocationIq.stub(:new, location_iq_mock) do
      OpenWeatherService.stub(:new, DummyWeatherService.new) do
        get search_weather_url, params: { address: address }, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal false, json_response["cached"], "Expected cached flag to be false on first call"
      end
    end

    # For the second call, the data should be cached so LocationIq and OpenWeatherService shouldn't be invoked.
    # No need to stub them again because the cache is already populated.
    get search_weather_url, params: { address: address }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal true, json_response["cached"], "Expected cached flag to be true on subsequent call"
  end
end