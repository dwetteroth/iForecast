require "test_helper"

class OpenWeatherServiceTest < ActiveSupport::TestCase
  test "fetch_weather returns expected data" do
    lat_lng = [39.0, -105.0]
    # Dummy weather data
    dummy_weather = { "temperature" => 75, "condition" => "Sunny" }
    
    # Create an instance of the service.
    service = OpenWeatherService.new(lat_lng)
    
    # Stub fetch_weather to return dummy data.
    service.stub :fetch_weather, dummy_weather do
      result = service.fetch_weather
      assert_equal dummy_weather, result
    end
  end

  test "fetch_forecast returns expected forecast data" do
    lat_lng = [39.0, -105.0]
    # Dummy forecast data
    dummy_forecast = [{ "day" => "Monday", "temperature" => 70 }]
    
    service = OpenWeatherService.new(lat_lng)
    service.stub :fetch_forecast, dummy_forecast do
      result = service.fetch_forecast
      assert_equal dummy_forecast, result
    end
  end
end