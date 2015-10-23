require 'spec_helper'

describe 'POST /v1/users' do
  it 'creates a new user' do
    post '/v1/users', {}, set_headers

    user = User.last
    expect(response_json).to eq(
      {
        'auth_token' => user.auth_token,
        'id' => user.id
       }
    )
  end
end
