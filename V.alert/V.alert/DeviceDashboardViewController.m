#import "DeviceDashboardViewController.h"
#import "SharedData.h"
#import "ContactsData.h"
#import "customAlertPopUp.h"
#import "AlertInProgress.h"
#import "ConfirmationView.h"
#import "ChangeNameView.h"
#import "commonnotifyalert.h"
#import "Constants.h"
#import "UIAlertView+UIAlertViewController.h"
#import "logfile.h"

#include <AudioToolbox/AudioToolbox.h>

@interface DeviceDashboardViewController ()

@end

@implementation DeviceDashboardViewController
@synthesize imgFall,btnBackaction,bottomView;
@synthesize lblShowBatteryPercentage,imgViewShowBatteryStatus,imgViewShowSignalStregnth,btnChangeName,btnFallDetection,btnFindMe,btnForgetMe,lblShowDeviceName,activePeripheral,lblShowSignalPercentage,scrlViewMultipleDevices,pgeCtrlrAvailableDevices,vibrateTimer,lblFallStatus,normalPeriperal,falldetectTimer,ObjBLEConnection,fallDetectionLbl;

@synthesize bottomLine,findVLRTLbl,forgetMeLbl,renameLbl;
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
    
    bottomLine.backgroundColor = BRANDING_COLOR;
    findVLRTLbl.text=NSLocalizedString(@"devicedashboard_findV.ALRT", nil);
    forgetMeLbl.text=NSLocalizedString(@"devicedashboard_forgetme", nil);
    renameLbl.text=NSLocalizedString(@"devicedashboard_renameV.ALRT", nil);
    
    
    fallDetectionLbl.text=NSLocalizedString(@"devicedashboard_falldetection", nil);
    [AlertInProgress sharedInstance].delegate =self;
    
    [btnBackaction setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    
    if([LANGUAGE isEqualToString:@"en"])
    {
        [btnBackaction setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0,0)];
    }
    
    //Set Label Name
    arrActivePeripherals = [[NSMutableArray alloc]init];
    for(int i=0;i<[SharedData sharedConstants].arrActivePeripherals.count;i++)
    {
        CBPeripheral *per = [[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i];
        if(per.state ==2)
        {
            [arrActivePeripherals addObject:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
    }
    if([arrActivePeripherals count]>0)
    {
        activePeripheral =[arrActivePeripherals objectAtIndex:0];
        [lblShowDeviceName setText:NSLocalizedString(@"home_deviceDashboard", nil)];
        lblShowDeviceName.textColor = BRANDING_COLOR;
        [btnFindMe setEnabled:YES];
        [btnChangeName setEnabled:YES];
        [btnFallDetection setEnabled:YES];
        deviceStatus =1;
    }
    
    
    
    //Register notifcation to check the status of active peripheral
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Checkstate:)
                                                 name:@"statechange"
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"statechange" object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    if([arrActivePeripherals count]==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    bottomView = [[UIView alloc]init];
   // imgViewShowBatteryStatus = [[UIImageView alloc]init];
   // imgViewShowSignalStregnth = [[UIImageView alloc]init];
    bottomLine = [[UIImageView alloc]init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        //CGSize result1 = [[UIScreen mainScreen] bounds].size;
        bottomView.backgroundColor = [UIColor clearColor];
        [lblFallStatus setBackgroundColor:[UIColor clearColor]];
        
        if([LANGUAGE isEqualToString:@"en"])
        {
            //lblFallStatus.frame = CGRectMake(30,11, 80, 20);
            lblFallStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            //lblFallStatus.font = [UIFont boldSystemFontOfSize:10];
        }
        else
        {
            //lblFallStatus.frame = CGRectMake(65,11, 80, 20);
            [lblFallStatus setBackgroundColor:[UIColor clearColor]];
            lblFallStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            //lblFallStatus.font = [UIFont boldSystemFontOfSize:10];
            //lblFallStatus.textAlignment = NSTextAlignmentLeft;
        }
        lblFallStatus.textAlignment = NSTextAlignmentLeft;
        
        lblFallStatus.text = NSLocalizedString(@"fall_status_disable", Nil);
        lblShowBatteryPercentage.textAlignment = NSTextAlignmentLeft;
        lblShowBatteryPercentage.frame = CGRectMake(250, 6, 20, 10);
        lblShowBatteryPercentage.font = [UIFont fontWithName:@"Avenir" size:8];
        lblShowBatteryPercentage.textColor = [UIColor whiteColor];
        
        lblShowSignalPercentage.textAlignment = NSTextAlignmentLeft;
        lblShowSignalPercentage.frame = CGRectMake(292, 6, 20, 10);
        lblShowSignalPercentage.font = [UIFont fontWithName:@"Avenir" size:8];
        lblShowSignalPercentage.textColor = [UIColor whiteColor];
       // imgViewShowSignalStregnth.frame = CGRectMake(281, 11, 25, 20);
        //imgViewShowBatteryStatus.frame = CGRectMake(224, 12, 40, 18);
        
        //bottomLine.frame = CGRectMake(0, 8, 321, 1);
        imgViewShowSignalStregnth.image = [UIImage imageNamed:@"img_signal_lost.png"];
        imgViewShowBatteryStatus.image = [UIImage imageNamed:@"battery_0.png"];
        //bottomLine.image = [UIImage imageNamed:@"line-bg.png"];
        //[bottomView addSubview:bottomLine];
        //[bottomView addSubview:lblShowBatteryPercentage];
        //[bottomView addSubview:imgViewShowBatteryStatus];
        //[bottomView addSubview:imgViewShowSignalStregnth];
        // [bottomView addSubview:lblFallStatus];
        //[bottomView addSubview:lblShowSignalPercentage];
        
        /*if(result1.height == 480)
        {
            bottomView.frame = CGRectMake(0, 440, 320, 40);
        }
        else
        {
            bottomView.frame = CGRectMake(0, 528, 320, 40);
        }*/
        //[self.view addSubview:bottomView];
    }
    
    //If fall detection already enabled
    NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
    
    //@log to check the issue
    NSString*logValue = [NSString stringWithFormat:@"Device Dashboard-Activeperipheral Id-%@ Time Stamp -%@",strID,[[SharedData sharedConstants] currentDate]];
    [[logfile logfileObj] writeLog:logValue];
    
    //Check strID length >20 then proceed to check the fall enable and other values.
    if([strID length] >20)
    {
        strID = [strID substringFromIndex: [strID length] - 20];
        dConnect = [[dbConnect alloc]init];
        if ([dConnect checkfallenableDevice:strID]==1)
        {
            
            [DEFAULTS setValue:@"0" forKey:@"FallEnabled"];
            lblFallStatus.text = NSLocalizedString(@"fall_status_enable", Nil);
            [imgFall setHighlighted:YES];
            [fallDetectionLbl setEnabled:YES];
            
            if(![LANGUAGE isEqualToString:@"en"])
            {
                lblFallStatus.frame = CGRectMake(65,11, 80, 20);
                [lblFallStatus setBackgroundColor:[UIColor clearColor]];
                lblFallStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
                lblFallStatus.font = [UIFont boldSystemFontOfSize:10];
                lblFallStatus.textAlignment = NSTextAlignmentLeft;
            }
            
            
        }
        else
        {
            
            [DEFAULTS setValue:@"1" forKey:@"FallEnabled"];
            lblFallStatus.text = NSLocalizedString(@"fall_status_disable", Nil);
            [imgFall setHighlighted:NO];
            [fallDetectionLbl setEnabled:YES];
            
        }
    }
    [SharedData sharedConstants].strBatteryLevelStatus = [NSString stringWithFormat:@"%d",0];
    [SharedData sharedConstants].strSignalStregnthstatus= [NSString stringWithFormat:@"%d",0];
    
    
    if(arrActivePeripherals.count >1)
    {
        pgeCtrlrAvailableDevices.numberOfPages = 0;
        pgeCtrlrAvailableDevices.currentPage = 0;
    }
    else
    {
        pgeCtrlrAvailableDevices.numberOfPages   =0;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)4.0 target:self selector:@selector(stregnthIndicatorTimer:) userInfo:nil repeats:YES];
    
    
    
    [self setupScrollView:scrlViewMultipleDevices];
    [self getBatteryStatus];
    
    //Hide the battery status and signal strength
    [lblShowSignalPercentage setHidden:YES];
    [lblShowBatteryPercentage setHidden:YES];
    
}

- (void) stregnthIndicatorTimer:(NSTimer *)timer
{
    
    //Get Signal Stregnth Status
    //[ObjBLEConnection readRssi:activePeripheral];
    if([activePeripheral state] != CBPeripheralStateConnected)
    {
        return;
    }
    [activePeripheral readRSSI];
    
    int signalStregnth = 2 * ((int)[[SharedData sharedConstants].strSignalStregnthstatus integerValue] + 100);
    //NSLog(@"a %d value ",signalStregnth);
    
    //Set Signal Stregnth as Text
    [lblShowSignalPercentage setText:[NSString stringWithFormat:@"%ld %@",(long)[[SharedData sharedConstants].strSignalStregnthstatus integerValue],@"dBm"]];
    

    //Set image indicator for Signal
    if (signalStregnth <=150 && signalStregnth >100) {
        imgViewShowSignalStregnth.image =[UIImage imageNamed:@"img_signal_very_strong.png"];
    }else  if (signalStregnth <100 && signalStregnth >80) {
        imgViewShowSignalStregnth.image =[UIImage imageNamed:@"img_signal_strong.png"];
    }else  if (signalStregnth <80 && signalStregnth >40) {
        imgViewShowSignalStregnth.image =[UIImage imageNamed:@"img_signal_weak.png"];
    }else  if (signalStregnth <40 && signalStregnth >10) {
        imgViewShowSignalStregnth.image =[UIImage imageNamed:@"img_signal_very_weak.png"];
    }else  if (signalStregnth <10) {
        imgViewShowSignalStregnth.image =[UIImage imageNamed:@"img_signal_lost.png"];
    }
    
}

//Get the battery status and bind the image
-(void)getBatteryStatus
{
    NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    int battery = [dConnect getBattertyStatus:strID];
    [SharedData sharedConstants].strBatteryLevelStatus = [NSString stringWithFormat:@"%d",battery];
    [self performSelector:@selector(bindbatteryvalue) withObject:self afterDelay:2.0];
    
}

//bind the battery value
-(void)bindbatteryvalue
{
    //Set Battery Value as Text
    [lblShowBatteryPercentage setText:[NSString stringWithFormat:@"%ld %@",(long)[[SharedData sharedConstants].strBatteryLevelStatus integerValue],@"%"]];
    
    //Set image indicator for Battery
    if ([[SharedData sharedConstants].strBatteryLevelStatus integerValue]<=100 && [[SharedData sharedConstants].strBatteryLevelStatus integerValue]>20)
    {
        imgViewShowBatteryStatus.image =[UIImage imageNamed:@"battery_2.png"];
    }
    else  if ([[SharedData sharedConstants].strBatteryLevelStatus integerValue]<=20 && [[SharedData sharedConstants].strBatteryLevelStatus integerValue]>=10)
    {
        imgViewShowBatteryStatus.image =[UIImage imageNamed:@"battery_1.png"];
    }
    else  if ([[SharedData sharedConstants].strBatteryLevelStatus integerValue]<10)
    {
        imgViewShowBatteryStatus.image =[UIImage imageNamed:@"battery_3.png"];
        
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        if(activePeripheral !=nil)
        {
            NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
            strID = [strID substringFromIndex: [strID length] - 20];
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:@"LowBattery"];
        }
    }
    
}

//Check and change the state
-(void)Checkstate:(NSNotification *) notification
{
    if([arrActivePeripherals count]>0)
    {
        NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        if(notification.userInfo ==nil)
        {
            [lblShowDeviceName setText:NSLocalizedString(@"home_deviceDashboard", nil)];
            [[SharedData sharedConstants].arrDisconnectedIdentifers removeObject:strID];
            [btnFindMe setEnabled:YES];
            [btnChangeName setEnabled:YES];
            [btnFallDetection setEnabled:YES];
            deviceStatus =1;
        }
        else
        {
            if([strID isEqualToString:[notification.userInfo valueForKey:@"identifier"]])
            {
                deviceStatus =0;
                [btnFindMe setEnabled:NO];
                [btnChangeName setEnabled:NO];
                [btnFallDetection setEnabled:NO];
                [lblShowDeviceName setText:@"Disconnected"];
                [[SharedData sharedConstants].arrDisconnectedIdentifers addObject:strID];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

//Find me action starts
- (IBAction)didActionFindMe:(id)sender
{
    
    if (![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
    {
        
        //Add status to the database
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"Find  V.ALRT Device", nil)];
        [ObjBLEConnection soundBuzzer:kSoundAndLEDEvery2SecsFor20sec p:activePeripheral];
        
    }
    if(deviceStatus)
    {
        PopViewController *ObjHelp;
        UIStoryboard *storyboard = IPHONE_STORYBOARD;
        ObjHelp = [storyboard instantiateViewControllerWithIdentifier:@"PopViewController"];
        ObjHelp.deviceName = lblShowDeviceName.text;
        ObjHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:ObjHelp animated:YES completion:nil];
    }
}

//Change the name of the device
- (IBAction)didActionChangeName:(id)sender
{
    
    if(deviceStatus)
    {
        CBPeripheral *peripheral = activePeripheral;
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        //use feedback changes starts
        NSString *str= NSLocalizedString(@"devicedashboard_renameV.ALRT", nil);
        [[ChangeNameView sharedInstance] didConfirmationViewLoad:self.view andConfirmationViewTitle:str andConfirmationViewContent:[DEFAULTS objectForKey:strID] andConfirmationViewCallback:^(BOOL onConfirm)
         {
             if(onConfirm)
             {
                 if (self->activePeripheral != nil)
                 {
                     if(![[[DEFAULTS dictionaryRepresentation] allValues]containsObject:[SharedData sharedConstants].strChangName] || [[DEFAULTS objectForKey:@"userName"] isEqualToString:[SharedData sharedConstants].strChangName])
                     {
                         if([[SharedData sharedConstants].strChangName length]>16)
                         {
                             [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"name_less", nill) msg:nil];
                         }
                         else
                         {
                             [DEFAULTS setObject:[SharedData sharedConstants].strChangName forKey:strID];
                             [DEFAULTS synchronize];
                             [self->lblShowDeviceName setText:NSLocalizedString(@"home_deviceDashboard", nil)];
                             //update the devicename in the history table
                             self->dConnect = [[dbConnect alloc]init];
                             NSString *strID = [NSString stringWithFormat:@"%@",self->activePeripheral.identifier];
                             strID = [strID substringFromIndex: [strID length] - 20];
                             [self->dConnect updatestatus:@"devicename" value:[DEFAULTS objectForKey:strID] mac:strID];
                             //Update device name to device information table
                             [self->dConnect updatedeviceinfo:@"devicename" value:[DEFAULTS objectForKey:strID] mac:strID];
                         }
                         
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:NSLocalizedString(@"manage_device_name_exist", nil)
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
                     }
                 }
             }
         }];
        
    }
}


- (IBAction)didactionFallDetection:(id)sender
{
    if(deviceStatus)
    {
        NSString*msg;
        NSString*title;
        NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        dConnect = [[dbConnect alloc]init];
        if ([dConnect checkfallenableDevice:strID]==1)
        {
            msg = NSLocalizedString(@"Are you sure do you want to disable the fall detection?", nil);
        }
        else
        {
            msg = NSLocalizedString(@"Are you sure do you want to enable the fall detection?", nil);
            title = NSLocalizedString(@"Enable Fall Detection?", nil);
        }
        
        UIAlertView*fallAlert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil) otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
        
        [fallAlert show];
        
    }
}

- (IBAction)didActionForgetMe:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"statechange" object:nil];
    
    [[ConfirmationView sharedInstance] didConfirmationViewLoad:self.view andConfirmationViewTitle:NSLocalizedString(@"Are you sure want to forgot this device",nil) andConfirmationViewContent:NSLocalizedString(@"Are you sure want to forgot this device", nil)   andConfirmationViewCallback:^(BOOL onConfirm) {
        if(onConfirm)
        {
            if (self->activePeripheral != nil)
            {
                
                //Set Device is removed bool to yes if forgot the device.
                [DEFAULTS setBool:YES forKey:IS_DEVICE_REMOVED];
                [self->ObjBLEConnection.CM cancelPeripheralConnection:self->activePeripheral];
                
                [[SharedData sharedConstants].arrActivePeripherals removeAllObjects];
                [[SharedData sharedConstants].arrActiveIdentifiers removeAllObjects];
                [[SharedData sharedConstants].arrAvailableIdentifiers removeAllObjects];
                
                NSString *strID = [NSString stringWithFormat:@"%@",self->activePeripheral.identifier];
                strID = [strID substringFromIndex: [strID length] - 20];
                self->dConnect = [[dbConnect alloc]init];
                [self->dConnect deleteDeviceInfo:strID];
                [self->dConnect addfallenableDevice:strID bleFlag:@"0"];
                
                //Insert value to the database
                NSString *_date=[[SharedData sharedConstants] currentDate];
                [self->dConnect addStatus:[NSString stringWithFormat:@"%@",_date]  bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"devicedashboard_forgetme", nil)];
                
                NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
                NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
                if (defaultUUIDS != nil) {
                    //[SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
                }
                [[SharedData sharedConstants].arrDiscovereUUIDs removeAllObjects];
                [DEFAULTS removeObjectForKey:BLE_DISCOVERED_UUIDS];
                [DEFAULTS synchronize];
                self->activePeripheral = nil;
                [SharedData sharedConstants].activePeripheral = nil;
                self->ObjBLEConnection.activePeripheral = nil;
                [self dismissViewControllerAnimated:YES completion:Nil];
            }
        }
    }];
    
}

- (IBAction)didActionBackViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//Delegate for key fall
-(void)keyfall
{
    [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
}

//Delegate method call for battery status
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral
{
    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    [[commonnotifyalert alertConstant] Notifybatterystatus:[DEFAULTS objectForKey:strID]  deviceId:strID device:[SharedData sharedConstants].strBatteryLevelStatus];
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

#pragma mark AudioService callback function prototypes
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID  ssID,
                                               void           *clientData
                                               );

#pragma mark AudioService callback function implementation

// Callback that gets called after we finish buzzing, so we
// can buzz a second time.
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID  ssID,
                                               void           *clientData
                                               ) {
    
    
    
    BOOL isPlaying = '\0';
    
    if (isPlaying) {
        AudioServicesPlaySystemSound([[DEFAULTS objectForKey:ALERT_RINGTONE_ID] intValue]);
    }else{
        AudioServicesRemoveSystemSoundCompletion([[DEFAULTS objectForKey:ALERT_RINGTONE_ID] intValue]);
    }
    
    [DEFAULTS synchronize];
    
    
}


-(void)someMethod:(NSNotification * ) notification{
    
    
    NSLog(@"this got called");
    
}



#pragma mark - ScrollView Delegates


- (void)setupScrollView:(UIScrollView*)scrMain
{
    // we have 10 images here.
    
    
    for (UIView *view in scrMain.subviews){
        
        [view removeFromSuperview];
    }
    
    [scrMain setBackgroundColor:[UIColor clearColor]];
    [scrMain setAlpha:0];
    
    
    for (int i=0; i<[SharedData sharedConstants].arrActivePeripherals.count; i++)
    {
        // create imageView
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(i*scrMain.frame.size.width, 0, scrMain.frame.size.width, scrMain.frame.size.height)];
        
        // apply tag to access in future
        imgV.backgroundColor = [UIColor whiteColor];
        imgV.layer.cornerRadius = 8.0;
        imgV.layer.masksToBounds = YES;
        // add to scrollView
        [scrMain addSubview:imgV];
    }
    // set the content size to 10 image width
    [scrMain setContentSize:CGSizeMake(scrMain.frame.size.width*[SharedData sharedConstants].arrActivePeripherals.count, scrMain.frame.size.height)];
    
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollviewwillbegindragging");
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate == NO){
        NSLog(@"no deceleration.");
    }
    NSLog(@"scrollviewdidenddragging");
}



#pragma  mark- Alertview Delegate

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // user tapped a button, don't dismiss alert programatically (i.e. invalidate timer)
    if(buttonIndex==1)
    {
        NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        dConnect = [[dbConnect alloc]init];
        
        //Check fall enable or disable
        if ([dConnect checkfallenableDevice:strID]==1)
        {   
            //Insert fall enable to identifier
            [dConnect addfallenableDevice:strID bleFlag:@"0"];
            [DEFAULTS setValue:@"0" forKey:@"FallEnabled"];
            lblFallStatus.text = NSLocalizedString(@"fall_status_disable", Nil);
            [imgFall setHighlighted:NO];
            //[lblFallStatus setEnabled:NO];
            [fallDetectionLbl setEnabled:YES];
            [[SharedData sharedConstants].fallenableIdentifiers removeObject:activePeripheral.identifier];
            [SharedData sharedConstants].fallMode =1;
            [ObjBLEConnection setFallDetection:activePeripheral];
            
        }
        else
        {
            //Insert fall enable to identifier
            [dConnect addfallenableDevice:strID bleFlag:@"1"];
            
            [DEFAULTS setValue:@"1" forKey:@"FallEnabled"];
            lblFallStatus.text = NSLocalizedString(@"fall_status_enable", Nil);
            [imgFall setHighlighted:YES];
            [fallDetectionLbl setEnabled:YES];
            [[SharedData sharedConstants].fallenableIdentifiers addObject:activePeripheral.identifier];
            [SharedData sharedConstants].fallMode =1;
            [ObjBLEConnection setFallDetection:activePeripheral];
            
        }
    }
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    scroller.frame =CGRectMake(0, 67, 320, self.view.frame.size.height-105);
    scroller.contentSize = CGSizeMake(320, 440);
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
