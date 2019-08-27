#import "HistoryViewController.h"
#import "Constants.h"
#import "logfile.h"


@interface HistoryViewController ()

@end

@implementation HistoryViewController
@synthesize btnBackSettings,tableView,historyLogLbl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    historyLogLbl.text=NSLocalizedString(@"help_history", nil);
    historyLogLbl.textColor = BRANDING_COLOR;
    self.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_app_background.png"]];
}
- (IBAction)didActionBackViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    tableView.backgroundColor = [UIColor colorWithRed:218.0/255.0f green:218.0f/255.0f blue:218.0/255.0f alpha:0.85];
    dConnect = [[dbConnect alloc]init];
    recordArray = [[NSMutableArray alloc]init];
    recordArray = [[dConnect fetchTable] mutableCopy];
    [btnBackSettings setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    [tableView reloadData];
    
    if([LANGUAGE isEqualToString:@"en"])
    {
        [historyLogLbl setTextAlignment:NSTextAlignmentCenter];
        
    }
    
}

/* Send log through mail */
-(IBAction)sendLogMail:(id)sender{
    if ( [MFMailComposeViewController canSendMail] )
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate  = self;
        NSData *myNoteData = [NSData dataWithContentsOfFile:[[logfile logfileObj] openLog]];
#ifdef HNALERT
        [controller setSubject:@"Log file for HELP NOW ALERT"];
        [controller addAttachmentData:myNoteData mimeType:@"text/plain" fileName:@"hnalert_log.txt"];
#else
        [controller setSubject:@"Log file for V.ALRT"];
        [controller addAttachmentData:myNoteData mimeType:@"text/plain" fileName:@"valrt_log.txt"];
        [controller setToRecipients:[NSArray arrayWithObjects:@"support@vsnmobil.com",
                                     nil]];
#endif
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSLog (@"mail finished"); // NEVER REACHES THIS POINT.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	
	return  [recordArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell;
    cell = (UITableViewCell *)[tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString*statusStr =[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vstatus"];
    if([statusStr isEqualToString:NSLocalizedString(@"Valrt_off", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Valrt_on", nil)] || [statusStr isEqualToString:NSLocalizedString(@"sms_sent_failure", nil)] || [statusStr isEqualToString:NSLocalizedString(@"sms_sent_success", nil)]|| [statusStr isEqualToString:NSLocalizedString(@"system kill by OS", nil)]|| [statusStr isEqualToString:NSLocalizedString(@"Power up or normal kill by user", nil)]|| [statusStr isEqualToString:NSLocalizedString(@"App upgrade", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Application silent mode on", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Application silent mode off", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Device silent mode off", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Device silent mode on", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Tracker loud tone off", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Tracker loud tone on", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Tracker vibrate on", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Tracker vibrate off", nil)] || [statusStr isEqualToString:NSLocalizedString(@"Tracker vibrate off", nil)] || [statusStr isEqualToString:NSLocalizedString(@"LaunchedForBluetoothRestore", nil)] || [statusStr isEqualToString:NSLocalizedString(@"will restore state", nil)] )
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@,%@",[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vdata"],[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vstatus"]];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@, %@",[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vdata"],[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vname"],[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vaddress"],[[recordArray objectAtIndex:indexPath.row] valueForKey:@"vstatus"]];
    }
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.frame = CGRectMake(10, 10, 308, 100);
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Nueue" size:10];
    [cell.textLabel setTextColor:[UIColor colorWithRed:(80/255.f) green:(74/255.f) blue:(103/255.f) alpha:1.0f]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.textLabel.numberOfLines = 3;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
