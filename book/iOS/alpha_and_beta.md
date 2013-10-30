## Using Alpha and Beta Schemes

### Distributing Early Builds

Distributing a Beta version of your app to testers before submitting to the app store is a vital part of the submittal process for medium to large scale apps. Humon may be a small app now, but we are going to set up a Alpha and Beta configuration and scheme in order to follow with best practices.

Every time you want to distribute a new build to Beta testers, you'll archive it and save it for ad hoc distribution. So, what we're going to do is create a Beta scheme that we'll use every time we archive a Beta version of the app. We'll use the default Humon scheme for archiving the actual production version of the app. The only differences between the new schemes will be the API endpoint (staging or production) we're hitting, the app name on the home screen, and the app's bundle ID.

Setting these manually is perfectly fine as well, but keeping separate configurations for Alpha, Beta, and production ensures that we never forget something important, like switching out the staging endpoint. The following steps will refer to creating the Beta scheme and are exactly the same for creating an Alpha scheme.

### Setting Up the New Schemes

1. **Create the new configuration**

	![Create the new configuration](images/ios_alpha_and_beta_1.png)

    Create a new configuration that's a duplicate of release, and call this new configuration Beta.
	
2. **Create the new scheme**

	![Create the new scheme](images/ios_alpha_and_beta_2.png)

	Create a new scheme that's a duplicate of the main Humon scheme. Call this scheme HumonBeta.
	
	![Set the scheme's build configuration](images/ios_alpha_and_beta_3.png)
	
	Set this scheme's run build configuration and archive build configuration to Beta.)
   
3. **Create user-defined settings**

	![Create user-defined settings](images/ios_alpha_and_beta_4.png)

    Create a user-defined setting in the Humon target's build settings. In Xcode 5 this can be found under Editor > Add Build Setting.
    
    Call the new user-defined setting SCHEME_VERSION and set it to Beta for the Beta configuration.
	
	Additionally, create a BASE_URL user-defined setting and set its value as your production URL for the release configuration and your staging URL for all the other configurations.

4. **Automate the bundle identifier and display name**

	![Automate the bundle identifier and display name](images/ios_alpha_and_beta_5.png)

	Change the Bundle identifier and the Bundle display name to include the ${SCHEME_VERSION} value.
   
	Now the name of the Beta app will display as HumonBeta and the bundle identifier will be com.thoughtbot.HumonBeta.

5. **Build the app using the new scheme.**

	The app's name should display as HumonBeta if everything has been configured correctly. In addition, you can use BASE_URL instead of a string literal everywhere you want to confitionally use your staging or production base URL.
