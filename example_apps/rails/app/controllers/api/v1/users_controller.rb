class Api::V1::UsersController < ApiController
  before_action :authorize_app_secret, only: [:create]

  def create
    @user = User.new

    if @user.save
      render
    else
      render json: {
        message: 'Validation Failed',
        errors: @user.errors.full_messages
      }, status: 422
    end
  end

  private

  def authorize_app_secret
    unless correct_app_secret?
      head :not_found
    end
  end

  def correct_app_secret?
    request.headers['tb-app-secret'] == ENV.fetch('TB_APP_SECRET')
  end
end
