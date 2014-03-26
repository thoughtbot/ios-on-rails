class Api::V1::AttendancesController < ApiController
  def create
    event = Event.find(params[:event][:id])
    user = User.find_by(device_token: params[:user][:device_token])

    Attendance.create(event: event, user: user)
  end
end
