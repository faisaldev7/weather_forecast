class WeatherService
  class << self
    def fetch_weather(address)
      location = WeatherData::DATA.find { |entry| entry[:address].casecmp?(address) }
      return nil unless location

      {
        temperature: location[:temperature],
        high: location[:high],
        low: location[:low],
        description: location[:description],
        zipcode: location[:zipcode]
      }
    end

    def extract_zipcode(address)
      location = WeatherData::DATA.find { |entry| entry[:address].casecmp?(address) }
      location ? location[:zipcode] : nil
    end
  end
end
