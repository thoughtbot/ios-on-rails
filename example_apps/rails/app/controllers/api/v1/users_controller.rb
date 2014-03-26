class Api::V1::UsersController < ApiController
  def create
    @user = User.find_or_initialize_by(device_token: params[:device_token])

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

  def user_params
    params.permit(
      :device_token,
    )
  end
end
