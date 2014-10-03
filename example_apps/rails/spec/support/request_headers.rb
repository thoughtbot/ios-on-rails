module RequestHeaders
  def set_headers(device_token)
    app_secret = 'secretkey'
    ENV['TB_APP_SECRET'] = app_secret

    {
      'tb-app-secret' => app_secret,
      'tb-device-token' => device_token,
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include RequestHeaders
end
