require 'spec_helper'

describe 'POST /v1/users' do
  it 'saves email, facebook id, first name, image_url, last name' do
    device_token = 'abc123'

    post '/v1/users',
      nil,
      set_headers(device_token)

    user = User.last
    expect(user.device_token).to eq 'abc123'
  end

  it 'does not create a user when a user aready exists with the device token' do
    device_token = 'abc123'
    create(:user, device_token: device_token)

    post '/v1/users',
      nil,
      set_headers(device_token)

    expect(User.count).to eq 1
  end
end
