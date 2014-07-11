require 'spec_helper'

describe 'GET /v1/events/nearests?lat=&lon=&radius=' do
  it 'returns the events closest to the lat and lon' do
    near_event = create(:event, lat: 37.760322, lon: -122.429667)
    less_near_event = create(:event, lat: 37.760321, lon: -122.429667)
    create(:event, lat: 37.687737, lon: -122.470608)
    lat = 37.771098
    lon = -122.430782
    radius = 5

    get "/v1/events/nearests?lat=#{lat}&lon=#{lon}&radius=#{radius}"

    expect(response_json).to eq([
      {
        'address' => near_event.address,
        'ended_at' => near_event.ended_at,
        'id' => near_event.id,
        'lat' => near_event.lat,
        'lon' => near_event.lon,
        'name' => near_event.name,
        'started_at' => near_event.started_at.as_json,
        'owner' => { 'id' => near_event.owner.id }
      },
      {
        'address' => less_near_event.address,
        'ended_at' => less_near_event.ended_at,
        'id' => less_near_event.id,
        'lat' => less_near_event.lat,
        'lon' => less_near_event.lon,
        'name' => less_near_event.name,
        'started_at' => less_near_event.started_at.as_json,
        'owner' => { 'id' => less_near_event.owner.id }
      }
    ])
  end

  it 'returns an error message when no event is found' do
    lat = 37.771098
    lon = -122.430782
    radius = 1

    get "/v1/events/nearests?lat=#{lat}&lon=#{lon}&radius=#{radius}"

    expect(response_json).to eq({ 'message' => 'No Events Found' })
    expect(response.code.to_i).to eq 200
  end
end
