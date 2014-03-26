class User < ActiveRecord::Base
  validates :device_token, uniqueness: true, allow_blank: true
end
