#import "MDMileageShowTableVC.h"
#import "MDRouteVC.h"
@interface MDMileageShowTableVC ()
@property (weak, nonatomic) IBOutlet UILabel *car;
@property (weak, nonatomic) IBOutlet UILabel *startLocation;
@property (weak, nonatomic) IBOutlet UILabel *startOdometer;
@property (weak, nonatomic) IBOutlet UILabel *stopLocation;
@property (weak, nonatomic) IBOutlet UILabel *stopOdometer;
@property (weak, nonatomic) IBOutlet UITextView *reason;
@end
@implementation MDMileageShowTableVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.car.text = self.record[@"car"];
    self.startLocation.text = self.record[@"start_location"];
    self.startOdometer.text = self.record[@"start_odometer"];
    self.stopLocation.text = self.record[@"stop_location"];
    self.stopOdometer.text = self.record[@"stop_odometer"];
    self.reason.text = self.record[@"reason"];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRoute"]) {
        MDRouteVC *routeVC = segue.destinationViewController;
        routeVC.record = self.record;
    }
}
@end