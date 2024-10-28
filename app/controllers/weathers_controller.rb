class WeathersController < ApplicationController
  before_action :address_presence, only: [:create]

  def new
    @weather = nil
  end

  def create
    address = weather_params[:address]
    zipcode = WeatherService.extract_zipcode(address)

    return render json: { error: 'Zipcode is not found' }, status: 422 if zipcode.blank?

    weather_result = cached_weather(address, zipcode)

    if weather_result[:weather]
      @weather = weather_result[:weather]
      @cached = weather_result[:cached]
    else
      render json: { error: 'Weather is either invalid or not found' }, status: 422
    end
  end

  private

  def weather_params
    params.permit(:address)
  end

  def cached_weather(address, zipcode)
    if Rails.cache.exist?("weather_#{zipcode}")
      { weather: Rails.cache.read("weather_#{zipcode}"), cached: true }
    else
      weather = WeatherService.fetch_weather(address)
      Rails.cache.write("weather_#{zipcode}", weather, expires_in: 30.minutes)
      { weather: weather, cached: false }
    end
  end

  def address_presence
    render json: { error: 'Address must be present' }, status: 422 if weather_params[:address].blank?
  end
end
