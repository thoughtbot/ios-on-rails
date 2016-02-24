# Alpha and Beta Schemes

Distributing a Beta version of your app to testers before submitting to the app store is a vital part of the submittal process for medium- to large-scale apps. Humon may be a small app now, but we are going to set up an Alpha and Beta configuration and scheme so as to follow best practices.

Every time you want to distribute a new build to Beta testers, you'll archive it and save it for ad hoc distribution. So what we're going to do is create a Beta scheme that we'll use every time we archive a Beta version of the app. We'll use the default Humon scheme for archiving the app's actual production version. The only differences between the new schemes will be the API endpoint (staging or production) we're hitting, the app name on the home screen, and the app's bundle ID.

Setting these manually is perfectly fine as well, but keeping separate configurations for Alpha, Beta, and production ensures that we never forget something important, like switching out the staging endpoint. The following steps will refer to creating the Beta scheme. They are exactly the same for creating an Alpha scheme.

### Setting Up the New Schemes

![1. Create the new configuration](images/ios_alpha_and_beta_6.png)

1. **Create the new configuration**

    Select the Humon project in the file navigator and then the Humon project in the editor. Under the "Info" tab, use the plus button to create a new configuration that's a duplicate of release. Call this new configuration Beta.


![2. Create the new scheme](images/ios_alpha_and_beta_1.png)

2. **Create the new scheme**

	Open the scheme drop down next to the stop button. Select `New Scheme...` and create a duplicate of the main Humon scheme. Call this scheme HumonBeta.


![3. Configure the scheme](images/ios_alpha_and_beta_3.png)

3. **Configure the scheme**

	Set this scheme's run build configuration and archive build configuration to the Beta configuration you created in step 1.


![4. Share the scheme](images/ios_alpha_and_beta_2.png)

4. **Share the scheme**

	We want this scheme to be shared so that any other developers working on this app will be able to access it. Open the scheme drop down we used in step 2 and select `Manage Schemes...` instead. Set the Humon and HumonBeta scheme to shared.


![5. Automate the bundle identifier and display name](images/ios_alpha_and_beta_5.png)

5. **Automate the bundle identifier and display name**

	Select the Humon project in the file navigator and then the Humon target in the editor. Under the "Info" tab, change the Bundle display name to include `${CONFIGURATION}`. `${CONFIGURATION}` evaluates to the name of the current build configuration. Now the name of the Beta app will display as HumonBeta.


![6. Add a ROOT_URL to pre-processor macros](images/ios_alpha_and_beta_4.png)

6. **Add a ROOT_URL to pre-processor macros**

	Under the "Build Settings" tab, search for preprocessor macros and add `ROOT_URL='@"yourProductionURL/"'` to the Beta and release configurations as well as `ROOT_URL='@"yourStagingURL/"'` to the debug configuration.

7. **Build the app using the new scheme**

	The app's name should display as HumonBeta if everything has been configured correctly. In addition, you can now use `ROOT_URL` instead of a string literal everywhere you want to conditionally use your staging or production base URL.
