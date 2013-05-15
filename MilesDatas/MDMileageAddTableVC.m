#import "MDMileageAddTableVC.h"
@interface MDMileageAddTableVC () <NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startingLocation;
@property (weak, nonatomic) IBOutlet UITextField *startingOdometer;
@property (weak, nonatomic) IBOutlet UITextField *stoppingLocation;
@property (weak, nonatomic) IBOutlet UITextField *stoppingOdometer;
@property (weak, nonatomic) IBOutlet UITextView *reason;
@property (nonatomic, strong) NSMutableData *jsonResponse;
@property (weak, nonatomic) IBOutlet UITextField *car;
@end
//{record: {}}
@implementation MDMileageAddTableVC
- (IBAction)addTrip:(id)sender
{
    self.jsonResponse = NSMutableData.new;
    NSDictionary *newTrip = @{@"record":
                                  @{
                                      @"start_location": self.startingLocation.text,
                                      @"start_odometer": self.startingOdometer.text,
                                      @"stop_location": self.stoppingLocation.text,
                                      @"stop_odometer": self.stoppingOdometer.text,
                                      @"reason": self.reason.text,
                                      @"car": self.car.text
                                    }
                              };
    NSError *error;
    NSData *jsonRecord = [NSJSONSerialization dataWithJSONObject:newTrip
                                                         options:0
                                                           error:&error];
    if (error) {
        NSLog(@"You have an error buddy!");
    }else{
        NSURL *url = [NSURL URLWithString:@"http://blooming-wave-3501.herokuapp.com/records.json"];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setValue:@"application/json"
          forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@"application/json"
          forHTTPHeaderField:@"accept"];
        urlRequest.HTTPMethod = @"POST";
        urlRequest.HTTPBody = jsonRecord;
        [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    }
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
    NSError *error;
    NSArray *serverResponse = [NSJSONSerialization JSONObjectWithData:self.jsonResponse
                                                              options:0
                                                                error:&error];
    if (error) {
        NSLog(@"We have an error!");
    }else{
        NSLog(@"%@", serverResponse);
    }
}
@end
