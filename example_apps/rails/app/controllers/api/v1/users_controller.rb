class Api::V1::UsersController < ApiController
  before_filter :authorize_app_secret, only: [:create]

  def create
    authorize do |user|
      @user = user

      if @user.save
        render
      else
        render json: {
          message: 'Validation Failed',
          errors: @user.errors.full_messages
        }, status: 422
      end
    end
  end

  private

  def authorize_app_secret
    unless correct_app_secret?
      render nothing: true, status: 404
    end
  end

  def correct_app_secret?
    request.headers['tb-app-secret'] == ENV.fetch('TB_APP_SECRET')
  end
end
