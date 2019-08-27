#import "CongratulationsViewController.h"
#import "Constants.h"
#import "congrpopupView.h"
#import "NSString+URLEncoding.h"
#import "SharedData.h"
#import "ContactsData.h"
#import "logfile.h"

#import <CoreLocation/CoreLocation.h>
@interface CongratulationsViewController ()

@end

@implementation CongratulationsViewController
@synthesize btnActionDoneSetUp,ObjBLEConnection;
@synthesize lblTitle,lblTitle1,lblTermsandConditionsDescription;

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
    locationManager = [[CLLocationManager alloc] init];
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        //[locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    [btnActionDoneSetUp setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateNormal];
    if(![LANGUAGE isEqualToString:@"en"])
    {
        [btnActionDoneSetUp setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0,0 )];
        
    }
    
    //user feedback chnages starts
    lblTitle.text = NSLocalizedString(@"cong_title", nil);
    lblTitle.textColor = BRANDING_COLOR;
    lblTitle1.text = NSLocalizedString(@"cong_title1", nil);
    [lblTitle1 setTextAlignment:NSTextAlignmentLeft];
    lblTitle1.font = [UIFont boldSystemFontOfSize:15];
    lblTitle.text = NSLocalizedString(@"cong_title", nil);
    lblTitle1.text = NSLocalizedString(@"cong_title1", nil);
    [lblTitle1 setTextAlignment:NSTextAlignmentLeft];
    lblTitle1.font = [UIFont boldSystemFontOfSize:15];
    
    NSString *str=[NSString stringWithFormat:@"%@",NSLocalizedString(@"home_termsDescription", nil)];
    NSArray *arr=[str componentsSeparatedByString:@"."];
    NSString *str1=[arr objectAtIndex:0];
    NSString *str2=[arr objectAtIndex:1];
    NSString *str3=[arr objectAtIndex:2];
    NSString *oriStr=[NSString stringWithFormat:@"%@.",str1];
    
    primaryLabel=[[UILabel alloc] initWithFrame:CGRectMake(23, 170, 278, 72)];
    [primaryLabel setTextColor:[UIColor colorWithRed:(80/255.f) green:(74/255.f) blue:(103/255.f) alpha:1.0f]];
    [primaryLabel setBackgroundColor:[UIColor clearColor]];
    NSString *oristr2=[NSString stringWithFormat:@"%@.%@.",str2,str3];
    primaryLabel.text=oristr2;
    [primaryLabel setNumberOfLines:4];
    [primaryLabel setLineBreakMode:NSLineBreakByWordWrapping];
    primaryLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
    primaryLabel.font=[UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:primaryLabel];
    [primaryLabel setHidden:NO];
    
    lblTermsandConditionsDescription.text = oriStr;
    [lblTermsandConditionsDescription setTextColor:[UIColor colorWithRed:(80/255.f) green:(74/255.f) blue:(103/255.f) alpha:1.0f]];
    [lblTermsandConditionsDescription setTextAlignment:NSTextAlignmentLeft];
    lblTermsandConditionsDescription.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [lblTermsandConditionsDescription setNumberOfLines:3];
    [lblTermsandConditionsDescription setLineBreakMode:NSLineBreakByWordWrapping];
    
    //user feedback changes ends
    smsArray = [[NSMutableArray alloc]init];
    //Check the message selected contact
    for(int i=0;i<[[SharedData sharedConstants].arrEnabledTexts count];i++)
    {
        
        if([[[SharedData sharedConstants].arrEnabledTexts objectAtIndex:i] isEqualToString:@"1"])
        {
            [smsArray addObject:[[ContactsData sharedConstants].contactNumbers objectAtIndex:i]];
        }
    }
    
    //creating object for Home view
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    
    ObjHomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    ObjHomeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ObjHomeViewController.ObjBLEConnection = ObjBLEConnection;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 }

/*!
 *  @method didActionDoneSetUp:
 *  @discussion action done setup once saw the congratulation view,popup the view to ask user to send sms.
 */
- (IBAction)didActionDoneSetUp:(id)sender
{
    
    if([smsArray count]>0 && [SharedData sharedConstants].isReachable)
    {
        [[congrpopupView sharedInstance] didConfirmationViewLoad:self.view andConfirmationViewTitle:NSLocalizedString(@"sms_title", nil)  andConfirmationViewContent:NSLocalizedString(@"sms_desc", nil) andConfirmationViewCallback:^(BOOL onConfirm) {
            if(onConfirm)
            {
                if([self->smsArray count]>0)
                {
                    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
                    self->HUD = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:self->HUD];
                    // Regiser for HUD callbacks so we can remove it from the window at the right time
                    self->HUD.delegate = self;
                    self->HUD.labelText = NSLocalizedString(@"send_sms", nil);
                    // Show the HUD while the provided method executes in a new thread
                    [self->HUD show:YES];

                    [self sendFirstSms];
                }
                else
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self presentViewController:self->ObjHomeViewController animated:YES completion:nil];
                    }];

                }
            }
            else
            {
                //set default for first flow
                [DEFAULTS setInteger:10 forKey:@"language"];
                [DEFAULTS synchronize];
                [DEFAULTS setValue:@"set" forKey:@"devicesDone"];
                [DEFAULTS setInteger:10 forKey:INITIAL_SETUP];
                [self presentViewController:self->ObjHomeViewController animated:YES completion:nil];
            }
        }];
    }
    else
    {
        //set default for first flow
        [DEFAULTS setInteger:10 forKey:@"language"];
        [DEFAULTS synchronize];
        [DEFAULTS setValue:@"set" forKey:@"devicesDone"];
        [DEFAULTS setInteger:10 forKey:INITIAL_SETUP];
        [self presentViewController:ObjHomeViewController animated:YES completion:nil];
    }
}

/*!
 *  @method sendFirstSms:
 *  @discussion send sms to selected contacts in contact view once click send.
 */
-(void)sendFirstSms
{
    NSString *urlString = [NSString stringWithFormat:@"%@VSNCloudApp/rest/vsn/notification/message",VOIP_SMS_CALL_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString* Msg = NSLocalizedString(@"sms_desc", nil);
    NSString* sepertatedString = [smsArray componentsJoinedByString:@","];
    
    NSString *bodyString = [NSString stringWithFormat:@"serial_no=%@&numberOfSmsReceverOrEmergencyNumberList=%@&messageBodyContent=%@ %@, %@&macId=%@",
                            [SharedData sharedConstants].activeSerialno,
                            [sepertatedString urlEncodeUsingEncoding:NSUTF8StringEncoding],
                            NSLocalizedString(@"valrt_from",nil),
                            [DEFAULTS objectForKey:@"userName"],
                            [Msg urlEncodeUsingEncoding:NSUTF8StringEncoding],
                            [SharedData sharedConstants].activeIdentifier];
    
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (!error)
        {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"received data in getCapabilityToken:%@", newStr);
            NSString*respStr = [NSString stringWithFormat:@"\n received data in getCapabilityToken:%@",newStr];
            [[logfile logfileObj]  writeLog:respStr];
            
            if(httpResponse.statusCode !=200)
            {
                self->failedFirstSmsRetryCount++;
                if(self->failedFirstSmsRetryCount <3)
                {
                    [self sendFirstSms];
                    
                }
                else
                {
                    /* Write value to the database to tell the sms sent is failure */
                    NSString *_date=[[SharedData sharedConstants] currentDate];
                    self->dConnect = [[dbConnect alloc]init];
                    //insert the device connection status
                    [self->dConnect addStatus:[NSString stringWithFormat:@"%@",_date]
                                      bleName:@"V.ALRT"
                                   bleAddress:@"Address"
                                    bleStatus:NSLocalizedString(@"sms_sent_failure", nil)];
                    
                    [self->HUD hide:YES];
                    //set default for first flow
                    [DEFAULTS setInteger:10 forKey:@"language"];
                    [DEFAULTS synchronize];
                    [DEFAULTS setValue:@"set" forKey:@"devicesDone"];
                    [DEFAULTS setInteger:10 forKey:INITIAL_SETUP];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self presentViewController:self->ObjHomeViewController animated:YES completion:nil];
                    }];
                    
                }
            }
            else
            {
                /* Write value to the database to tell the sms sent is succes */
                NSString *_date=[[SharedData sharedConstants] currentDate];
                self->dConnect = [[dbConnect alloc]init];
                //insert the device connection status
                [self->dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"sms_sent_success", nil)];
                
                [self->HUD hide:YES];
                //set default for first flow
                [DEFAULTS setInteger:10 forKey:@"language"];
                [DEFAULTS synchronize];
                [DEFAULTS setValue:@"set" forKey:@"devicesDone"];
                [DEFAULTS setInteger:10 forKey:INITIAL_SETUP];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self presentViewController:self->ObjHomeViewController animated:YES completion:nil];
                }];
            }
        }
        else
        {
            /* Write value to the database to tell the sms sent is failure */
            NSString *_date=[[SharedData sharedConstants] currentDate];
            self->dConnect = [[dbConnect alloc]init];
            //insert the device connection status
            [self->dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"sms_sent_failure", nil)];
            [self->HUD hide:YES];
            [DEFAULTS setValue:@"set" forKey:@"devicesDone"];
            [DEFAULTS setInteger:10 forKey:INITIAL_SETUP];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:self->ObjHomeViewController animated:YES completion:nil];
            }];
        }
    }];
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
