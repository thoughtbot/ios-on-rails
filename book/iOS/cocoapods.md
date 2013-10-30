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

5. When using CocoaPods in conjunction with git, you may choose to ignore the Pods directory so that the libraries that CocoaPods downloads are not under version control. If you want to do this, add `Pods` your .gitignore. Anyone who clones your project will have the Podfile and can `pod install` to retrieve the libraries and versions that the project requires.

### Humon's Podfile

Installing the CocoaPods gem and creating a podfile is covered in more detail on their website. Below is the podfile we're going to use for this project, which indicates what libraries we'll be using.

	platform :ios, '7.0'
	
	pod 'TestFlightSDK', '~> 2.0'
	pod 'Parse', '~> 1.2.11'
	
	pod 'AFNetworking', '~> 2.0'
	pod 'SSKeychain', '~> 1.2.1'
	pod 'SVProgressHUD', '~> 1.0'
	
	target :HumonTests, :exclusive => true do
		pod 'Kiwi', '~> 2.2'
	end

The `:exclusive => true do` block ensures that the HumonTests target only links to the testing frameworks inside the block. The frameworks outside the block will still be available to HumonTests target. Since they'll be available to the Humon target, which the testing

We will be using the TestFlight SDK to distribute our app to Beta testers. Parse will be used for push notifications by both the iOS app and the Rails app. AFNetworking will handle our API network requests, SSKeychain will help us save user info to the keychain, and SVProgressHUD will let us display loading views to the user.

Once you've updated your podfile, go ahead and run `$pod install`