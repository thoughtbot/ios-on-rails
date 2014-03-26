class Api::V1::EventsController < ApiController
  def create
    @event = Event.new(event_params)

    if @event.save
      render
    else
      render json: {
        message: 'Validation Failed',
        errors: @event.errors.full_messages
      }, status: 422
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(event_params)
      render
    else
      render json: {
        message: 'Validation Failed',
        errors: @event.errors.full_messages
      }, status: 422
    end
  end

  private

  def event_params
    {
      address: params[:address],
      ended_at: params[:ended_at],
      lat: params[:lat],
      lon: params[:lon],
      name: params[:name],
      started_at: params[:started_at],
      owner: user
    }
  end

  def user
    User.find_or_create_by(device_token: device_token)
  end

  def device_token
    params[:owner].try(:[], :device_token)
  end
end
