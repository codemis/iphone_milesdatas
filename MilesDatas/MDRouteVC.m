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
-(MKPointAnnotation *)addPinToMapAtLocation:(CLLocationCoordinate2D)location
                                  withTitle:(NSString *)title
                               withSubtitle:(NSString *)subtitle {
    MKPointAnnotation *point = MKPointAnnotation.new;
    point.coordinate = location;
    point.title = title;
    point.subtitle = subtitle;
    [self.mapView addAnnotation:point];
    return point;
}
-(CLLocationCoordinate2D)locationWithLatitude:(double)latitude withLongitude:(double)longitude {
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    return location;
}
-(NSString *)formatOdometer:(NSNumber *)odometer {
    NSNumberFormatter *formatter = NSNumberFormatter.new;
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [NSString stringWithFormat:@"Odometer: %@",[formatter stringFromNumber:odometer]];
}
-(NSNumber *)odometer:(NSString *)reading {
    return [NSNumber numberWithDouble:[reading doubleValue]];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    CLLocationCoordinate2D startLocation =
      [self locationWithLatitude:[self.record[@"start_lat"] doubleValue]
                   withLongitude:[self.record[@"start_long"] doubleValue]];
    MKCoordinateRegion viewRegion =
      MKCoordinateRegionMakeWithDistance(
        startLocation,0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:[self.mapView regionThatFits:viewRegion]
                   animated:YES];
    NSString *startSubtitle = [self formatOdometer:[self odometer:self.record[@"start_odometer"]]];
    MKPointAnnotation *startPoint = [self addPinToMapAtLocation:startLocation
                                                 withTitle:self.record[@"start_location"]
                                              withSubtitle:startSubtitle];
    [self.mapView selectAnnotation:startPoint animated:YES];
    CLLocationCoordinate2D stopLocation =
    [self locationWithLatitude:[self.record[@"stop_lat"] doubleValue]
                 withLongitude:[self.record[@"stop_long"] doubleValue]];
    NSString *stopSubtitle = [self formatOdometer:[self odometer:self.record[@"stop_odometer"]]];
    [self addPinToMapAtLocation:stopLocation
                      withTitle:self.record[@"stop_location"]
                   withSubtitle:stopSubtitle];
}
@end
