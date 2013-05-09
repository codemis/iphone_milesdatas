#import "MDMileageTableVC.h"
#import "MDMileageShowTableVC.h"

@interface MDMileageTableVC () <NSURLConnectionDataDelegate>
@property (nonatomic, readonly) NSInteger recordCount;
@property (nonatomic, strong) NSMutableData *jsonResponse;
@property (nonatomic, strong) NSArray *records;
@end

@implementation MDMileageTableVC

- (NSInteger) recordCount {
    return self.records.count;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.jsonResponse = NSMutableData.new;
    NSURL *url = [NSURL URLWithString:@"http://blooming-wave-3501.herokuapp.com/records.json"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.recordCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Record"
                                                            forIndexPath:indexPath];
    NSDictionary *record = (NSDictionary *) self.records[indexPath.row];
    NSDateFormatter *dateFormatter = NSDateFormatter.new;
    //2013-05-07T03:56:30Z
    //TODO: Clean up and make static
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *creationDate = [dateFormatter dateFromString:record[@"created_at"]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *prettyCreationDate = [dateFormatter stringFromDate:creationDate];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", prettyCreationDate, record[@"car"]];
    cell.detailTextLabel.text = record[@"reason"];
    return cell;
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
    self.records = [NSJSONSerialization JSONObjectWithData:self.jsonResponse
                                                   options:0
                                                     error:&error];
    if (error) {
        NSLog(@"We have an error!");
    }else{
        [self.tableView reloadData];
    }
}
#pragma mark - Segue methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    MDMileageShowTableVC *mileageShowVC = segue.destinationViewController;
    mileageShowVC.record = (NSDictionary *) self.records[self.tableView.indexPathForSelectedRow.row];
}
@end
