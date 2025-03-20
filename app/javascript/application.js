// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"




$(function() {
  function getWindDirection(deg) {
    const directions = [
      "N","NNE","NE","ENE","E","ESE","SE","SSE",
      "S","SSW","SW","WSW","W","WNW","NW","NNW"
    ];
    const index = Math.round(deg / 22.5) % 16;
    return directions[index];
  }

  

  function updateCurrentWeather(data) {
    const cw = data.current_weather;



    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true
    });
    // e.g., "Mar 19, 8:43 PM"

    
    const city = cw.name || 'Unknown';
    const country = cw.sys?.country || 'Unknown';

    const tempF = Math.round(cw.main.temp);
    const feelsLikeF = Math.round(cw.main.feels_like);
    
    const rawDesc = cw.weather[0].description || '';
    const shortText = rawDesc.charAt(0).toUpperCase() + rawDesc.slice(1);
    
    const windSpeed = cw.wind?.speed?.toFixed(1) || '0.0';
    const windDir = cw.wind?.deg !== undefined ? getWindDirection(cw.wind.deg) : '';
    
    const pressure = cw.main?.pressure || '—';
    const humidity = cw.main?.humidity || '—';
    const visibilityKm = cw.visibility ? (cw.visibility / 1000).toFixed(1) : '—';


    const icon = cw.weather?.[0]?.icon || '01d';
    const iconUrl = `http://openweathermap.org/img/wn/${icon}@2x.png`;

    const windGust = cw.wind?.gust?.toFixed(1) || '—';
    const cachedLabel = data.cached ? "<span class='badge ml-2 cached'>Cached</span>" : "";


    const currentHtml = `
      <div class="current-weather-card">
        
        <div class="d-flex justify-content-between  mb-3">
          <h2 class="mb-4">Current Weather for ${city}, ${country} ${cachedLabel}</h2> 
          <span>${timeString}</span>

        </div>
        
        <div class="row">
          <!-- Left side: icon, big temp, RealFeel, description, "MORE DETAILS" -->
          <div class="col-md-12 d-flex align-items-center">
            <img src="${iconUrl}" alt="Weather Icon" style="width:60px; height:auto; margin-right:15px;">
            <div>
              <div class="display-4 mb-0">${tempF}°F</div>
              <div>RealFeel ${feelsLikeF}°</div>
              <div class="text-capitalize">${shortText}</div>
              <div>Wind: ${windDir} ${windSpeed} mph</div>
              <div>Wind Gusts: ${windGust} mph</div>
              
            </div>
          </div>
          
        
        </div>
      </div>
    `;
    
    $('#current-weather').html(currentHtml);
  }
  function displayWeather(data) {
    // --- Current Weather ---
    updateCurrentWeather(data);
    
    // --- Forecast ---
    let forecastHtml = `
                      <div class="d-flex justify-content-between  mb-3">
                        <h2 class="mt-4">Forecast</h2>
                      </div>
                      `;
    
    $.each(data.forecast.list, function(i, entry) {
      const iconUrl = `http://openweathermap.org/img/wn/${entry.weather[0].icon}@2x.png`;
      
      const forecastDateObj = new Date();
      forecastDateObj.setDate(forecastDateObj.getDate() + i + 1);

      const weekday = forecastDateObj.toLocaleDateString('en-US', { weekday: 'short' });
      const month = forecastDateObj.getMonth() + 1;
      const day = forecastDateObj.getDate();
    
      
      
      const precipChance = entry.main.humidity + '%'; 
      
      // Extract the raw description
      const rawDescription = entry.weather[0].description;

      // Capitalize the first letter, then combine with the rest of the string
      const shortText = rawDescription.charAt(0).toUpperCase() + rawDescription.slice(1);
      
      // RealFeel often requires a different API field, but here we'll just use feels_like:
      const realFeel = Math.round(entry.main.feels_like);
    
  
  
      const wind = entry.wind.speed + ' mph';
      
      // Build a single forecast row


      forecastHtml += `
        <div class="row align-items-center py-2 border-bottom">
          
          <div class="col-md-3 text-center">
            <div class="text-uppercase font-weight-bold forecast-date-text">
              ${weekday} ${month}/${day}
            </div>
            <img src="${iconUrl}" alt="Weather Icon" class="my-1">
            <div class="h5 mb-1">
              <span class="forecast-main-temp">${Math.round(entry.main.temp_max)}°</span> / ${Math.round(entry.main.temp_min)}°
            </div>
            
          </div>
          
          <!-- Right column: Description, RealFeels, etc. -->
          <div class="col-md-9">
            <div class="mb-2">${shortText}</div>
            <div>RealFeel: ${realFeel}°</div>
            <div>Humidity: ${precipChance}</div>
            <div>Wind: ${wind}</div>
          </div>
        </div>
      `;
    });
    
    $('#forecast').html(forecastHtml);
  }
  
  // Event handler for the search button
  $('#search-btn').on('click', function() {
    const address = $.trim($('#address').val());
    if (!address) {
      alert('Please enter an address.');
      return;
    }
    
    $.ajax({
      url: '/weather/search',
      method: 'GET',  // or 'POST' if your endpoint requires it
      dataType: 'json',
      data: { address },
      success: displayWeather,
      error: function(err) {
        console.error("Error fetching weather data:", err);
      }
    });
  });
});