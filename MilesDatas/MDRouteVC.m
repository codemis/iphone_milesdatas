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
@interface MDRouteVC ()
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
    CLLocationCoordinate2D startLocation =
      [self locationWithLatitude:[self.record[@"start_lat"] doubleValue]
                   withLongitude:[self.record[@"start_long"] doubleValue]];
    coords[0] = startLocation;
    NSString *startSubtitle =
      [self formatOdometer:[self odometer:self.record[@"start_odometer"]]];
    MKPointAnnotation *startPoint =
      [self addPinToMapAtLocation:startLocation
                        withTitle:self.record[@"start_location"]
                     withSubtitle:startSubtitle];
    [self.mapView selectAnnotation:startPoint animated:YES];
    CLLocationCoordinate2D stopLocation =
    [self locationWithLatitude:[self.record[@"stop_lat"] doubleValue]
                 withLongitude:[self.record[@"stop_long"] doubleValue]];
    coords[1] = stopLocation;
    NSString *stopSubtitle =
      [self formatOdometer:[self odometer:self.record[@"stop_odometer"]]];
    [self addPinToMapAtLocation:stopLocation
                      withTitle:self.record[@"stop_location"]
                   withSubtitle:stopSubtitle];
    [self.mapView setVisibleMapRect:
      coordinateRegionForCoordinates(coords,MAP_ANNOTATIONS_COUNT)
                        edgePadding:EDGE_INSETS animated:NO];
    free(coords);
}
@end
