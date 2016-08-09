class Event < ActiveRecord::Base
  include DatabaseValidations

  has_many :attendances
  belongs_to :owner, foreign_key: 'user_id', class_name: 'User'
  has_many :users, through: :attendances

  reverse_geocoded_by :lat, :lon
end
