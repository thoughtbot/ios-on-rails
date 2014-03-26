require 'spec_helper'

describe 'POST /v1/attendances' do
  it 'creates an attendance for a user and event' do
    event = create(:event)
    user = create(:user)

    post '/v1/attendances', {
      event: { id: event.id },
      user: { device_token: user.device_token }
    }

    expect(event.reload.attendances.count).to eq 1
  end

  it 'only allows a user to RSVP once per event' do
    event = create(:event)
    user = create(:user)

    2.times do
      post '/v1/attendances', {
        event: { id: event.id },
        user: { device_token: user.device_token }
      }
    end

    expect(event.reload.attendances.count).to eq 1
  end
end
