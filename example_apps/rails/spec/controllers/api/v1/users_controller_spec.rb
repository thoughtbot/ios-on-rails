require 'spec_helper'

describe Api::V1::UsersController do
  it 'looks for an app secret in the headers' do
    app_secret = 'testsecret'
    auth_token = 'abc123'
    ENV['TB_APP_SECRET'] = app_secret

    request.headers['tb-app-secret'] = app_secret
    request.headers['tb-auth-token'] = auth_token
    post :create, format: :json

    expect(response).to be_ok
  end

  it 'does not allow requests without a valid app secret in the header' do
    app_secret = 'testsecret'
    auth_token = 'abc123'
    ENV['TB_APP_SECRET'] = app_secret

    request.headers['tb-app-secret'] = 'other_secret'
    request.headers['tb-auth-token'] = auth_token
    post :create, format: :json

    expect(response.status).to eq 404
  end
end
