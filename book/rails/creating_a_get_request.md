## Creating a GET request

### It all starts with a request spec

At thoughtbot, we do test-driven and Outside-in development, which means that we
start work on any feature by writing a high-level test that describes user
behaviors. You can read a more detailed description of Outside-in development
[here](http://rubylearning.com/blog/2010/10/05/outside-in-development/), but the
benefits can be summarized as follows:

>  Outside-in along with the test-driven process helps you write just the
>  minimum amount of code that provides value to stakeholders, and not a line
>  more.

The external interface of our application will be the iOS app that GETs and
POSTs data to the Rails app, so [feature
specs](https://www.relishapp.com/rspec/rspec-rails/docs/feature-specs/feature-spec),
which usually interact with the application via web interfaces, do not make
sense. Jonas Nicklas, the creator of Capybara, [said it
best](http://www.elabs.se/blog/34-capybara-and-testing-apis): "Do not test APIs
with Capybara. It wasn't designed for it."

Instead, we will use [request
specs](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec).
RSpec request specs, like feature specs, are a great way to ensure the entire
stack is working together properly but via HTTP verbs, response codes, and
responses rather than browser interactions.

    # spec/requests/api/v1/events/events_spec.rb

    require 'spec_helper'

    describe 'GET /v1/events/:id' do
      it 'returns an event by :id' do
        event = create(:event)

        get "/v1/events/#{event.id}"

        expect(response_json).to eq(
          {
            'address' => event.address,
            'ended_at' => event.ended_at,
            'id' => event.id,
            'lat' => event.lat,
            'lon' => event.lon,
            'name' => event.name,
            'started_at' => event.started_at.iso8601(3),
            'owner' => {
              'device_token' => event.owner.device_token
            }
          }
        )
      end
    end

### Model

This first error we will get for the request spec above is that our app does not
have a factory named `event`. FactoryGirl guesses the class of the object based
on the factory name, so creating the `event` factory is a good opportunity to
set up our `Event` model.

At the model level, Rails applications that serve a JSON API look exactly like
regular web applications built with Rails. Although the views and controllers
will be versioned, we will write our migrations like standard Rails migrations
and keep our models within the models directory. You can see the data migrations
for our example application
[here](https://github.com/thoughtbot/ios-on-rails/tree/master/example_apps/rails/db/migrate).

At this point, let's assume our `User` model has already been created.

Our `Event` model has a few validations and relations, so we will write tests
for those validations. In our development process, we would write the following
tests line-by-line, watching them fail, and writing the lines in our model one
at a time to make them pass. We will use FactoryGirl, Shoulda Matchers, and
RSpec for our unit tests. To see our full test setup, see our `spec_helper`
[here](https://github.com/thoughtbot/ios-on-rails/blob/master/example_apps/rails/spec/spec_helper.rb).

    # spec/models/event.rb

    require 'spec_helper'

    describe Event, 'Validations' do
      it { should validate_presence_of(:lat) }
      it { should validate_presence_of(:lon) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:started_at) }
    end

    describe Event, 'Associations' do
      it { should have_many(:attendances) }
      it { should belong_to(:owner).class_name('User') }
    end

To make the tests pass, we will write a migration (note: your file name will be
different, as the numbers in the name are generated based on the date and time
the migration was created):

    # db/migrate/20131028210819_create_events.rb

    class CreateEvents < ActiveRecord::Migration
      def change
        create_table :events do |t|
          t.timestamps null: false
          t.string :address
          t.datetime :ended_at
          t.float :lat, null: false
          t.float :lon, null: false
          t.string :name, null: false
          t.datetime :started_at, null: false
          t.integer :user_id, null: false
        end

        add_index :events, :user_id
      end
    end

and add those validations to the model:

    # app/models/event.rb

    class Event < ActiveRecord::Base
      validates :lat, presence: true
      validates :lon, presence: true
      validates :name, presence: true
      validates :started_at, presence: true

      belongs_to :owner, foreign_key: 'user_id', class_name: 'User'
    end

Once this is working, we can add the `event` Factory to
[`spec/factories.rb`](https://github.com/thoughtbot/ios-on-rails/blob/master/example_apps/rails/spec/factories.rb)
for use in our request spec.

### Controller

At this point, we can create an `event` object using FactoryGirl, but our
request spec is failing on the next line. This is because we have no routes set
up for the path we are using in our test's GET request (`get
"/v1/events/#{event.id}"`). To fix this, we need to add a controller and
configure our `routes.rb` file.

As we discussed in the versioning section of our introduction, we will add
controllers within `api/v1` directory so that we may release future versions of
our API without breaking older versions of our application.

Because our `routes.rb` file tells our controllers to look for the JSON format
by default, we do not need to tell our individual controllers to render JSON
templates. We do, however, need to add our new paths to our routes file:

    # config/routes.rb

    Humon::Application.routes.draw do
      scope module: :api, defaults: { format: 'json' } do
        namespace :v1 do
          resources :events, only: [:show]
        end
      end
    end

Aside from including our controller within the `api/v1 directory`, our
`EventsController` looks much like a standard Rails controller. To make our
request spec pass, we need to add a single action to our API:

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApplicationController
      def show
        @event = Event.find(params[:id])
      end
    end

### View

Our controller and routes are set up, but we still need one final piece before
our spec will pass: a view. Our request spec is looking for a view template with
some response JSON, but so we need to create that view.

For a Rails developer, the views are where there will be the most difference
between a standard web application and a JSON API.  As with our controllers, we
will include our views in the `api/v1` directory so that they are versioned.

Just like regular view partials, Jbuilder partials minimize duplication by
letting us re-use blocks of view code in many different places. JSON
representations of data frequently include duplication (a collection is usually
an array of the same JSON structure that would be found for a single object), so
partials are especially handy when creating a JSON API. We will use Jbuilder’s
DSL to tell our show view to find the event partial:

    # app/views/api/v1/events/show.json.jbuilder

    json.partial! 'event', event: @event

Our show GET view is looking for a partial named `_event.json.jbuilder` within
the `events` directory. So we will create that partial next:

    # app/views/api/v1/events/_event.json.jbuilder

    json.cache! event do
      json.address event.address
      json.ended_at event.ended_at
      json.id event.id
      json.lat event.lat
      json.lon event.lon
      json.name event.name
      json.started_at event.started_at

      json.owner do
        json.device_token event.owner.device_token
      end
    end

#### Caching our view

You might be wondering what the `json.cache!` at the top of our `event` partial
is doing. Jbuilder supports [fragment
caching](http://guides.rubyonrails.org/caching_with_rails.html#fragment-caching),
and you tell your app to cache a block of view code by wrapping it in a
`json.cache!` block. While the load time for the JSON in our view above is going
to be teeny tiny, adding fragment caching is simple and a good habit to get into
for apps that are likely to expand over time.

If you're interested in learning more about fragment caching, there is a great
[Railscast](http://railscasts.com/episodes/90-fragment-caching-revised) (paid)
on the topic.

### Putting it all together

We have now successfully created our first API endpoint for Humon and our
request spec should pass!

But let's test it manually just to make sure. Our iOS app isn't up and running
yet, so we will have to create records in Rails console. Make sure you are in
your project directory in Terminal, run `rails console` and the enter the
following:

    User.create(device_token: '12345')
    Event.create(
      address: '85 2nd Street',
      lat: 37.8050217,
      lon: -122.409155,
      name: 'Best event OF ALL TIME!',
      owner: User.find_by(device_token: '12345')
    )

Assuming this created your first event (`id` will equal 1) and you are running
`rails server` in Terminal (you will need to exit from Rails console or open a
new Terminal window to do this), when you visit `localhost:3000/v1/events/1` in
your browser you should see something like this:

    {
      "address":"85 2nd Street",
      "ended_at":"2013-09-17T00:00:00.000Z",
      "id":1,
      "lat":37.8050217,
      "lon":-122.409155,
      "name":"Best event OF ALL TIME!",
      "started_at":"2013-09-16T00:00:00.000Z",
      "owner":{
        "device_token":"234324235"
       }
     }

Alternatively, you can run a [curl](http://curl.haxx.se/docs/manpage.html)
request (`curl http://localhost:3000/v1/events/1`) from Terminal and see the
same JSON output.

Congratulations, you just created your first API endpoint with Rails!
