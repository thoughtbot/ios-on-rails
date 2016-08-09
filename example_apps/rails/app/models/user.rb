class User < ActiveRecord::Base
  include DatabaseValidations

  before_validation :set_auth_token

  private

  def set_auth_token
    self.auth_token ||= SecureRandom.uuid
  end
end
