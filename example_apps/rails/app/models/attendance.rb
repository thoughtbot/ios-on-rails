class Attendance < ActiveRecord::Base
  include DatabaseValidations

  belongs_to :event
  belongs_to :user
end
