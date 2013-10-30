## Managing Dependencies

### Using CococaPods

Before we create our new iOS project, lets discuss the libraries and resources we're going to be using.

Firstly, we're going to use CocoaPods to manage our dependencies. Cocoapods is a ruby gem and command line tool that makes makes it easy to add dependencies to your project. Alternatively, you can use git submodules, but using CocoaPods is our preference due to its ease of implementation and the wide variety of third party libraries available as pods. CocoaPods will not only download the libraries we need and link them to our project in Xcode, it will also allow us to easily manage and update what version of each library we want to use we want to use.

Given that you have a background in ruby, it may help to think of CocoaPod "pods" as gems, meaning that podfiles function similarly to gemfiles and podspecs are similar to gemspecs. `$ pod install` can be thought of as running `$ bundle install`, except for the fact that a pod install inserts the actual libraries into your project's pod directory.

### CocoaPods Setup

What follows is a succinct version of the instructions on the CocoaPods website:

1. `$ gem install cocoapods`

2. Create a podfile text file in your iOS project's root directory using your editor of choice.

3. `$ pod install`

4. If you have your iOS project open in Xcode, close it and reopen the workspace that Cocoapods generated for you.

5. When using CocoaPods in conjunction with git, it is a good idea to ignore the Pods directory so that the libraries CocoaPods downloads are not under version control. Amend your .gitignore by addding `Pods` to prevent pushing up unncessary code. Anyone who clones your project will have the Podfile and can `pod install` the exact pods and versions that the project requires.

### Humon's Podfile

Installing the CocoaPods gem and creating a podfile is covered in more detail on their website. Below is the podfile we're going to use for this project, which indicates what libraries we'll be using.

	platform :ios, '7.0'
	
	pod 'TestFlightSDK', '~> 2.0'
	pod 'AFNetworking', '~> 2.0'
	pod 'Parse', '~> 1.2.11'
	
	target :HumonTests, :exclusive => true do
		pod 'Kiwi', '~> 2.2'
		pod 'KIF', '~> 2.0.0'
		pod 'Nocilla', '~> 0.7.1'
	end

The first three pods will be available no matter what target you use to build the app. The ones inside the target block will only be set as dependencies for the test target, since `:exclusive => true do` ensures that the testing pods are not only available to the test target and not in the actual app.

We will be using the TestFlight SDK to distribute our app to Beta testers. Parse will be used for push notifications and AFNetworking will handle all our API network requests.
