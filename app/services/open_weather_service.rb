class OpenWeatherService
    
  def initialize(lat_lng)
    @lat, @lon = lat_lng
    @api_key = Rails.application.credentials.dig(:openweather, :api_key)
    @weather_url =      'https://api.openweathermap.org/data/2.5/weather'
    @forecast_url =     'https://api.openweathermap.org/data/2.5/forecast'
  end

  def fetch_weather
    current_weather = HTTParty.get(@weather_url, query: {
      lat: @lat,
      lon: @lon,
      appid: @api_key,
      units: 'imperial'
    })
    if current_weather.success?
      current_weather
    else
      raise "Error fetching weather data: #{current_weather.code}"
    end
  end

  def fetch_forecast
    forecast_weather = HTTParty.get(@forecast_url, query: {
      lat: @lat,
      lon: @lon,
      appid: @api_key,
      units: 'imperial'
    })
    
    if forecast_weather.success?
      forecast_data = JSON.parse(forecast_weather.body)
      # Group forecast entries by date (YYYY-MM-DD) using dt_txt
      grouped_entries = forecast_data["list"].group_by do |entry|
        Date.parse(entry["dt_txt"])
      end
  
      # For each day, select the entry with the highest high (temp_max)
      # and aggregate the lowest low (temp_min) from all entries of that day.
      daily_forecasts = grouped_entries.map do |_date, entries|
        best_entry = entries.max_by { |entry| entry["main"]["temp_max"] }
        aggregated_low = entries.map { |e| e["main"]["temp_min"] }.min
        best_entry["main"]["temp_min"] = aggregated_low
        best_entry
      end
  
      # Replace the full list with the daily forecasts
      forecast_data["list"] = daily_forecasts
      forecast_data
    else
      raise "Error fetching forecast data: #{forecast_weather.code}"
    end
  end




  def call 
      
  end

  private

end

