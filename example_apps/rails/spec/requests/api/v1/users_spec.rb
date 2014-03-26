require 'spec_helper'

describe 'POST /v1/users' do
  it 'saves email, facebook id, first name, image_url, last name' do
    post '/v1/users', {
      device_token: 'abc123',
    }.to_json, { 'Content-Type' => 'application/json' }

    user = User.last
    expect(response_json).to eq({ 'device_token' => user.device_token })
    expect(user.device_token).to eq 'abc123'
  end

  it 'does not create a user when a user aready exists with the device token' do
    device_token = 'abc123'
    create(:user, device_token: device_token)

    post '/v1/users', {
      device_token: device_token,
    }.to_json, { 'Content-Type' => 'application/json' }

    expect(User.count).to eq 1
    expect(response_json).to eq({ 'device_token' => device_token })
  end
end
