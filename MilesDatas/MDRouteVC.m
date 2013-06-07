#import "MDRouteVC.h"
#import <MapKit/MapKit.h>
#define METERS_PER_MILE 1609.344
@interface MDRouteVC ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MDRouteVC
-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.record[@"start_lat"] doubleValue];
    zoomLocation.longitude = [self.record[@"start_long"] doubleValue];
    MKCoordinateRegion viewRegion =
      MKCoordinateRegionMakeWithDistance(
        zoomLocation,0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:[self.mapView regionThatFits:viewRegion]
                   animated:YES];
    MKPointAnnotation *point = MKPointAnnotation.new;
    point.coordinate = zoomLocation;
    point.title = self.record[@"start_location"];
    //TODO: format odometer
    point.subtitle = [NSString stringWithFormat:@"Odometer: %@",self.record[@"start_odometer"]];
    [self.mapView addAnnotation:point];
}
@end
