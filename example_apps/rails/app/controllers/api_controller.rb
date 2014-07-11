class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  def authorize
    if authorization_token
      yield User.find_or_initialize_by(device_token: authorization_token)
    else
      render nothing: true, status: 401
    end
  end

  private

  def authorization_token
    @authorization_token ||= authorization_header
  end

  def authorization_header
    request.headers['tb-device-token']
  end

end
