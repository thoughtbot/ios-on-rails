FactoryGirl.define do
  sequence :lat do |n|
    "#{n}.0".to_f
  end

  sequence :lon do |n|
    "#{n}.0".to_f
  end

  sequence :name do |n|
    "name #{n}"
  end

  sequence :started_at do |n|
    Time.zone.now + n.hours
  end

  sequence :token do
    SecureRandom.hex(3)
  end

  factory :attendance do
    event
    user
  end

  factory :event do
    lat
    lon
    name
    started_at
    owner factory: :user
  end

  factory :user do
    auth_token { generate(:token) }
  end
end
