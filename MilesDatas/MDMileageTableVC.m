#import "MDMileageTableVC.h"

@interface MDMileageTableVC () <NSURLConnectionDataDelegate>
@property (nonatomic, readonly) NSInteger recordCount;
@property (nonatomic, strong) NSMutableData *jsonResponse;
@property (nonatomic, strong) NSArray *records;
@end

@implementation MDMileageTableVC

- (NSInteger) recordCount {
    return 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.jsonResponse = NSMutableData.new;
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/records.json"];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
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
    }
}
@end
