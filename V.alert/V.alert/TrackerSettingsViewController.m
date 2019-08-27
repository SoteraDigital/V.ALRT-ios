#import "TrackerSettingsViewController.h"
#import "Constants.h"
#import "SharedData.h"

@interface TrackerSettingsViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *nectActionButton;
- (IBAction)checkBoxActionButton:(UIButton *)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)soundLineButton:(id)sender;
- (IBAction)vibratelineButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *toggleTheTrackerLabel;
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UILabel *vibrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackerLabel;

@end

@implementation TrackerSettingsViewController
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
    NSUInteger languageSelction = [DEFAULTS integerForKey:@"language"];
    if (languageSelction >0)
    {
        [self.nectActionButton setHidden:YES];
    }
    _trackerTitle.textColor = BRANDING_COLOR;
    _trackerBar.backgroundColor = BRANDING_COLOR;
    self.toggleTheTrackerLabel.text = NSLocalizedString(@"TogelTheTracker", @"Toggel text");
    self.soundLabel.text = NSLocalizedString(@"Sound", @"Sound");
    self.vibrateLabel.text = NSLocalizedString(@"Vibrate", @"Vibrate");
    self.lightLabel.text = NSLocalizedString(@"Light", @"Light");
    self.trackerLabel.text = NSLocalizedString(@"Tracker", @"Tracker");
    
    [self loadThePrefferedUserSetting];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //alloc the obj for dbconnect class
    _date=[[SharedData sharedConstants] currentDate];
    dConnect = [[dbConnect alloc]init];
}

// Load the previous user preferences
-(void)loadThePrefferedUserSetting
{
    
    ((UIButton*)[self.view viewWithTag:10]).selected =  [DEFAULTS boolForKey:DEVICE_TRAKING_SOUND];
    ((UIButton*)[self.view viewWithTag:11]).selected =  [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// CheckBox get Clicked
- (IBAction)checkBoxActionButton:(UIButton *)sender
{
    if (sender.tag == 10)
    { //Sound button clicked
        if ([DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT] && (!sender.selected))
        {
            [self triggerAlert:(int)sender.tag];
        }
        else
        {
            sender.selected = !sender.selected;
            [DEFAULTS setBool:sender.selected forKey:DEVICE_TRAKING_SOUND];
            if(sender.selected ==YES)
            {
                //add the status to the database dat device is in phone is silent mode.
                [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Tracker loud tone on", nil)];
            }
            else
            {
                //add the status to the database dat device is in phone is silent mode.
                [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Tracker loud tone off", nil)];
            }
        }
    }
    else if (sender.tag == 11)
    {
        //Vibrate button clicked
        sender.selected = !sender.selected;
        [DEFAULTS setBool: sender.selected forKey:DEVICE_TRAKING_VIBRATION];
        if(sender.selected ==YES)
        {
            //add the status to the database dat device is in phone is silent mode.
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Tracker vibrate on", nil)];
        }
        else
        {
            //add the status to the database dat device is in phone is silent mode.
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Tracker vibrate off", nil)];
        }
        
    }
    
    [DEFAULTS synchronize];
    [DEFAULTS setBool:([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] || [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION]) forKey:IS_DEVICE_TRAKING_FEATURE_ON];
    [DEFAULTS synchronize];
    
}

// Trigger Alert View With Button Tag number
-(void)triggerAlert:(int)tagId
{
    
    NSString *alertMassage = NSLocalizedString(@"Tracker_silent", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertMassage delegate:self cancelButtonTitle:NSLocalizedString(@"Tracker_cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Tracker_accept", @"Accept"), nil];
    alert.tag = tagId;
    [alert show];
}

#pragma mark - AlertView Delegate mathods
-(void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10)
    {  // Tracker Tone get Clicked
        if (buttonIndex == 1)
        { // Accept Button clicked
            ((UIButton*)[self.view viewWithTag:alertView.tag]).selected = YES;
            [DEFAULTS setBool:NO forKey:DISABLE_PHONEAPPLICATION_SILENT];
            if (alertView.tag == 10)
            {
                [DEFAULTS setBool: YES forKey:DEVICE_TRAKING_SOUND];
                
                //add the status to the database dat device is in phone is silent mode and tracker sound is on.
                [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Tracker loud tone on", nil)];
                [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Application silent mode off", nil)];
            }
        }
        else
        { // Decline Button clicked
            ((UIButton*)[self.view viewWithTag:alertView.tag]).selected = NO;
        }
        
        [DEFAULTS synchronize];
        [DEFAULTS setBool:([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] || [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION]) forKey:IS_DEVICE_TRAKING_FEATURE_ON];
        [DEFAULTS synchronize];
    }
}




// Go Back Button Clicked
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
- (IBAction)soundLineButton:(id)sender {
    [self checkBoxActionButton:(id)[self.view viewWithTag:10]];
}

- (IBAction)vibratelineButton:(id)sender {
    [self checkBoxActionButton:(id)[self.view viewWithTag:11]];
}
@end
