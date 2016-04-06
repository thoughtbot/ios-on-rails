#import "HUMAnnotationView.h"

@interface HUMAnnotationView ()

@property (assign, nonatomic) BOOL shouldAnimate;


@end

@implementation HUMAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:@"HUMButtonQuestion"]
                      forState:UIControlStateNormal];
    [button sizeToFit];
    self.rightCalloutAccessoryView = button;
    self.canShowCallout = YES;

    UIImage *image;
    if (reuseIdentifier == HUMMapViewControllerAnnotationGreen) {
        image = [UIImage imageNamed:@"HUMPlacemarkSmall"];
    } else if (reuseIdentifier == HUMMapViewControllerAnnotationGrey) {
        image = [UIImage imageNamed:@"HUMPlacemarkSmallGrey"];
    }
    self.image = image;

    return self;
}

- (void)startAnimating
{
    if (self.shouldAnimate == YES) {
        return;
    }
    
    self.shouldAnimate = YES;
    [self changeToNormalImage];
}

- (void)changeToNormalImage
{
    UIImage *image;
    if (self.reuseIdentifier == HUMMapViewControllerAnnotationGreen) {
        image = [UIImage imageNamed:@"HUMPlacemarkSmall"];
    } else if (self.reuseIdentifier == HUMMapViewControllerAnnotationGrey) {
        image = [UIImage imageNamed:@"HUMPlacemarkSmallGrey"];
    }
    self.image = image;

    if (self.shouldAnimate == NO) {
        return;
    }

    [self performSelector:@selector(changeToTalkingImage)
               withObject:nil
               afterDelay:0.2];
}

- (void)changeToTalkingImage
{
    if (self.shouldAnimate == NO) {
        return;
    }

    UIImage *image;
    if (self.reuseIdentifier == HUMMapViewControllerAnnotationGreen) {
        image = [UIImage imageNamed:@"HUMPlacemarkSmallTalking"];
    } else if (self.reuseIdentifier == HUMMapViewControllerAnnotationGrey) {
        image = [UIImage imageNamed:@"HUMPlacemarkSmallGreyTalking"];
    }
    self.image = image;

    [self performSelector:@selector(changeToNormalImage)
               withObject:nil
               afterDelay:0.2];
}

- (void)stopAnimating
{
    self.shouldAnimate = NO;
}

@end
