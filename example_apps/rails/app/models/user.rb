class User < ActiveRecord::Base
  validates :auth_token, uniqueness: true, presence: true

  before_validation :set_auth_token

  private

  def set_auth_token
    self.auth_token ||= SecureRandom.uuid
  end
end
