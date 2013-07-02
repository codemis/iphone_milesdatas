#import "MDMileageTableVC.h"
#import "MDMileageShowTableVC.h"

@interface MDMileageTableVC () <NSURLConnectionDataDelegate>
@property (nonatomic, readonly) NSInteger recordCount;
@property (nonatomic, strong) NSMutableData *jsonResponse;
@property (nonatomic, strong) NSMutableArray *records;
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    NSString *reason = record[@"reason"];
    cell.detailTextLabel.text =  [reason substringToIndex:MIN(50, reason.length)];
    //FIXME: Untruncated causes cell oddities
    return cell;
}
-(void)  tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *urlString = [NSString stringWithFormat:@"http://blooming-wave-3501.herokuapp.com/records/%@.json",
                               self.records[indexPath.row][@"id"]];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setValue:@"application/json"
          forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@"application/json"
          forHTTPHeaderField:@"accept"];
        urlRequest.HTTPMethod = @"DELETE";
        [self.records removeObjectAtIndex:indexPath.row];
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
    if (self.jsonResponse.length > 0) //Rails sends no content on delete
        self.records = [[NSJSONSerialization JSONObjectWithData:self.jsonResponse
                                                   options:0
                                                     error:&error] mutableCopy];
    if (error) NSLog(@"We have an error!");
    else [self.tableView reloadData];
}
#pragma mark - Segue methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTrip"]) {
        MDMileageShowTableVC *mileageShowVC = segue.destinationViewController;
        mileageShowVC.record = (NSDictionary *) self.records[self.tableView.indexPathForSelectedRow.row];
    }
}
@end
