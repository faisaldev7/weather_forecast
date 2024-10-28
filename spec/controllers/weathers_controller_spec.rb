require 'rails_helper'

RSpec.describe WeathersController, type: :controller do
  describe 'POST #create' do
    let(:address) { 'Hitech City' }
    let(:zipcode) { 500012 }
    let(:weather_data) { { temperature: '24°C', high: '26°C', low: '22°C', description: 'Sunny' } }

    before do
      allow(WeatherService).to receive(:extract_zipcode).with(address).and_return(zipcode)
    end

    context 'when address is blank' do
      it 'returns an error' do
        post :create, params: { address: '' }
        expect(JSON.parse(response.body)).to include('error' => 'Address must be present')
      end
    end

    context 'when zipcode is not found' do
      it 'returns an error' do
        allow(WeatherService).to receive(:extract_zipcode).and_return(nil)

        post :create, params: { address: address }
        expect(JSON.parse(response.body)).to include('error' => 'Zipcode is not found')
      end
    end

    context 'when weather data is invalid or not found' do
      before do
        allow(WeatherService).to receive(:fetch_weather).with(address).and_return(nil)
      end

      it 'returns an error' do
        post :create, params: { address: address }
        expect(JSON.parse(response.body)).to include('error' => 'Weather is either invalid or not found')
      end
    end
  end
end
