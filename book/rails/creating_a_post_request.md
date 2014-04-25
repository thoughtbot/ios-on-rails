## Creating a POST request

### Forgery protection strategy and Rails 4

Before we begin digging into creating POST requests to our API, we need to
change our forgery protection strategy.

Rails protects against [cross-site request
forgery](http://en.wikipedia.org/wiki/Cross-site_request_forgery) by protecting
your application from requests that are missing authenticity tokens. [An
explanation](http://stackoverflow.com/a/1571900/1019369) of authenticity tokens
in Rails:

> When the user views a form to create, update, or destroy a resource, the Rails
> app  would create a random `authenticity_token`, store this token in the
> session, and place it in a hidden field in the form. When the user submits the
> form, Rails would look for the `authenticity_token`, compare it to the one
> stored in the session, and if they match the request is allowed to continue.

Why this happens:

> Since the authenticity token is stored in the session, the client can not know
> its value. This prevents people from submitting forms to a Rails app
without viewing the form within that app itself. Imagine that you are using
service
A, you logged into the service and everything is ok. Now imagine that you went
to
use service B, and you saw a picture you like, and pressed on the picture to
view a
larger size of it. Now, if some evil code was there at service B, it might send
a 
request to service A (which you are logged into), and ask to delete your
account, by sending a request to `http://serviceA.com/close_account`. This is
what is known as
CSRF (Cross Site Request Forgery).

While protecting against CSRF attacks is a good thing, the default forgery
protection strategy in Rails 4 is problematic for dealing with POST requests to
APIs. If you make a POST request to a Rails endpoint (rather than using a
standard web form to create a record), you will see the following error:

    ActionController::InvalidAuthenticityToken

Rails lets us choose between forgery protection strategies. The default in Rails
4 is `:exception`, which we are seeing in action above. Rails recommends the
`:null_session` strategy for APIs, which empties the session rather than raising
an exception. Since we want this strategy for all API endpoints but not
necessarily all endpoints, we will create an `ApiController` that all of our API
controllers will inherit from and set the forgery protection strategy there:

    # app/controllers/api_controller.rb

    class ApiController < ApplicationController
      protect_from_forgery with: :null_session
    end

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApiController

    ...

    end

Now we're ready to get started on our first POST request.

### It all starts with a request spec

We will start working on our POST request the same way we began working on our
GET request: with a request spec.

    # spec/requests/api/v1/events/events_spec.rb

    describe 'POST /v1/events' do
      it 'saves the address, lat, lon, name, and started_at date' do
        date = Time.zone.now
        device_token = '123abcd456xyz'
        owner = create(:user, device_token: device_token)

        post '/v1/events', {
          address: '123 Example St.',
          ended_at: date,
          lat: 1.0,
          lon: 1.0,
          name: 'Fun Place!!',
          started_at: date,
          owner: {
            device_token: device_token
          }
        }.to_json, { 'Content-Type' => 'application/json' }

        event = Event.last
        expect(response_json).to eq({ 'id' => event.id })
        expect(event.address).to eq '123 Example St.'
        expect(event.ended_at.to_i).to eq date.to_i
        expect(event.lat).to eq 1.0
        expect(event.lon).to eq 1.0
        expect(event.name).to eq 'Fun Place!!'
        expect(event.started_at.to_i).to eq date.to_i
        expect(event.owner).to eq owner
      end
    end

Note about the time comparisons above: the reason we are calling `to_i` on
`event.started_at` and `event.ended_at` is that Ruby time (the time we are
setting when we declare the `date` variable) is more precise than ActiveRecord
time (the time we are getting back from `Event.last`). If you run the tests
without `to_i`, you will see something like this:

        expected: Wed, 16 Apr 2014 17:13:47 UTC +00:00
             got: Wed, 16 Apr 2014 17:13:47 UTC +00:00

Even though the date objects themselves appear equal, as [this blog post on time
comparisons in Rails
notes](http://blog.tddium.com/2011/08/07/rails-time-comparisons-devil-details-etc/),
"When the value is read back from the database, it's only preserved to
microsecond precision, while the in-memory representation is precise to
nanoseconds." Calling `to_i` on these dates normalizes them to use the same
place value, which renders them equal for our test.


#### Controller

When we run the test above, our first error should be `No route matches [POST]
"/v1/events"`. This is exactly the error we would expect, since we haven't
defined this route in our `routes.rb` file. Let's fix that:

    #config/routes.rb

    Humon::Application.routes.draw do
      scope module: :api, defaults: { format: 'json' } do
        namespace :v1 do
          resources :events, only: [:create, :show,]
        end
      end
    end

When we run the spec again, our error has changed to

    The action 'create' could not be found for Api::V1::EventsController

This is good; it means the route we
added is working, but we still need to add a `create` method to our
`EventsController`. So let's do that:

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApiController
      def create
      end

      ...

    end

Run the spec again, and our error has changed to `Missing template
api/v1/events/create`. Again, receiving a different error message is a good
indication that the last change we made is bringing us closer to a passing test.

We will get back to the view layer in the next section, but for now let's just
create an empty file at `app/views/api/v1/events/create.json.jbuilder`, since
that will help us get to our next error.

Run the spec again, and our error has changed (hooray!) to:

     Failure/Error: expect(response_json).to eq({ 'id' => event.id })
       NoMethodError:
         undefined method `id' for nil:NilClass

If we look back at our spec, we can see that `id` is being called on `event`,
which is the variable name we assigned to `Event.last`. By saying that `id` is
an undefined method for `nil`, our error is telling us that `Event.last` is
`nil`.

And of course it is! We haven't added any logic into our controller that would
create an instance of `Event`; at the moment, all we have is an empty `create`
method. Time to add some logic:

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApiController
      def create
        @event = Event.new(event_params)

        if @event.save
          render
        end
      end

      ...

      private

      def event_params
        {
          address: params[:address],
          ended_at: params[:ended_at],
          lat: params[:lat],
          lon: params[:lon],
          name: params[:name],
          started_at: params[:started_at],
          owner: user
        }
      end

      def user
        User.find_or_create_by(device_token: device_token)
      end

      def device_token
        params[:owner].try(:[], :device_token)
      end
    end

Our error message has changed yet again, and now it is time for us to move to
the final step: creating our view.

#### View

Our
[`EventsController`](https://github.com/thoughtbot/ios-on-rails/blob/master/example_apps/rails/app/controllers/api/v1/events_controller.rb)
is creating an `event`, but we are still getting an error when we run our spec
(note: your expectation might have a different `id` number depending on how many
time's you've run your test; that's fine):


    expect(response_json).to eq({ 'id' => event.id })
           expected: {"id"=>6}
            got: {}

The empty brackets we are getting tell us that our view is rendering an empty
JSON object. Time to fix our empty view template:

    # app/views/api/v1/events/create.json.jbuilder

    json.id @event.id

And with that, our test is passing. Nice work. But before we move on, let's not
forget our second POST spec.

### It all starts with a request spec, part II

Our first spec covered the "happy path," which
[Wikipedia](http://en.wikipedia.org/wiki/Happy_path) defines as the "a
well-defined test case using known input, which executes without exception and
produces an expected output." Our second test will show the "sad path," which
means that it will cover validation and error handling.

You might remember that our GET request section only contained a single test.
While these decisions are rarely black and white, it was our judgment that only
a "happy path" test was required for that endpoint. The "sad path" for a GET
request would occur when the `id` in the URL does not correspond to an existing
`event`. In that case, the application would return a [`404 Not
Found`](http://en.wikipedia.org/wiki/HTTP_404) response code, which is the
default behavior and therefore does not need to be tested.

By default, passing invalid attributes to our POST request would not create the
`event` and would return a response body without helpful error messages and a
misleading response code of [`200
OK`](http://en.wikipedia.org/wiki/HTTP_200#2xx_Success).

Because we want to change both the response body and the response code returned
when invalid attributes are used in a POST request, writing a test for that
scenario makes sense.

Let's move on to our "sad path" request spec and cover a POST request with
invalid attributes (it will go inside the same `describe` block as our first
POST request spec):

    # spec/requests/api/v1/events/events_spec.rb

    describe 'POST /v1/events' do

    ...

     it 'returns an error message when invalid' do
        post '/v1/events',
          {}.to_json,
          { 'Content-Type' => 'application/json' }

        expect(response_json).to eq({
          'message' => 'Validation Failed',
          'errors' => [
            "Lat can't be blank",
            "Lon can't be blank",
            "Name can't be blank",
            "Started at can't be blank",
          ]
        })
        expect(response.code.to_i).to eq 422
      end
    end

Creating an `event` without attributes does not work because of the validations
we set up in the GET request section of this book. If you need a refresher,
check out the validations on
[`Event`](https://github.com/thoughtbot/ios-on-rails/blob/master/example_apps/rails/app/models/event.rb).

Right now, rather than our response JSON containing the message and errors we
want to see, we get `{"id"=>nil}`. Time to look at the `EventsController`.

##### Controller

Right now, our controller doesn't contain any instructions for what to do in the
case that an `event` does not save properly, which is why we do not see the
message or errors included in our spec. So let's add those:

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApiController
      def create
        @event = Event.new(event_params)

        if @event.save
          render
        else
          render json: {
            message: 'Validation Failed',
            errors: @event.errors.full_messages
          }, status: 422
        end
      end

      ...

    end

With this change, our spec should be passing.

To manually test that this is working, make sure you are running `rails server`
and try a `curl` request in another Terminal window:

    $ curl --data "{}" http://localhost:3000/v1/events

You should see the same message and errors that are in the "sad path" spec
expectations.

With that, our second request spec is passing. Nice work!
