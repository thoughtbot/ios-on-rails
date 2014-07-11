class Api::V1::EventsController < ApiController
  def create
   authorize do |user|
      @user = user
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
  end

  def show
    @event = Event.find(params[:id])
  end

  def update
    authorize do |user|
      @user = user
      @event = Event.find(params[:id])

      if @event.update(event_params)
        render
      else
        render json: {
          message: 'Validation Failed',
          errors: @event.errors.full_messages
        }, status: 422
      end
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
      owner: @user
    }
  end
end
