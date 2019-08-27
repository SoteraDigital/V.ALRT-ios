#import "HomeViewController.h"
#import "Constants.h"
#import "ContactsData.h"
#import "SharedData.h"
#import "logfile.h"
#import "ManageDevicesViewController.h"
//#import "SettingsViewController.h"
#import "vsnsettingsviewcontroller.h"
#import "customAlertPopUp.h"
#import "HelpViewController.h"
#import "Reachability.h"
#import "commonnotifyalert.h"
#import "deviceoffscreen.h"

#import "DevicoffpopView.h"
#import "AppDelegate.h"


#import <AVFoundation/AVFoundation.h>
#ifndef __IPHONE_7_0
typedef void (^PermissionBlock)(BOOL granted);
#endif
@interface HomeViewController ()
{
   
}
@property (nonatomic) Reachability *internetReachability;
@end

@implementation HomeViewController

@synthesize lblHomeText,lblNotifyEnableDisableTextsandCalls,lblNotifyPhoneApplicationSilentMode,lblNotifyValertDeviceSilentMode;
@synthesize lblDeviceDashboard,lblDeviceSettings,lblhelp,lblmanageDevice,lbltextCalls,lblphoneApp,lblSilent,lblvAlertDevice,bottomView,bottomimgView,ObjBLEConnection,vibrateTimer,falldetectTimer,normalPeriperal,bottomlineView;

@synthesize imgAlertDev,imgphoneApp,bottomLine;
@synthesize dashBoardView,valrtView,manageDeviceView,helpView;

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
    //Set flow step
     [DEFAULTS setBool:NO forKey:REMOVE_BACK];
    [DEFAULTS setInteger:3 forKey:FLOW_STEP];
    //set default for first flow
    [DEFAULTS setInteger:10 forKey:@"language"];
    [DEFAULTS synchronize];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    lblHomeText.text = NSLocalizedString(@"home_title", nil);
    lblDeviceDashboard.text = NSLocalizedString(@"home_deviceDashboard", nil);
    lblDeviceSettings.text = NSLocalizedString(@"home_settings", nil);
    lblhelp.text = NSLocalizedString(@"home_help", nil);
    lblmanageDevice.text = NSLocalizedString(@"home_manageDevice", nil);
    lbltextCalls.text = NSLocalizedString(@"home_textCalls", nil);
    lblphoneApp.text = NSLocalizedString(@"home_phoneApp", nil);
    lblSilent.text = NSLocalizedString(@"home_silent", nil);
    lblvAlertDevice.text = NSLocalizedString(@"home_valertDevice", nil);
    
    [lblDeviceDashboard  sizeToFit];
    [lblDeviceSettings sizeToFit];
    [lblmanageDevice sizeToFit];
    [lblhelp sizeToFit];
    
    
    dashBoardView.layer.cornerRadius=5;
    valrtView.layer.cornerRadius=5;
    manageDeviceView.layer.cornerRadius=5;
    helpView.layer.cornerRadius=5;
    
    
    [self intializeble];
    
    PermissionBlock permissionBlock = ^(BOOL granted) {
        if (!granted)
        {
            NSLog(NSLocalizedString(@"App has no Microphone Permission", nil));
            [[logfile logfileObj]  writeLog:NSLocalizedString(@"App has no Microphone Permission", nil)];
            self->dConnect = [[dbConnect alloc]init];

            [self->dConnect addStatus:[NSString stringWithFormat:@"%@",[[SharedData sharedConstants] currentDate]]
                            bleName:@"V.ALRT"
                            bleAddress:@"V.ALRT"
                            bleStatus: NSLocalizedString(@"App has no Microphone Permission", nil)];
            
        }
    };
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"App missing Microphone Access"
                                 message:@"We detected not having access for the microphone in case of a emergency call they will not be able to hear you."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No, thanks"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
                                              withObject:permissionBlock];
    }
    
    if(![[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
    {
        [DEFAULTS setObject:@"Other" forKey:@"countryname"];
        [DEFAULTS setObject:@"-" forKey:@"countrycode"];
    }
    AVAudioSessionRecordPermission mic_permission = [[AVAudioSession sharedInstance] recordPermission];
    switch (mic_permission) {
        case AVAudioSessionRecordPermissionGranted:
            break;
        case AVAudioSessionRecordPermissionDenied:
        case AVAudioSessionRecordPermissionUndetermined:
            //TODO: add this to main GUI if voice is enabled
           // [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];

            break;
        default:
            NSLog(@"Microphone permission uknown");
            break;
    }
}


-(void)intializeble
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        // If homeViewController doesn't have a BLEConnect class object
        if(!ObjBLEConnection)
        {
            AppDelegate *appDelegateObj = APP_DELEGATE;
            
            // Check ObjBLEConnect from App Delegate
            if (appDelegateObj.manageDevice.ObjBLEConnection)
            {
                // if valid then use ObjBLEConnection from App delegate
                ObjBLEConnection = appDelegateObj.manageDevice.ObjBLEConnection;
            } else
            {
                // AppDelegate doesn't have ObjBLEConnection then create new one
                ObjBLEConnection =[[BLEConnectionClass alloc]init];
                [ObjBLEConnection controlSetup:1]; // Do initial setup of BLEConnection class.
            }
            ObjBLEConnection.delegate = self;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        
            if(ObjBLEConnection.CM.state == CBCentralManagerStatePoweredOn)
            {
                [ObjBLEConnection.CM scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]] options:options];
            }
        
        }
    }
    [AlertInProgress sharedInstance].delegate =self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    bottomView = [[UIView alloc]init];
    lblSilent = [[UILabel alloc]init];
    imgAlertDev = [[UIImageView alloc]init];
    imgphoneApp = [[UIImageView alloc]init];
    bottomLine = [[UIImageView alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result1 = [[UIScreen mainScreen] bounds].size;
         deviceonoffLbl.translatesAutoresizingMaskIntoConstraints = YES;
        if(result1.height == 480)
        {
            
            
            mydeviceView.translatesAutoresizingMaskIntoConstraints = YES;
            mysettingView.translatesAutoresizingMaskIntoConstraints = YES;
            managedeviceimgView.translatesAutoresizingMaskIntoConstraints = YES;
            helpimgView.translatesAutoresizingMaskIntoConstraints = YES;
            managedeviceLbl.translatesAutoresizingMaskIntoConstraints = YES;
            helpiconLbl.translatesAutoresizingMaskIntoConstraints = YES;
            deviceoffBtn.translatesAutoresizingMaskIntoConstraints = YES;
            deviceoffImg.translatesAutoresizingMaskIntoConstraints = YES;
            deviceonoffLbl.translatesAutoresizingMaskIntoConstraints = YES;
            logoImg.translatesAutoresizingMaskIntoConstraints = YES;
            self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            
            
            mydeviceView.frame = CGRectMake(15, 125, 290, 90);
            mysettingView.frame = CGRectMake(15, 223, 290, 90);
            managedeviceimgView.frame = CGRectMake(44, 323, 63, 63);
            helpimgView.frame = CGRectMake(207, 323, 63, 63);
            helpiconLbl.frame = CGRectMake(200, 385, 80, 35);
      

            bottomimgView.frame=CGRectMake(0, 520, 320, 44);
            bottomView.frame = CGRectMake(0, 520, 320, 44);
            bottomimgView.backgroundColor = [UIColor clearColor];
            bottomView.backgroundColor = [UIColor clearColor];
            lbltextCalls.frame = CGRectMake(10, 15, 80, 20);
            lbltextCalls.textAlignment = NSTextAlignmentLeft;
            lblNotifyEnableDisableTextsandCalls.textAlignment = NSTextAlignmentLeft;
            lblNotifyEnableDisableTextsandCalls.frame = CGRectMake(85, 15, 50, 20);
            //Deviceoffbtn
            deviceoffBtn.frame = CGRectMake(15, 80, 290, 40);
            deviceoffImg.frame = CGRectMake(15, 80, 290, 40);
            deviceonoffLbl.frame = CGRectMake(120, 86, 69, 30);
            logoImg.frame = CGRectMake(45,29, 218, 44);
            lblSilent.textAlignment = NSTextAlignmentLeft;
            lblSilent.frame = CGRectMake(81, 12, 80, 20);
            
            if(![LANGUAGE isEqualToString:@"en"])
            {
                managedeviceLbl.frame = CGRectMake(20, 385, 113, 44);
                lblSilent.frame = CGRectMake(57, 12, 120, 20);
                //[lblDeviceSettings setFrame:CGRectMake(180, 148, 150, 41)];
                //[lblDeviceSettings setNumberOfLines:0];
                
            }
            else
            {
                managedeviceLbl.frame = CGRectMake(38, 385, 80, 44);
                lblSilent.frame = CGRectMake(81, 12, 80, 20);

            }
            lblSilent.text = NSLocalizedString(@"home_silent", nil);
            lblSilent.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            lblSilent.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
            imgAlertDev.frame = CGRectMake(209, 12, 22, 22);
            imgphoneApp.frame = CGRectMake(176, 12, 22, 22);
            
            bottomLine.frame = CGRectMake(0, 0, 321, 1);
            imgAlertDev.image = [UIImage imageNamed:@"deviceoff.png"];
            imgphoneApp.image = [UIImage imageNamed:@"calloff.png"];
            bottomLine.image = [UIImage imageNamed:@"line-bg.png"];
            [bottomView addSubview:bottomLine];
            [bottomView addSubview:lblSilent];
            [bottomView addSubview:imgAlertDev];
            [bottomView addSubview:imgphoneApp];
            [bottomView addSubview:lbltextCalls];
            [bottomView addSubview:lblNotifyEnableDisableTextsandCalls];
            [bottomimgView addSubview:bottomView];
            [bottomlineView setHidden:YES];

            
            if(![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT] && ![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT] )
            {
                [imgAlertDev removeFromSuperview];
                [imgphoneApp removeFromSuperview];
                [lblSilent removeFromSuperview];
                [bottomView removeFromSuperview];
                [bottomlineView setHidden:YES];

            }
        }
        else {
            
            //user feedback chnages starts
            
            imgAlertDev.frame = CGRectMake(213, 535, 22, 22);
            imgphoneApp.frame = CGRectMake(173, 535, 22, 22);
            lblSilent.backgroundColor=[UIColor clearColor];
            lblSilent.textAlignment = NSTextAlignmentLeft;
            
            if([LANGUAGE isEqualToString:@"en"])
            {
                lblSilent.frame = CGRectMake(83, 535, 80, 20);
                
            }
            else
            {
                lblSilent.frame = CGRectMake(57,535, 120, 20);
                
                
            }
            
            lblSilent.text = NSLocalizedString(@"home_silent", nil);
            lblSilent.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            lblSilent.textColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1];
            [bottomView addSubview:lblSilent];
            [bottomView addSubview:imgAlertDev];
            [bottomView addSubview:imgphoneApp];
            [bottomimgView addSubview:bottomView];
            [bottomlineView setHidden:NO];
            //user feedback chnages ends
            
            imgAlertDev.image = [UIImage imageNamed:@"deviceoff.png"];
            imgphoneApp.image = [UIImage imageNamed:@"calloff.png"];
            
            
            if (![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT]) {
                [imgAlertDev setHighlighted:YES];
                
            }else{
                [imgAlertDev setHighlighted:NO];
            }
            
            if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT]) {
                [imgphoneApp setHighlighted:YES];
                
            }else{
                [imgphoneApp setHighlighted:NO];
            }
            
            if(![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT] && ![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT] )
            {
                [imgAlertDev removeFromSuperview];
                [imgphoneApp removeFromSuperview];
                [lblSilent removeFromSuperview];
                [bottomView removeFromSuperview];
                [bottomlineView setHidden:YES];

            }
        }
        
    }
    if (![DEFAULTS boolForKey:DISABLE_SETTINGS]) {
        lblNotifyEnableDisableTextsandCalls.text = DEVICE_ENABLED;
    }else{
        lblNotifyEnableDisableTextsandCalls.text = DEVICE_DISABLED;
    }
    
    if (![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT]) {
        lblNotifyValertDeviceSilentMode.text = DEVICE_OFF;
        lblNotifyValertDeviceSilentMode.textColor = [UIColor redColor];
        [imgAlertDev setImage:[UIImage imageNamed:@"deviceoff.png"]];
        
    }else{
        lblNotifyValertDeviceSilentMode.text = DEVICE_ON;
        lblNotifyValertDeviceSilentMode.textColor = [UIColor greenColor];
        [imgAlertDev setImage:[UIImage imageNamed:@"deviceon.png"]];
    }
    
    if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT]) {
        lblNotifyPhoneApplicationSilentMode.text = DEVICE_OFF;
        lblNotifyPhoneApplicationSilentMode.textColor = [UIColor redColor];
        [imgphoneApp setImage:[UIImage imageNamed:@"calloff.png"]];
        
    }else{
        lblNotifyPhoneApplicationSilentMode.text = DEVICE_ON;
        lblNotifyPhoneApplicationSilentMode.textColor = [UIColor greenColor];
        [imgphoneApp setImage:[UIImage imageNamed:@"callon.png"]];
    }
    
    //Check puck is in paired  device
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
    NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    //@discussion -check if any device is paired
    if([defaultUUIDS  count] ==0 || defaultUUIDS == nil)
    {
        [deviceoffBtn setHidden:YES];
        [deviceoffImg setHidden:YES];
        [deviceonoffLbl setHidden:YES];
    }
    else
    {
        [deviceoffBtn setHidden:NO];
        [deviceoffImg setHidden:NO];
        [deviceonoffLbl setHidden:NO];
        if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
        {
            deviceonoffLbl.textColor = [UIColor blackColor];
            [self switchOn];
        }
        else
        {
            deviceonoffLbl.textColor = [UIColor whiteColor];
            [self switchOff];
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [bottomView removeFromSuperview];
}

-(void)scanDevices:(NSTimer *)timer
{
    [ObjBLEConnection findBLEPeripherals:5];
}

///keyfob ready
-(void) keyfobReady
{
    NSLog(@"HomeViewController::keyfobReady -- initialize puck settings");
    [SharedData sharedConstants].verifyMode = 1;
    [ObjBLEConnection verifyPairing:[ObjBLEConnection activePeripheral]];
    //setup notify flags on the puck
    [ObjBLEConnection enableButtons:[ObjBLEConnection activePeripheral]];
    
    if ([DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
    {
        for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
        {
            
            [ObjBLEConnection silentNormalmode:0x03 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
    }
    else
    {
        for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
        {
            
            [ObjBLEConnection silentNormalmode:0x00
                                     periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
    }
    [SharedData sharedConstants].readBtry =1;
    [ObjBLEConnection readBattery:[ObjBLEConnection activePeripheral]];
    
    //Write value to adjust connection interval
    [SharedData sharedConstants].adjustMode =1;
    [ObjBLEConnection adjustInterval:[ObjBLEConnection activePeripheral]];
}

///Key value press delegate and fall detect delegate
-(void) keyValuesUpdated:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Key Values Updated!");
    if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue] !=1)
    {
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"V.ALRT Key pressed", nil)];
        
        [DEFAULTS setValue:@"1" forKey:@"KeyPressed"];
        
        normalPeriperal = peripheral;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(normalMode) name:@"pucktonormal" object:nil];
        
 
        [[ContactsData sharedConstants] manageTextsandCalls];
        
        if ([[ContactsData sharedConstants].dictMessageResponse isKindOfClass:[NSNull class]])
        {
            
            [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:NSLocalizedString(@"invalid_number", nil)];
        }
        
        //Open the popup in a  main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
        });
    }
}
///Delagate for key fall
-(void)keyfall
{
    
    [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
}

///Key fall popup
-(void)keyfallpopup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:keyFallNotification object:nil];
    
    //Open the popup in a  main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
        
    });
    
}

///put the puck to silent mode
-(void)normalMode
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:keyFallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pucktonormal" object:nil];
    [SharedData sharedConstants].normalMode =1;
    [ObjBLEConnection disableAlert:normalPeriperal];
}


/// Method from BLEDelegate, called when fall detection values are updated
-(void) fallDetected:(CBPeripheral *)peripheral
{
    if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue] !=1)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(normalMode) name:@"pucktonormal" object:nil];
        
        //Add observer for keyfall popup
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyfallpopup) name:keyFallNotification object:nil];
        
        normalPeriperal = peripheral;
        
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"V.FALL fall Detect", nil)];
        
        //open the pop up in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertInProgress sharedInstance] didAnnouncementfallLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
        });
        [DEFAULTS setObject:@"1" forKey:@"FallDetecct"];
    }
}

///Delegate method call for battery status
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral
{
    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    
    //Notify alert to user for low battery
    [[commonnotifyalert alertConstant] Notifybatterystatus:[DEFAULTS objectForKey:strID]  deviceId:strID device:[SharedData sharedConstants].strBatteryLevelStatus];
    
}


-(void)invalidateTimer
{
    [self performSelectorOnMainThread:@selector(print) withObject:nil waitUntilDone:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoptimer" object:nil];
}

-(void)print{
    [vibrateTimer invalidate];
    vibrateTimer = nil;
}

-(void)batteryCurrentValue
{
    if([[SharedData sharedConstants].strBatteryLevelStatus integerValue] <90)
    {
        //Send local notification if the device battery is less than 10%
        NSString *strID = [NSString stringWithFormat:@"%@",p.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ is %@", [DEFAULTS objectForKey:strID],[SharedData sharedConstants].strBatteryLevelStatus];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [DEFAULTS synchronize];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didActionDeviceDashboard:(id)sender
{
    
    if ([SharedData sharedConstants].arrActivePeripherals.count >0)
    {
        
        if([[[SharedData sharedConstants].laststateIdentifiers allValues]containsObject:@"2"])
        {
            DeviceDashboardViewController *ObjDeviceDashBoard;
            UIStoryboard *storyboard = IPHONE_STORYBOARD;
            ObjDeviceDashBoard = [storyboard instantiateViewControllerWithIdentifier:@"DeviceDashboardViewController"];
            ObjDeviceDashBoard.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            ObjDeviceDashBoard.ObjBLEConnection = ObjBLEConnection;
            [self presentViewController:ObjDeviceDashBoard animated:YES completion:nil];
        }
        else
        {
            [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:NSLocalizedString(@"home-nodevice found", nil)];
        }
    }
    else
    {
        [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:NSLocalizedString(@"home-nodevice found", nil)];
    }
}

- (IBAction)didActionDeviceSettings:(id)sender
{
    
    vsnsettingsviewcontroller*ObjSettingsViewController;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjSettingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"vsnsettings"];
    ObjSettingsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ObjSettingsViewController animated:YES completion:nil];
}


- (IBAction)didActionManageDeviceSettings:(id)sender
{
    AppDelegate *appDelegateObj = APP_DELEGATE;
    // If AppDelegate has valid manageDevicesViewController then use it instead of instantiating a new one.
    if (appDelegateObj.manageDevice) {
        [self presentViewController:appDelegateObj.manageDevice animated:YES completion:nil];
    } else {
        ManageDevicesViewController *ObjManageDevicesViewController;
        UIStoryboard *storyboard = IPHONE_STORYBOARD;
        
        ObjManageDevicesViewController = [storyboard instantiateViewControllerWithIdentifier:@"ManageDevicesViewController"];
        ObjManageDevicesViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        ObjManageDevicesViewController.ObjBLEConnection = ObjBLEConnection;
        [self presentViewController:ObjManageDevicesViewController animated:YES completion:nil];
    }
    
}

- (IBAction)didActionAboutValert:(id)sender
{
    
    //HelpViewController *ObjHelpsViewController;
    vsnsettingsviewcontroller*ObjHelpsViewController;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjHelpsViewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    ObjHelpsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ObjHelpsViewController animated:YES completion:nil];
}

/*!
 *  @method deviceswitchoffandonAction:
 *  @discussion use to switch on and off the valrt app
 *
 */
- (IBAction)deviceswitchoffandonAction:(id)sender
{
    [deviceoffBtn setHighlighted:NO];
    if([DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
        
        /* Write value to the database to tell the switch is on */
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT"
            bleAddress:@"Address"     bleStatus:NSLocalizedString(@"Valrt_on", nil)];
        //Ends
        if(!ObjBLEConnection)
        {
            ObjBLEConnection =[[BLEConnectionClass alloc]init];
            [ObjBLEConnection controlSetup:1]; // Do initial setup of BLEConnection class.
            ObjBLEConnection.delegate = self;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            if(ObjBLEConnection.CM.state == CBCentralManagerStatePoweredOn)
            {
                [ObjBLEConnection.CM scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]] options:options];
            }
            
        }
        [self switchOn];
    }
    else
    {
        [[DevicoffpopView sharedInstance] didConfirmationViewLoad:self.view
                                         andConfirmationViewTitle:NSLocalizedString(@"turnoff_desc", nil)
                                       andConfirmationViewContent:@""
                                      andConfirmationViewCallback:^(BOOL onConfirm)
         {
            if(onConfirm)
            {
                /* Write value to the database to tell the switch is on */
                NSString *_date=[[SharedData sharedConstants] currentDate];
                self->dConnect = [[dbConnect alloc]init];
                //insert the device connection status
                [self->dConnect addStatus:[NSString stringWithFormat:@"%@",_date]
                            bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Valrt_off", nil)];
                //Ends
                [self switchOff];
            }
        }];
    }
}
/*!
 * Called by Reachability whenever status changes.
 */

/*!
 *  @method switchOn:
 *  @discussion do all the Function after switch on
 *
 */
-(void)switchOn
{
    deviceonoffLbl.textColor = TEXT_COLOR;
    
    [UIView animateWithDuration:.35 delay:0.0 options:0
                     animations:^{
                         float alphaValue = 1.0;
                         [self->lblDeviceDashboard setAlpha:alphaValue];
                         [self->lblDeviceSettings setAlpha:alphaValue];
                         [self->lblmanageDevice setAlpha:alphaValue];
                         [self->lblhelp setAlpha:alphaValue];
                         [self->mydeviceView setAlpha:alphaValue];
                         [self->mysettingView setAlpha:alphaValue];
                         [self->managedeviceimgView setAlpha:alphaValue];
                         [self->helpimgView setAlpha:alphaValue];
                         [self->lblSilent setAlpha:alphaValue];
                         [self->imgAlertDev setAlpha:alphaValue];
                         [self->imgphoneApp setAlpha:alphaValue];
                         [self->bottomView setAlpha:alphaValue];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }];
    
    [mydeviceView setUserInteractionEnabled:YES];
    [mysettingView setUserInteractionEnabled:YES];
    [lblDeviceDashboard setUserInteractionEnabled:YES];
    [lblDeviceSettings setUserInteractionEnabled:YES];
    [lblmanageDevice setUserInteractionEnabled:YES];
    [lblhelp setUserInteractionEnabled:YES];
    [managedeviceimgView setUserInteractionEnabled:YES];
    [helpimgView setUserInteractionEnabled:YES];
    [lblSilent  setUserInteractionEnabled:YES];
    [imgAlertDev  setUserInteractionEnabled:YES];
    [imgphoneApp  setUserInteractionEnabled:YES];
    [bottomView  setUserInteractionEnabled:YES];

    deviceoffBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [deviceoffBtn setSelected:YES];
     deviceonoffLbl.frame = CGRectMake(110, 135, 89, 30);
    deviceonoffLbl.textAlignment = NSTextAlignmentCenter;
    if(IS_IPHONE_4)
    {
        deviceonoffLbl.frame = CGRectMake(110, 86, 89, 30);
    }
    [deviceoffImg setHighlighted:YES];
    deviceonoffLbl.text = NSLocalizedString(@"on", nil);
    [DEFAULTS setBool:NO forKey:VALRT_DEVICE_OFF];
    [DEFAULTS synchronize];
    [self intializeble];
    
}
/*!
 *  @method switchOff:
 *  @discussion do all the Function after switch off
 *
 */
-(void)switchOff{
    
    // TRACKER : SETTING FLAG Valert_Immediate_Triggered TO CHECK FREQUENT ON/OFF
    [DEFAULTS setBool:NO forKey:Valert_Immediate_Triggered];
    [DEFAULTS setBool:YES forKey:VALRT_DEVICE_OFF];
    [DEFAULTS synchronize];
    
    deviceonoffLbl.textColor = [UIColor  whiteColor];
    
    [UIView animateWithDuration:.35 delay:0.0 options:0
                     animations:^{
                         float alphaValue = 0.3;
                         [self->lblDeviceDashboard setAlpha:alphaValue];
                         [self->lblDeviceSettings setAlpha:alphaValue];
                         [self->lblmanageDevice setAlpha:alphaValue];
                         [self->lblhelp setAlpha:alphaValue];
                         [self->mydeviceView setAlpha:alphaValue];
                         [self->mysettingView setAlpha:alphaValue];
                         [self->managedeviceimgView setAlpha:alphaValue];
                         [self->helpimgView setAlpha:alphaValue];
                         [self->lblSilent setAlpha:alphaValue];
                         [self->imgAlertDev setAlpha:alphaValue];
                         [self->imgphoneApp setAlpha:alphaValue];
                         [self->bottomView setAlpha:alphaValue];
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [mydeviceView setUserInteractionEnabled:NO];
    [mysettingView setUserInteractionEnabled:NO];
    [lblDeviceDashboard setUserInteractionEnabled:NO];
    [lblDeviceSettings setUserInteractionEnabled:NO];
    [lblmanageDevice setUserInteractionEnabled:NO];
    [lblhelp setUserInteractionEnabled:NO];
    [managedeviceimgView setUserInteractionEnabled:NO];
    [helpimgView setUserInteractionEnabled:NO];
    [lblSilent  setUserInteractionEnabled:NO];
    [imgAlertDev  setUserInteractionEnabled:NO];
    [imgphoneApp  setUserInteractionEnabled:NO];
    [bottomView  setUserInteractionEnabled:NO];
    
    //Puck app to silent mode and disconnect the puck
    for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
    {
        [ObjBLEConnection silentNormalmode:0x03 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        
    }

    [DEFAULTS setBool:YES forKey:VALRT_DEVICE_OFF];
    [deviceoffBtn setSelected:NO];
   deviceonoffLbl.frame = CGRectMake(110, 135, 89, 30);
    if(IS_IPHONE_4)
    {
        deviceonoffLbl.frame = CGRectMake(110, 86, 89, 30);
        
    }
    [deviceoffImg setHighlighted:NO];
    deviceonoffLbl.text = NSLocalizedString(@"off", nil);
  
    [self performSelector:@selector(removeDevice) withObject:self afterDelay:2.0];
}
/*!
 *  @method removeDevice:
 *  @discussion to disconnect the device
 *
 */
-(void)removeDevice{
    if([[SharedData sharedConstants].arrActivePeripherals count] >0)
    {
        //Restricted for one puck, if more puck in paired device need to change the index 0 to i
        CBPeripheral *peripheral =[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:0];
        [ObjBLEConnection.CM cancelPeripheralConnection: peripheral];
    }
}

#pragma mark : Tracker Get Activated/Diactivated

//Tracker: Called when Periferal Device Get disconnected
-(void)deviceDisconnected{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertInProgress sharedInstance] didAnnouncementDeviceConnect:self.view andAnnouncementSelect:^(int announcemntId){}];
    });
}

//Tracker: Called when Periferal Device Get Connected Again
-(void)deviceConnectedAgain{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertInProgress sharedInstance] cancelAlertView];
    });
    
}



#pragma mark -
#pragma mark Execution code

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
	sleep(3);

}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
