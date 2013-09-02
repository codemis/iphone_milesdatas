#import "MDRouteVC.h"
#import <MapKit/MapKit.h>

@interface MDRouteVC () <MKMapViewDelegate>
@property(weak,nonatomic)IBOutlet MKMapView *mapView;
@end

@implementation MDRouteVC
-(void)addPinToMapAtLocation:(CLLocationCoordinate2D)location
                   withTitle:(NSString *)title
                withSubtitle:(NSString *)subtitle
                    selected:(BOOL)selected{
    MKPointAnnotation *point = MKPointAnnotation.new;
    point.coordinate = location;
    point.title = title;
    point.subtitle = subtitle;
    [self.mapView addAnnotation:point];
    if (selected) [self.mapView selectAnnotation:point animated:YES];
}
-(NSString *)formatOdometer:(NSNumber *)odometer {
    NSNumberFormatter *formatter = NSNumberFormatter.new;
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [NSString stringWithFormat:@"Odometer: %@",
            [formatter stringFromNumber:odometer]];
}
-(NSNumber *)odometer:(NSString *)reading {
    return [NSNumber numberWithDouble:[reading doubleValue]];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    CLLocation *startLocation =
      [[CLLocation alloc] initWithLatitude:[self.record[@"start_lat"] doubleValue]
                                 longitude:[self.record[@"start_long"] doubleValue]];
    NSString *startSubtitle =
      [self formatOdometer:[self odometer:self.record[@"start_odometer"]]];
    [self addPinToMapAtLocation:startLocation.coordinate
                      withTitle:self.record[@"start_location"]
                   withSubtitle:startSubtitle
                       selected:YES];
    CLLocation *stopLocation =
      [[CLLocation alloc] initWithLatitude:[self.record[@"stop_lat"] doubleValue]
                                 longitude:[self.record[@"stop_long"] doubleValue]];
    NSString *stopSubtitle =
      [self formatOdometer:[self odometer:self.record[@"stop_odometer"]]];
    [self addPinToMapAtLocation:stopLocation.coordinate
                      withTitle:self.record[@"stop_location"]
                   withSubtitle:stopSubtitle
                       selected:NO];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self addOverlayForRouteFromLocation:startLocation toLocation:stopLocation];
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView
           rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]
                                        initWithPolyline:(MKPolyline *)overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 1.0;
        return renderer;
    }
    return nil;
}
-(void)addOverlayForRouteFromLocation:(CLLocation *)startLocation
                           toLocation:(CLLocation *)stopLocation {
    MKPlacemark *startPlacemark =
      [[MKPlacemark alloc] initWithCoordinate:startLocation.coordinate
                            addressDictionary:nil];
    MKPlacemark *stopPlacemark =
      [[MKPlacemark alloc] initWithCoordinate:stopLocation.coordinate
                            addressDictionary:nil];
    MKDirectionsRequest *directionsRequest = MKDirectionsRequest.new;
    directionsRequest.source =
      [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    directionsRequest.destination =
      [[MKMapItem alloc] initWithPlacemark:stopPlacemark];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = NO;
    MKDirections *directions =
      [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:
      ^(MKDirectionsResponse *response, NSError *error) {
          if (!error) {
              MKRoute *route = response.routes[0];
              [self.mapView addOverlay:route.polyline];
          }
       }
     ];
}
@end