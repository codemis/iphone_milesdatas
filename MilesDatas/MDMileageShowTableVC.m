#import "MDMileageShowTableVC.h"
@interface MDMileageShowTableVC ()
@property (weak, nonatomic) IBOutlet UILabel *startLocation;
@property (weak, nonatomic) IBOutlet UILabel *startOdometer;
@property (weak, nonatomic) IBOutlet UILabel *stopLocation;
@property (weak, nonatomic) IBOutlet UILabel *stopOdometer;
@property (weak, nonatomic) IBOutlet UILabel *reason;
@end
@implementation MDMileageShowTableVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.startLocation.text = self.record[@"start_location"];
    self.startOdometer.text = self.record[@"start_odometer"];
    self.stopLocation.text = self.record[@"stop_location"];
    self.stopOdometer.text = self.record[@"stop_odometer"];
    self.reason.text = self.record[@"reason"];
}
@end
