# Managing Dependencies

### Using CococaPods

Before we create our new iOS project, lets discuss the libraries and resources we will use.

We'll be using CocoaPods to manage our dependencies. Cocoapods is a Ruby gem and command line tool that makes it easy to add dependencies to your project. Alternatively, you can use Git submodules, but using CocoaPods is our preference due to its ease of implementation and the wide variety of third-party libraries available as pods. CocoaPods will not only download the libraries we need and link them to our project in Xcode, it will also allow us to easily manage and update which version of each library we want to use.

With a background in Ruby, it may help to think of CocoaPod "pods" as gems, meaning that podfiles function similarly to gemfiles and podspecs are similar to gemspecs. `$ pod install` can be thought of as running `$ bundle install`, except for the fact that a pod install inserts the actual libraries into your project's pod directory.

### CocoaPods Setup

What follows is a succinct version of the instructions on the [CocoaPods](http://guides.cocoapods.org/using/getting-started.html) website:

1. `$ gem install cocoapods`

2. Create a podfile text file in your iOS project's root directory using your editor of choice.

3. `$ pod install`

4. If you have your iOS project open in Xcode, close it and reopen the workspace that Cocoapods generated for you.

5. When using CocoaPods in conjunction with Git, you may choose to ignore the Pods directory so the libraries that CocoaPods downloads are not under version control. If you want to do this, add `Pods` your .gitignore. Anyone who clones your project will have the Podfile and can `$ pod install` to retrieve the libraries and versions that the project requires.

### Humon's Podfile

Installing the CocoaPods gem and creating a podfile is covered in more detail on their website. Below is the podfile we're going to use for this project, which indicates what libraries we'll be using.

	platform :ios, '7.0'
	
	pod 'AFNetworking', '~> 2.4.1'
	pod 'SSKeychain', '~> 1.2.2'
	pod 'SVProgressHUD', '~> 1.0'
	
	target :HumonTests  do
	  pod 'Kiwi', '~> 2.3.0'
	  pod 'OHHTTPStubs', '~> 3.0.2'
	end
	
	target :HumonUITests, :exclusive => true do
	  pod 'KIF', '~> 3.0.8'
	end

The `:exclusive => true do` block ensures that the HumonUITests target only links to the testing frameworks inside the block. The frameworks outside the block will still be available to HumonUITests target since they'll be available to the main Humon target.

AFNetworking will handle our API network requests, SSKeychain will help us save user info to the keychain, and SVProgressHUD will let us display loading views to the user.

Another important Pod to add is either Hockey or TestFlight to distribute our app to Beta testers. That process is outlined superbly on either of their developer support pages.

Once you've updated your podfile, go ahead and run `$ pod install`
