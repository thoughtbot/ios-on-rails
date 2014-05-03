# Posting an Event With AFNetworking

Now lets POST an event using AFNetworking. You may continue building your own HUMRailsClient if you so desire, but henceforth we will be using AFNetworking for all our networking requests. 

### Declaring a Task for Making Requests

Once we complete a request to POST an event, we want to return the event that we just posted. The /events POST request will return an event ID from the rails API, so we'll set this ID on the event object before returning it.

Typedef this new type of event completion block:

	// HUMRailsAFNClient.h

	typedef void(^HUMRailsAFNClientEventCompletionBlock)(HUMEvent *event);

and declare the event creation method:

	// HUMRailsAFNClient.h

	- (void)createEvent:(HUMEvent *)event
        	withCompletionBlock:(HUMRailsAFNClientEventCompletionBlock)block;

### Creating a Task for Making Requests

With AFNetworking, making a POST request with a dictionary of parameters is quite easy. We call the `POST:parameters:success:failure` method and provide the `@"events"` path, the event's JSON dictionary, and a success and failure block. 

	// HUMRailsClient.m
	
    - (void)createEvent:(HUMEvent *)event
    		withCompletionBlock:(HUMRailsAFNClientEventCompletionBlock)block
    {
        [self POST:@"events"
        parameters:[event JSONDictionary]
           success:^(NSURLSessionDataTask *task, id responseObject) {
               
            event.eventID = responseObject[@"id"];
            block(event);
               
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            block(nil);
            
        }];
    }

In the case of success, we want to change the ID number on the event object and execute the completion block with the event. If there's a failure, we execute the block with `nil`. We don't have to worry about forcing the completion block to the main thread since the success and failure blocks are fired off on the main thread.

### Making the POST Request

All POSTs to /events will happen inside of the HUMAddEventViewController. Eventually, the user will be able to populate the tableView with event information so that tapping the "Done" cell will POST an event using their input. For now, we will just create an event with fake event data on tapping the "Add" cell.

	// HUMAddEventViewController.m
	
    - (void)tableView:(UITableView *)tableView
            didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
    	// If the user didn't select the last row, we don't need to do anything
        if (indexPath.row != 5)
            return;
        
        // Create an event with fake data
        NSDictionary *fakeEventData = @{
                                    @"name" : @"Dolores Park Picnic",
                                    @"address" : @"566 Dolores St",
                                    @"ended_at" : @"2013-09-17T00:00:00.000Z",
                                    @"started_at" : @"2013-09-16T00:00:00.000Z",
                                    @"lat" : @"37.7583",
                                    @"lon" : @"-122.4275",
                                    @"user" :
                                    @{ @"device_token" : [HUMUser currentUserID] }
                                    };
        HUMEvent *event = [[HUMEvent alloc] initWithJSON:fakeEventData];
        
        // Post the event
        [SVProgressHUD show];
        [[HUMRailsAFNClient sharedClient] createEvent:event
                                  withCompletionBlock:^(HUMEvent *event) {
        	[SVProgressHUD dismiss];
        }];
    }
    
Instead of simply dismissing the progress display, we should present a HUMConfirmationViewController once the POST completes successfully.

	// HUMAddEventViewController.m

    if (!event) {
        [SVProgressHUD showErrorWithStatus:@"Event creation error"];
        return;
    }
                              
    [SVProgressHUD dismiss];
    HUMConfirmationViewController *confirmationViewController =
                              [[HUMConfirmationViewController alloc] init];
    [self.navigationController pushViewController:confirmationViewController
                                         animated:YES];

Now you can go through the general flow of hitting the "Add Event" button, confirming with the "Done" button, and recieving confirmation by seeing the HUMConfirmationViewController.
