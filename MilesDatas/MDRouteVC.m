#import "MDRouteVC.h"
#import <MapKit/MapKit.h>

@interface MDRouteVC () <MKMapViewDelegate,NSURLConnectionDataDelegate>
@property(weak,nonatomic)IBOutlet MKMapView *mapView;
@property(strong,nonatomic)NSMutableData *jsonResponse;
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
-(void)getGoogleRouteFrom:(CLLocation *)start to:(CLLocation *)stop {
    self.jsonResponse = NSMutableData.new;
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f"
    "&destination=%f,%f&sensor=true",start.coordinate.latitude,start.coordinate.longitude,stop.coordinate.latitude,
                     stop.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    CLLocation *startLocation =
      [[CLLocation alloc] initWithLatitude:[self.record[@"start_lat"] doubleValue]
                                 longitude:[self.record[@"start_long"] doubleValue]];
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
    NSString *stopSubtitle =
      [self formatOdometer:[self odometer:self.record[@"stop_odometer"]]];
    [self addPinToMapAtLocation:stopLocation.coordinate
                      withTitle:self.record[@"stop_location"]
                   withSubtitle:stopSubtitle];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self getGoogleRouteFrom:startLocation to:stopLocation];
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
#pragma mark - NSURL Delegate methods
- (void) connection:(NSURLConnection *)connection
     didReceiveData:(NSData *)data
{
    [self.jsonResponse appendData:data];
}
- (void) connection:(NSURLConnection *)connection
 didReceiveResponse:(NSURLResponse *)response
{
    self.jsonResponse.length = 0;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *records = NSMutableDictionary.new;
    NSError *error;
    if (self.jsonResponse.length > 0) //Rails sends no content on delete
        records = [[NSJSONSerialization JSONObjectWithData:self.jsonResponse
                                                        options:0
                                                          error:&error] mutableCopy];
    if (error) NSLog(@"We have an error!");
    else [self decodePolyLine:records[@"routes"][0][@"overview_polyline"][@"points"]];
}
-(void)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:encodedStr.length];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, encoded.length)];
    NSInteger len = encoded.length;
    NSInteger index = 0;
    NSInteger lat=0;
    NSInteger lng=0;
    CLLocationCoordinate2D *coords = malloc(len * sizeof(CLLocationCoordinate2D));
    NSUInteger coordIndex = 0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocationCoordinate2D coord;
        coord.latitude = [latitude floatValue];
        coord.longitude = [longitude floatValue];
        coords[coordIndex] = coord;
        coordIndex++;
    }
    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords
                                                           count:coordIndex]];
    free(coords);
}
@end