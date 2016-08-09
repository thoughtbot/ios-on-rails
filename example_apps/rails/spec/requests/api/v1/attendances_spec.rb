require 'spec_helper'

describe 'POST /v1/attendances' do
  it 'creates an attendance for a user and event' do
    event = create(:event)
    user = create(:user)

    post '/v1/attendances',
      params: { event: { id: event.id } },
      headers: set_headers(user.auth_token),
      as: :json

    expect(event.reload.attendances.count).to eq 1
  end

  it 'only allows a user to RSVP once per event' do
    event = create(:event)
    user = create(:user)

    2.times do
      post '/v1/attendances',
        params: { event: { id: event.id } },
        headers: set_headers(user.auth_token),
        as: :json
    end

    expect(event.reload.attendances.count).to eq 1
  end
end
