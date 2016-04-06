@import MapKit;

static NSString *const HUMMapViewControllerAnnotationGreen = @"HUMMapViewControllerAnnotationGreen";
static NSString *const HUMMapViewControllerAnnotationGrey = @"HUMMapViewControllerAnnotationGrey";

@interface HUMAnnotationView : MKAnnotationView

- (void)startAnimating;
- (void)stopAnimating;

@end
