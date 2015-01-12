# Creating a geocoded GET request

### What is geocoding?

> Geocoding is the process of finding associated geographic coordinates (often
> expressed as latitude and longitude) from other geographic data, such as
> street addresses, or ZIP codes.

-- [Wikipedia](http://en.wikipedia.org/wiki/Geocoding).

Geocoding gives us the power to take location information from humans and turn
it into something that a computer can understand and reason about.

[Yelp](http://www.yelp.com), for example, does not ask businesses to add their
latitude and longitude when creating a profile. Instead, they ask for the
street address and zipcode, which the Yelp application transforms into a
latitude and longitude that can be plotted on a map.

This is important because humans don't think in the decimal precision terms of
latitude and longitude, but computers do. A web application that receives
location information from humans will always receive a string of text, and that
application cannot plot locations on a map or compute distances between points
without turning that text into a set of coordinates.

There are many approaches to geocoding with Rails. If you're interested in
learning more, thoughbot's [*Geocoding on
Rails*](http://geocodingonrails.com) provides a
thorough analysis and discussion of the various options.

### Geocoding in Humon: choosing a library

For Humon, we aren't going to be transforming one type of geographic data to
another. What we want is to be able to receive a latitude and longitude from
the iOS application and return the closest events to those coordinates.

After consulting *Geocoding on Rails*, we chose the
[Geocoder](https://github.com/alexreisner/geocoder) gem for Humon. It supports
distance queries, is simple to use, and is under active development.

### It all starts with a request spec

Before we jump into setting up our `Event` model with the Geocoder gem, let's
write a request spec for this new endpoint. Since this new endpoint will
require a controller of its own, we will create an `events` directory within
`spec/requests` and include this spec there:

    # spec/requests/api/v1/events/nearest_spec.rb

    describe 'GET /v1/events/nearests?lat=&lon=&radius=' do
      it 'returns the events closest to the lat and lon' do
        near_event = create(:event, lat: 37.760322, lon: -122.429667)
        farther_event = create(:event, lat: 37.760321, lon: -122.429667)
        create(:event, lat: 37.687737, lon: -122.470608)
        lat = 37.771098
        lon = -122.430782
        radius = 5

        get "/v1/events/nearests?lat=#{lat}&lon=#{lon}&radius=#{radius}"

        expect(response_json).to eq([
          {
            'address' => near_event.address,
            'ended_at' => near_event.ended_at,
            'id' => near_event.id,
            'lat' => near_event.lat,
            'lon' => near_event.lon,
            'name' => near_event.name,
            'owner' => { 'device_token' => near_event.owner.device_token },
            'started_at' => near_event.started_at.as_json,
          },
          {
            'address' => farther_event.address,
            'ended_at' => farther_event.ended_at,
            'id' => farther_event.id,
            'lat' => farther_event.lat,
            'lon' => farther_event.lon,
            'name' => farther_event.name,
            'owner' => { 'device_token' => farther_event.owner.device_token },
            'started_at' => farther_event.started_at.as_json,
          }
        ])
      end
    end

### Controller

When we run the test above, we get an interesting error:

    ActiveRecord::RecordNotFound:
       Couldn't find Event with id=nearests

What's that about!? If we run `rake routes` in our shell we'll see that our app
has the following GET endpoint defined:

    GET   /v1/events/:id(.:format)  api/v1/events#show

Rails is matching `get '/v1/events/nearests'` to this pattern and thinks we are
looking for an `event` with an `id` of `nearests`. How do we fix this? We need
to tell our Rails app that a GET request at `events/nearests` is different from
a GET request at `events/:id` (note: we must define this route *before* the
other `events` routes within the file or it will be overridden):

    # config/routes.rb

    Humon::Application.routes.draw do
      scope module: :api, defaults: { format: 'json' } do
       namespace :v1 do
          namespace :events do
            resources :nearests, only: [:index]
          end

      ...

        end
      end
    end

If we run `rake routes` in the shell again, we'll see that there's a new GET
endpoint:

    GET   /v1/events/nearests(.:format) api/v1/events/nearests#index

And when we run our test again, our error has changed:

    ActionController::RoutingError:
       uninitialized constant Api::V1::Events

Nice! Our routes file now knows that we are looking for a controller within
`Api::V1::Events` rather than the `EventsController`, but we haven't defined
anything within that namespace. Time to define our controller.  In the
[`NearestsController`](https://github.com/thoughtbot/ios-on-rails/blob/master/example_apps/rails/app/controllers/api/v1/events/nearests_controller.rb),
we will be using the [`near`
scope](https://github.com/alexreisner/geocoder#location-aware-database-queries)
(given to us by the Geocoder gem) which takes in a latitude-longitude pair,
radius, and units as arguments:

    # app/controllers/api/1/events/nearests_controller.rb

    class Api::V1::Events::NearestsController < ApiController
      def index
        @events = Event.near(
          [params[:lat], params[:lon]],
          params[:radius],
          units: :km
        )
      end
    end

Run the test again, and again, our test is failing:

     NoMethodError:
       undefined method `near' for #<Class:0x007ffba8583468>

Oh yeah! We forgot to actually add the Geocoder gem. Let's do that now.

### Model (and Gemfile)

Let's start by adding `gem 'geocoder'` to our
[Gemfile](https://github.com/thoughtbot/ios-on-rails/blob/master/example_apps/rails/Gemfile)
and running `bundle install`.

We already have the `lat` and `lon` attributes on our `Event` model, so no need
for a database migration. If we run our test again, however, we will get the
same `undefined method` error that we got before.

According to the [Geocoder
README](https://github.com/alexreisner/geocoder#object-geocoding), "your model
must tell Geocoder which method returns your object's geocodable address".
Since our model is *already* geocoded (meaning: it already has the latitude and
longitude set) we need to tell Geocoder which attributes store latitude and
longitude:

    # app/models/event.rb

    class Event < ActiveRecord::Base

      ...

      reverse_geocoded_by :lat, :lon

    end

This setup is a bit confusing. If we were *reverse geocoding*, we would be
looking at the latitude and longitude in order to find an address. On the other
hand, if we were *geocoding*, we would be turning an address string into a set
of coordinates.

In Humon we're neither geocoding nor reverse geocoding. We're using geolocation
information to find objects that are close to each other using Geocoder's
`near` scope. By adding the line above to our `Event` model, we are telling
Geocoder that this is a geocoded model and that the geocoded coordinates are
named `lat` and `lon`.

An illustrative example: comment out the new line in our `Event` model above
and open a Rails console. Create or select an `event`:

    irb(main):001:0> event = Event.first

    irb(main):002:0> event.geocoded?

    NoMethodError: undefined method `geocoded?' for #<Event:0x007fdb4e4353b0>

Does this error message look familiar? Answer: yes! This is the same type of
error we got when we last ran our test.

Let's reload our Rails console by running `reload!`, add `reverse_geocoded_by :lat,
:lon` back to the `Event` model, and do the same thing:

    irb(main):001:0> event = Event.first

    irb(main):002:0> event.geocoded?

    => true

By adding `reverse_geocoded_by`, we are telling Geocoder that this is a
geocoded object, and consequently giving our `Event` model access to Geocoder's
instance methods, such as `geocoded?`, and scopes, such as `near`.

### View

Run the test again, and our failure has changed.

      Failure/Error: get "/v1/events/nearests?lat=#{lat}&lon=#{lon}&radius=#{radius}"
      ActionView::MissingTemplate api/v1/events/nearests/index

We now need to create a `nearests` directory within `app/views/api/v1/events` and
create the following template inside of that directory:

    # app/views/api/v1/events/nearests/index.json.jbuilder

    json.partial! 'api/v1/events/event', collection: @events, as: :event

This view is using the `_event.json.jbuilder` template we already have, and
rendering the `@events` found in the controller.

When we run our test again, and it passes! Time to address the sad path...

### It all starts with a request spec, part II

We want to explicitly define what happens when there are no events nearby.
Let's do that through writing a test first:

    # spec/requests/api/v1/events/nearest_spec.rb

    describe 'GET /v1/events/nearest?lat=&lon=&radius=' do

     ...

      it 'returns an error message when no event is found' do
        lat = 37.771098
        lon = -122.430782
        radius = 1

        get "/v1/events/nearest?lat=#{lat}&lon=#{lon}&radius=#{radius}"

        expect(response_json).to eq({ 'message' => 'No Events Found' })
        expect(response.code.to_i).to eq 200
      end
    end

  When we run this test, we get the following error:

     expected: {"message"=>"No Events Found"}
           got: []


### Controller

Time to add some branching in our controller so that we're returning the
correct message.

    # app/controllers/api/v1/events/nearests_controller.rb

    class Api::V1::Events::NearestsController < ApiController
      def index

      ...

        if @events.count(:all) > 0
          render
        else
          render json: { message: 'No Events Found' }, status: 200
        end
      end
    end

And just like that, our test is now passing.
