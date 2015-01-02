# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#create seed events
10.times do |i|
  Event.create({
    name: Faker::Name.name,
    ended_at: Faker::Time.forward(14, :evening),
    started_at: Faker::Time.backward(14, :morning),
    user_id: i + 1,
    address: Faker::Address.street_address,
    lat: Faker::Address.latitude,
    lon: Faker::Address.longitude
  })
end

#create seed users
10.times do |i|
  User.create({
    device_token: Faker::Number.number(10).to_s,
  })
end

#create seed attendances
10.times do |i|
  Attendance.create({
    event_id: i + 1,
    user_id: i + 1
  })
end

