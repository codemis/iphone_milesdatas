#import "MDRouteVC.h"
#import <MapKit/MapKit.h>
#define EDGE_INSETS UIEdgeInsetsMake(20, 20, 20, 20)
#define MAP_ANNOTATIONS_COUNT 2
MKMapRect coordinateRegionForCoordinates(CLLocationCoordinate2D *coords,
                                         NSUInteger coordCount) {
    MKMapRect r = MKMapRectNull;
    for (NSUInteger i=0; i<coordCount; ++i) {
        MKMapPoint p = MKMapPointForCoordinate(coords[i]);
        r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0));
    }
    return r;
}
@interface MDRouteVC () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MDRouteVC
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
-(CLLocationCoordinate2D)locationWithLatitude:(double)latitude
                                withLongitude:(double)longitude {
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    return location;
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
    CLLocationCoordinate2D *coords = malloc(MAP_ANNOTATIONS_COUNT *
                                            sizeof(CLLocationCoordinate2D));
    CLLocation *startLocation =
      [[CLLocation alloc] initWithLatitude:[self.record[@"start_lat"] doubleValue]
                                 longitude:[self.record[@"start_long"] doubleValue]];
    coords[0] = startLocation.coordinate;
    NSString *startSubtitle =
      [self formatOdometer:[self odometer:self.record[@"start_odometer"]]];
    MKPointAnnotation *startPoint =
      [self addPinToMapAtLocation:startLocation.coordinate
                        withTitle:self.record[@"start_location"]
                     withSubtitle:startSubtitle];
    [self.mapView selectAnnotation:startPoint animated:YES];
    CLLocation *stopLocation =
      [[CLLocation alloc] initWithLatitude:[self.record[@"stop_lat"] doubleValue]
                   longitude:[self.record[@"stop_long"] doubleValue]];
    coords[1] = stopLocation.coordinate;
    NSString *stopSubtitle =
      [self formatOdometer:[self odometer:self.record[@"stop_odometer"]]];
    [self addPinToMapAtLocation:stopLocation.coordinate
                      withTitle:self.record[@"stop_location"]
                   withSubtitle:stopSubtitle];
    [self.mapView setVisibleMapRect:
      coordinateRegionForCoordinates(coords,MAP_ANNOTATIONS_COUNT)
                        edgePadding:EDGE_INSETS animated:NO];
    [self overlayRouteFrom:startLocation to:stopLocation];
    free(coords);
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
-(MKPolyline *)routeFromLocation:(CLLocation *)startLocation
                      toLocation:(CLLocation *)stopLocation {
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startLocation.coordinate
                                               addressDictionary:nil];
    MKPlacemark *stopPlacemark = [[MKPlacemark alloc] initWithCoordinate:stopLocation.coordinate
                                              addressDictionary:nil];
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:stopPlacemark];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions =
      [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:
      ^(MKDirectionsResponse *response, NSError *error) {
          if (!error) {
              MKRoute *route = response.routes[0];
              for(MKRouteStep *routeStep in route.steps){
                  NSLog(@"Latitude: %g longitude: %g",
                        routeStep.polyline.coordinate.latitude,
                        routeStep.polyline.coordinate.longitude);
              }
          }
       }
     ];
    return nil;
}
-(void)overlayRouteFrom:(CLLocation *)fromLocation to:(CLLocation *)toLocation {
    MKPlacemark   *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromLocation.coordinate
                                                       addressDictionary:nil];
    MKPlacemark *toPlacemark =
      [[MKPlacemark alloc] initWithCoordinate:toLocation.coordinate
                            addressDictionary:nil];
    MKMapItem *fromMapItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toMapItem = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    directionsRequest.source      = fromMapItem;
    directionsRequest.destination = toMapItem;
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions =
      [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:
      ^(MKDirectionsResponse *response, NSError *error) {
          if (!error) {
              MKRoute *route = response.routes[0];
              CLLocationCoordinate2D *coords = malloc(route.steps.count *
                                                      sizeof(CLLocationCoordinate2D));
              NSUInteger coordIndex = 0;
              for(MKRouteStep *routeStep in route.steps){
                  coords[coordIndex] = routeStep.polyline.coordinate;
                  coordIndex++;
              }
              [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords
                                                                     count:route.steps.count]];
              free(coords);
          }
    }];
}
@end
