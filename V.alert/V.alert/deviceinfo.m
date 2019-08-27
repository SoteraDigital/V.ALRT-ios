#import "deviceinfo.h"
#import "Customcell.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
@interface deviceinfo ()

@end

@implementation deviceinfo
@synthesize webAgreementDescription,btnBack,imgViewCheckBox,lblTitle;
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
	
    [deviceInfoTbl setBackgroundColor:[UIColor clearColor]];
    deviceInfoTbl.scrollEnabled = NO;
    
    //Button back
    [btnBack setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    //[btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     lblTitle.text = NSLocalizedString(@"helpInfo_ProductinfoTitle", nil);
    lblTitle.textColor = BRANDING_COLOR;
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    
    NSString*htmlString;

    if([LANGUAGE isEqualToString:@"en"])
    {
#ifdef HNALERT
        htmlString = [NSString stringWithFormat:@"<html><body style='line-height:20px;background-color:transparent;color:#504a67'>V.ALRT information<br>Model Number:  VSN 400</br>Application version: %@<br>For more information visit us at</br><a href='http://vsnmobil.com/' style='color:#504a67'>http://vsnmobil.com/</a></body></html>",VERSION];
#else
        htmlString = [NSString stringWithFormat:@"<html><body style='line-height:20px;background-color:transparent;color:#504a67'>V.ALRT information<br>Model Number:  VSN 400</br>Application version: %@<br>For more information visit us at</br><a href='http://vsnmobil.com/' style='color:#504a67'>http://vsnmobil.com/</a></body></html>",VERSION];
#endif
    }
    else
    {
#ifdef HNALERT
        htmlString = [NSString stringWithFormat:@"<html><body style='line-height:20px;color:#504a67'><p>Información del V.ALRT<br>Modelo: VSN 400<br>Versión de la Aplicación:%@<br>Para más información visítenos en<br><a href='http://vsnmobil.com/' style='color:#504a67'>http://vsnmobil.com/</a></body></html>",VERSION];
#else
        htmlString = [NSString stringWithFormat:@"<html><body style='line-height:20px;color:#504a67'><p>Información del V.ALRT<br>Modelo: VSN 400<br>Versión de la Aplicación:%@<br>Para más información visítenos en<br><a href='http://vsnmobil.com/' style='color:#504a67'>http://vsnmobil.com/</a></body></html>",VERSION];
#endif

        lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        lblTitle.font = [UIFont boldSystemFontOfSize:17.0];
        lblTitle.numberOfLines=0;
        [lblTitle sizeToFit];
        
        
        
    }
    webAgreementDescription.contentMode = UIViewContentModeCenter;
    [webAgreementDescription setOpaque:NO];
    

   NSString *str= [NSString stringWithFormat:@"<font face='HelveticaNeue' size='2'>%@", htmlString];
    webAgreementDescription.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
    webAgreementDescription.layer.cornerRadius=7;
    [webAgreementDescription setClipsToBounds:YES];
    [webAgreementDescription loadHTMLString:str  baseURL:nil];
    
    
    //Load device info in tableview
    deviceInfoArr = [[NSMutableArray alloc]init];
    dbconnectObj = [[dbConnect alloc]init];
    deviceInfoArr =[dbconnectObj fetchDeviceinfo];
    [deviceInfoTbl reloadData];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *requestURL =[request URL];
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"mailto" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) )
    {
        return ![[ UIApplication sharedApplication ] openURL:requestURL];
    }

    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [deviceInfoArr count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
        return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
     Customcell *cell=(Customcell *)[deviceInfoTbl dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[Customcell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
    CALayer* layer = cell.layer;
    [layer setCornerRadius:5.0f];
    [layer setMasksToBounds:YES];
    cell.primaryLabel.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
    cell.secondaryLabel.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
    cell.thirdLabel.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
    cell.devicetxtLabel.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
    cell.serialtxtLabel.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
    cell.sofverLabel.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
    cell.primaryLabel.text =NSLocalizedString(@"product_devicename",nil);
    cell.secondaryLabel.text =NSLocalizedString(@"product_serialnumber", nil);
    cell.thirdLabel.text = NSLocalizedString(@"product_softwareversion", nil);
    cell.devicetxtLabel.text = [[deviceInfoArr objectAtIndex:indexPath.section] valueForKey:@"vname"];
    cell.serialtxtLabel.text = [[deviceInfoArr objectAtIndex:indexPath.section] valueForKey:@"serialno"];
    cell.sofverLabel.text = [[deviceInfoArr objectAtIndex:indexPath.section] valueForKey:@"sofver"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     [deviceInfoTbl deselectRowAtIndexPath:indexPath animated:YES];
 }


//Dismiss the view
- (IBAction)didActionBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
