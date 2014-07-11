class Api::V1::AttendancesController < ApiController
  def create
    authorize do |user|
      event = Event.find(params[:event][:id])
      user = user

      Attendance.create(event: event, user: user)
    end
  end
end
