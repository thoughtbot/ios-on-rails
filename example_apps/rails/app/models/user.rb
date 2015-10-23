class User < ActiveRecord::Base
  validates :device_token, uniqueness: true, presence: true

  before_validation :set_device_token

  private

  def set_device_token
    self.device_token ||= SecureRandom.uuid
  end
end
