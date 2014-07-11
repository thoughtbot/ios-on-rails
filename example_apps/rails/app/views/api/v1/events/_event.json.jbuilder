json.cache! event do
  json.address event.address
  json.ended_at event.ended_at
  json.id event.id
  json.lat event.lat
  json.lon event.lon
  json.name event.name
  json.started_at event.started_at

  json.owner do
    json.id event.owner.id
  end
end
