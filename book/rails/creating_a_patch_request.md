## Creating a PATCH request

### It all starts with a request spec

We will start working on our PATCH request the same way we began working on our
other requests: with a request spec. In this test, we want to create an `event`
with the name `'Old Name'` and send a PATCH request to change the name to
`'New Name'`.

In our test setup, we will create the first event with `FactoryGirl` and then
use the PATCH request with a new event name in the parameters as the spec
exercise. Our expectation looks at the name of the `event` to confirm that it
was changed. The spec expectation also looks for the `event.id` in the
response, since that is what our iOS app will be expecting after a successful
PATCH request.

    # spec/requests/api/v1/events/events_spec.rb

    describe 'PATCH /v1/events/:id' do
      it 'updates the event attributes' do
        event = create(:event, name: 'Old name')
        new_name = 'New name'

        patch "/v1/events/#{event.id}", {
          address: event.address,
          ended_at: event.ended_at,
          lat: event.lat,
          lon: event.lon,
          name: new_name,
          owner: {
            device_token: event.owner.device_token
          },
          started_at: event.started_at
        }.to_json, { 'Content-Type' => 'application/json' }

        event = Event.last
        expect(event.name).to eq new_name
        expect(response_json).to eq({ 'id' => event.id })
      end


#### Controller

When we run the test above, we will again get a routing error: `No route
matches [PATCH] "/v1/events/13"` (note: your `id` will likely not be `13` like
mine, but the error message should otherwise be the same).

Let's add the `update` route to fix that:

    #config/routes.rb

    Humon::Application.routes.draw do
      scope module: :api, defaults: { format: 'json' } do
        namespace :v1 do
          resources :events, only: [:create, :show, :update]
        end
      end
    end

If we updated the `routes.rb` file correctly, running our test again should
produce a different error: `The action 'update' could not be found for
Api::V1::EventsController`.

What a nice, clear error message! Thank you, RSpec. Let's add that `update`
method to our controller.

Note: Rails' scaffolding places the `update` method second to last in the
controller, right above `destroy`. To stick with that convention, I will add
the `update` method below my other controller methods, right above the
`private` methods:

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApiController

     ...

      def update
      end

      private

      ...

    end

Run the spec again, and, our error has changed to `Missing template
api/v1/events/update`. Like we covered in the last section, receiving a
different error message is a good indication that the last change we made is
bringing us closer to a passing test.

We will address the view layer in the next section, but for now let's just
create an empty file at `app/views/api/v1/event/update.json.jbuilder`.

Run the spec again, and our error has changed (woot!) to:

    Failure/Error: expect(event.name).to eq new_name

       expected: "New name" got: "Old name"

See how handy the semantic variable naming in our test is?

Our route, controller method, and view template are in place. All that's left
is to add logic to our `update` method that actually updates our `event`:

    # app/controllers/api/v1/events_controller.rb

    def update
      @event = Event.find(params[:id])

      if @event.update_attributes(event_params)
        render
      end
    end

If we run our request spec again, we will find that `event.name` is now
updating correctly. Yay! But the test is still failing. Boo! Time to move onto
our view.

#### View

Our spec error now looks like this (note: your expectation might have a
different `id` number depending on how many time's you've run your test; that's
fine):

     Failure/Error: expect(response_json).to eq({ 'id' => event.id })

       expected: {"id"=>21} got: {}

Our view template exists, but is rendering an empty JSON object. And of course
it is, all we did was create an empty view template! Let's add the JSON our
test is expecting:

    # app/views/api/v1/events/update.json.jbuilder

    json.id @event.id

Our test passes!

### It all starts with a request spec, part II

If you guessed that our PATCH request requires two specs, you'd be right! One
thing we've found when creating APIs with Rails is that it's just as important
to return consistent, logical error messages and response codes as it is to
create endpoints and responses for valid requests.

Like our POST request, a PATCH request has as "sad path" where the parameters
passed are invalid. We need to create logic in our controller for that case,
and to test drive that logic we will write a request spec:


    # spec/requests/api/v1/events/events_spec.rb

    describe 'PATCH /v1/events/:id' do

      ...

      it 'returns an error message when invalid' do
         event = create(:event)

        patch "/v1/events/#{event.id}", {
           address: event.address,
           ended_at: event.ended_at,
           lat: event.lat,
           lon: event.lon,
           name: nil,
           owner: {
             device_token: event.owner.device_token
           },
           started_at: event.started_at
         }.to_json, { 'Content-Type' => 'application/json' }

         event = Event.last
         expect(event.name).to_not be nil
         expect(response_json).to eq({
           'message' => 'Validation Failed',
           'errors' => [
             "Name can't be blank",
           ]
         })
         expect(response.code.to_i).to eq 422
       end
     end

In our expectation above, we are hoping to see a `422` response, which is the
[most
appropriate](http://www.bennadel.com/blog/2434-HTTP-Status-Codes-For-Invalid-Data-400-vs-422.htm)
HTTP status code for a request with invalid (but not
[malformed](http://stackoverflow.com/a/20215807/1019369)) attributes.

The need for this test is apparent immediately upon running it: rather than
returning a validation erorr or telling response code, we are getting the same
response from a PATCH request with *invalid* parameters that we got from a PATCH
request with *valid* parameters:

     Failure/Error: expect(response_json).to eq({

       expected: {"message"=>"Validation Failed", "errors"=>["Name can't be blank"]}
            got: {"id"=>24}

Our iOS app will have no way of knowing that a request with invalid parameters
was passed, since it returns the same JSON either way.

To fix this, we will add a branching statement to our controller method that
renders the `event` error messages (note: these error messages already exist
because of the validations we set up in our `Event` model) and a `422` status:

    # app/controllers/api/v1/events_controller.rb

    class Api::V1::EventsController < ApiController

      ...

      def update
        @event = Event.find(params[:id])

      if @event.update_attributes(event_params)
        render
      else
        render json: {
          message: 'Validation Failed',
          errors: @event.errors.full_messages
        }, status: 422
      end

Phew! Our test passes.

Hooray! We've now successfully implemented 3 different HTTP requests
in our Rails API. Don't forget to update the API documentation. Next we'll
be having some fun with geocoding!
