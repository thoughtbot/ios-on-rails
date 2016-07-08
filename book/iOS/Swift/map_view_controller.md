# The Map View Controller

![Map View for viewing events](images/ios_app_skeleton_1.png)

### Create the New View Controller Class

Create a new view controller subclass called `MapViewController` by selecting File > New > File.

![Creating a new view controller](images/ios_app_skeleton_3.png)

Select the new `MapViewController.swift` file and declare the `MapViewController` class as follows:

	// MapViewController.swift
	
	class MapViewController: UIViewController {
	}

### Assign the Class in the Storyboard

Now that we have a view controller subclass that will serve as our map view controller,
we can assign this new class to the `view controller` we created in the Storyboard.

Open `Main.storyboard` and select the `view controller`.
In the attributes inspector, set the custom class of the `view controller` to be `MapViewController`.

PICTURE OF CUSTOM CLASS SETTING

### Creating an Outlet for the MapView

We need to create a IBOutlet property for the `mapView` so we can call map view methods and assign pins to our map. 

First, import MapKit by placing `import MapKit` at the top of `MapViewController.swift`.

With `MapViewController.swift` open in the editor, toggle the assistant editor. This will show `Main.storyboard` in the assistant editor on the right, allowing us to connect the Swift file to the Storyboard file.

Hold down `ctrl` and drag from the Storyboard's map view to inside the `MapViewController` class. Name the map view `mapView`.

Once you've created an outlet for your `mapView`, your `MapViewController` class should look like this:

	// MapViewController.swift
	
	import UIKit
	import MapKit
	
	class MapViewController: UIViewController {
		@IBOutlet weak var mapView: MKMapView!
	}

### Assigning a MapView Delegate

The `MapViewController` needs to receive delegate messages from the `mapView`, such as when the map is panned or when the user taps on a pin. We can assign the delegate of the `mapView` programatically or via the Storyboard.

First though, we need to declare that the `MapViewController` conforms to the `MKMapViewDelegate` protocol by adding `MKMapViewDelegate` to its class declaration:

	// MapViewController.swift
	
	class ViewController: UIViewController, MKMapViewDelegate {
	...

To assign the `MapViewController` as the `mapView`'s delegate, override the `viewDidLoad` method in the `MapViewController`.

	// MapViewController.swift
	
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
Now the `MapViewController` is a delegate of the `mapView`, and can respond to `MKMapViewDelegate` methods.
