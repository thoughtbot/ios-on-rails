# Managing Dependencies

### Using CococaPods

Before we create our new iOS project, 
lets discuss the libraries and resources we will use.

We'll be using CocoaPods to manage our dependencies. 
CocoaPods is a Ruby gem and command line tool 
that makes it easy to add dependencies to your project. 
We prefer CocoaPods over Git submodules 
due to its ease of implementation 
and the wide variety of third-party libraries available as pods. 
CocoaPods will not only download the libraries we need 
and link them to our project in Xcode, 
it will also allow us to easily manage 
and update which version of each library we want to use.

### CocoaPods Setup

What follows is a succinct version of the instructions on the [CocoaPods](http://guides.cocoapods.org/using/getting-started.html) website:

1. `$ gem install cocoapods` or `$ gem install cocoapods` to use the latest version. The Podfile we provide in the next section uses CocoaPods v1.0 syntax.

2. Navigate to your iOS project's root directory.

3. Create a text file named `Podfile` using your editor of choice.

4. `$ pod install`

5. If you have your iOS project open in Xcode, close it and reopen the workspace that CocoaPods generated for you.

6. When using CocoaPods in conjunction with Git, you may choose to ignore the Pods directory so the libraries that CocoaPods downloads are not under version control. If you want to do this, add `Pods` your .gitignore. Anyone who clones your project will need to `$ pod install` to retrieve the libraries that the project requires.

### Humon's Podfile

Installing the CocoaPods gem and creating a podfile is covered in more detail on their website. 
Below is the podfile we're going to use for this project.

	platform :ios, '7.0'

	target 'Humon' do
		pod 'SSKeychain', '~> 1.2.2'
		pod 'SVProgressHUD', '~> 1.0'
	end

SSKeychain will help us save user info to the keychain. 
SVProgressHUD will let us display loading views to the user. 
Once you've updated your podfile, go ahead and run `$ pod install`
