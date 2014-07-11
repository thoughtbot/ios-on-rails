class Api::V1::UsersController < ApiController
  def create
    authorize do |user|
      @user = user

      if @user.save
        render nothing: true
      else
        render json: {
          message: 'Validation Failed',
          errors: @user.errors.full_messages
        }, status: 422
      end
    end
  end
end
