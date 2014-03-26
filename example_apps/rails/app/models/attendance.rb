class Attendance < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  validates :event, presence: true
  validates :user, presence: true
  validates :event_id, uniqueness: { scope: :user_id,
    message: 'Can only RSVP once per event' }
end
