#import "AppDelegate.h"
#import "AlertInProgress.h"
#import "SharedData.h"
#import "Constants.h"
#import "logfile.h"
#import "dbConnect.h"
#import "commonnotifyalert.h"
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <sys/sysctl.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@import Firebase;


@implementation AppDelegate
@synthesize vibrateTimer,repeatToneFlag,dataArray,internetReachability,inCall,manageDevice;

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"AppDelegate::willFinishLaunchingWithOptions options: %@",launchOptions);
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSLog(@"AppDelegate::didFinishLaunchingWithOptions options: %@",launchOptions);
    [FIRApp configure];
    [Fabric with:@[[Crashlytics class]]];

    //Register local notfication for ios8
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings
                                                       settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |UIUserNotificationTypeSound
                                                        categories:nil]];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UIViewController *vc =[storyboard instantiateInitialViewController];
    
    // Set root view controller and make windows visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    //[application setStatusBarHidden:NO];
    //[application setStatusBarStyle:UIStatusBarStyleDefault];
    
    // [DEFAULTS setBool:NO forKey:VALRT_DEVICE_OFF];
    //Set o for key press and fall detect
    [DEFAULTS setObject:@"0" forKey:@"FallDetecct"];
    [DEFAULTS setObject:@"0" forKey:@"KeyPressed"];
    // Tracker: Flag to check device removed or not
    [DEFAULTS setValue:@"NO" forKey:@"DeviceRemoved"];
    [DEFAULTS setBool:NO forKey:IS_DEVICE_REMOVED];
    [DEFAULTS setValue:@"ShowingNO" forKey:SHOWINGDISCONNECTEDDEVICEPOPUP];
    
    //create object for dbconnect class
    dConnect = [[dbConnect alloc]init];

    //set bool to no for isLaunchedForBluetoothRestore
    [DEFAULTS setBool:NO forKey:@"isLaunchedForBluetoothRestore"];
    //app was relaunched to manage 
    if([launchOptions objectForKey:UIApplicationLaunchOptionsBluetoothCentralsKey])
    {
        //set bool to Yes for isLaunchedForBluetoothRestore if restore from bluetooth central key
        [DEFAULTS setBool:YES forKey:@"isLaunchedForBluetoothRestore"];
        //Get the array of central managers restored by iOS
        NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
        
        // Setup manageDevicesViewController so we can restore the Central Manager
        if (manageDevice == nil) {
            manageDevice = [storyboard instantiateViewControllerWithIdentifier:@"ManageDevicesViewController"];
            manageDevice.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        if (manageDevice.ObjBLEConnection == nil) {
            manageDevice.ObjBLEConnection = [[BLEConnectionClass alloc]init];
        }
        
        //Restore the Central Manager
        for (NSString *centralManagerIdentifier in centralManagerIdentifiers)
        {
            manageDevice.ObjBLEConnection.CM = [[CBCentralManager alloc] initWithDelegate:manageDevice.ObjBLEConnection queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey : centralManagerIdentifier, CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES]}];
            manageDevice.ObjBLEConnection.delegate = manageDevice;
        }
    }
    
    NSLog(@"AppDelegate::didFinishLaunchingWithOptions applicationState: %d",(int)[UIApplication sharedApplication].applicationState);
    //To check its not launch from local notification
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (!localNotif)
    {
        //To check its a first launch (because no need of notification in first launch)
        if ([[DEFAULTS valueForKey:@"isFirstLaunch"] isEqualToString:@"no"])
        {
            //Get the paired devices uuid.
            NSData *pairedUuidArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
            NSArray *pairedUuids = [NSKeyedUnarchiver unarchiveObjectWithData:pairedUuidArray];
            
            if([pairedUuids  count]>0 && pairedUuids != nil)
            {
                [self launchNotification];
            }
        }
        
    }
    //Call the call observer function
    [self callObserver];
    return YES;
}
//Call observer
-(void)callObserver
{
    _callCenter = [[CTCallCenter alloc] init];
    [_callCenter setCallEventHandler:^(CTCall *call)
     {
         if ([call.callState isEqualToString: CTCallStateIncoming])
         {
             
             [[commonnotifyalert alertConstant] stopNotify];
             
         }
         else if ([call.callState isEqualToString: CTCallStateDialing])
         {
             
             [[commonnotifyalert alertConstant] stopNotify];
             
         }
         else if ([call.callState isEqualToString: CTCallStateConnected])
         {
             self.inCall = 1;
             [[commonnotifyalert alertConstant] stopNotify];
         }
         else if ([call.callState isEqualToString: CTCallStateDisconnected])
         {
             self.inCall = 0;
             if([UIApplication sharedApplication].applicationState ==UIApplicationStateBackground)
             {
                 //Check for tracker
                 //check Tracker cancel and add status to the database
                 if([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
                 {
                     [[commonnotifyalert alertConstant] repeatTrackerNotify];
                 }
                 //For Key press
                 //Check  the keypressed
                 if ([[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"] || [[DEFAULTS valueForKey:@"FallDetecct"] isEqualToString:@"1"])
                 {
                     
                     [[commonnotifyalert alertConstant] repeatLocalNotify];
                 }
             }
             else
             {
                 //check Tracker cancel and add status to the database
                 if([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
                 {
                     [[commonnotifyalert alertConstant] repeatTrackertone];
                 }
                 
                 if ([[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"]  || [[DEFAULTS valueForKey:@"FallDetecct"] isEqualToString:@"1"])
                 {
                     
                     if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
                     {
                         [[commonnotifyalert alertConstant] repeatRingtone];
                     }
                 }
             }
         }
         
     }];
}

-(void)launchNotification
{
    NSLog(@"AppDelegate::launchNotification");
    
    //@comment-Check the count of  the active peripheral is greater than 0. This occur when there is any system kill by OS
    //@discussion -check the activeperipheral count ,If any devices is in paired section then the paired devices is save in activeperipheral array
    if([[SharedData sharedConstants].arrActivePeripherals count]>0)
    {
        CBPeripheral *peripheral =[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:0];
        //@discussion check the activiperipheral state if it is not in connected state
        if(peripheral.state != CBPeripheralStateConnected)
        {

            [dConnect addStatus:[NSString stringWithFormat:@"V.ALRT"] bleName:@"V.ALRT" bleAddress:@"V.ALRT" bleStatus: NSLocalizedString(@"system kill by OS", nil)];
            //@log to check the issue
            NSString*logValue = [NSString stringWithFormat:@"System Kill-Time Stamp -%@",[[SharedData sharedConstants] currentDate]];
            NSLog(@"%@", logValue);
            [[logfile logfileObj] writeLog:logValue];
            [self didLocalNotification];
        }
        
    }
    else
    {
        //@comment-This occur when you switch off/on the phone .
        //@discussion -If devices is paired but there is no activeperipheral ie,activieperipheral count is 0 since the activeperipheral is a singelton class it gets clear ,so based on the defaults uuid we throw local notification.
        [dConnect addStatus:[NSString stringWithFormat:@"%@",[[SharedData sharedConstants] currentDate]]
                    bleName:@"V.ALRT"
                  bleAddress:@"V.ALRT"
                  bleStatus: NSLocalizedString(@"Phone power up or app restored", nil)];
        
        //@log to check the issue
        NSString*logValue = [NSString stringWithFormat:@"Phone power up or app restored-Time Stamp -%@",[[SharedData sharedConstants] currentDate]];
        NSLog(@"%@", logValue);
        [[logfile logfileObj] writeLog:logValue];
        
       // if(![DEFAULTS boolForKey:IS_CONNECTED]){
            [self didLocalNotification];
        //}
        
    }
    
    //Wait for 3seconds and execute the code
    //WUT?
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    });
}

#pragma mark- LocalNotification
-(void)didLocalNotification
{
    NSLog(@"AppDelegate::didLocalNotification");
    //Check is not restore from bluetooth central key
    if(![DEFAULTS boolForKey:@"isLaunchedForBluetoothRestore"])
    {
        if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
        {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.applicationIconBadgeNumber =0;
            localNotification.alertBody = NSLocalizedString(@"app_launch", nil);
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.repeatInterval = NSCalendarUnitMinute;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            isBlockCancel = YES;
        }
    }
    else
    {
        //set no for isLaunchedForBluetoothRestore if it already yes
        [DEFAULTS setBool:NO forKey:@"isLaunchedForBluetoothRestore"];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    //Cancel all local notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //Check if Location is not enabled
    if(![CLLocationManager locationServicesEnabled]
       || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
        {
            NSLog(@"AppDelegate::applicationDidEnterBackground Location Permissions Disabled");
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody =NSLocalizedString(@"locationservice_agreement",nil);
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
            {
                
                // Tracker : Check if Tracker is in pregress and sound alert is on dont play local notification sound
                if ([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
                {
                    if (![DEFAULTS boolForKey:DEVICE_TRAKING_SOUND])
                    {
                        localNotification.soundName = UILocalNotificationDefaultSoundName;
                    }
                }else{
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }
            }
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [DEFAULTS synchronize];
        }
    } else {
        // Do any additional setup after loading the view.
        locationManager = [[CLLocationManager alloc] init];
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            //[locationManager requestWhenInUseAuthorization];
            [locationManager requestAlwaysAuthorization];
        }
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startMonitoringSignificantLocationChanges];

    }
    
    //Check the bluetooth is in off state Bluetooth
    if([[DEFAULTS valueForKey:@"Bluetooth"]isEqualToString:@"off"])
    {
        if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
        {
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody =NSLocalizedString(@"bluetooth-off", nil);
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
    else
    {
        [[SharedData sharedConstants] checkDisconnectdevice];
    }
    //Check  the keypressed
    if ([[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"] || [[DEFAULTS valueForKey:@"FallDetecct"] isEqualToString:@"1"])
    {
        if(repeatToneFlag !=1 && self.inCall !=1)
        {
            [[commonnotifyalert alertConstant] repeatLocalNotify];
        }
    }
    
    //Check for tracker
    //check Tracker cancel and add status to the database
    if([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"] && self.inCall !=1)
    {
        [[commonnotifyalert alertConstant] repeatTrackerNotify];
    }
    
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication]
                               setKeepAliveTimeout:600
                               handler:^{
                                   [self backgroundHandler];
                                   
                               }];
    if (backgroundAccepted)
    {
        
    }
    
    
}

//Low Accuracy level
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations

{
//    CLLocation *currentLocation = [locations lastObject];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // ...
}

-(void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)backgroundHandler
{
    
    NSLog(@"### -->VOIP backgrounding callback"); // What to do here to extend timeout?
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //check Tracker cancel and add status to the database
    if([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
    {
        [[commonnotifyalert alertConstant] repeatTrackertone];
    }
    if([SharedData sharedConstants].isReachable)
    {
        [[SharedData sharedConstants] dismissalert];
    }
    //Stop the location manager
    [locationManager stopMonitoringSignificantLocationChanges];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if ([[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"]  || [[DEFAULTS valueForKey:@"FallDetecct"] isEqualToString:@"1"])
    {
        
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            if(repeatToneFlag !=1)
            {
                
                [[commonnotifyalert alertConstant] repeatRingtone];
            }
        }
    }
    
    //Check location services enabled
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
        {
            if (!alertBool)
            {
                if (![[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"]  && ![[DEFAULTS valueForKey:@"FallDetecct"] isEqualToString:@"1"])
                {
                UIAlertView*alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App permission_title", nil)
                                                               message:NSLocalizedString(@"App permission-denied-alert", nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                     otherButtonTitles:nil];
                [alert show];
                alertBool = YES;
                }
            }
            
        }
        
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (![DEFAULTS valueForKey:@"isFirstLaunch"] || [[DEFAULTS valueForKey:@"isFirstLaunch"] isEqualToString:@""] || [[DEFAULTS valueForKey:@"isFirstLaunch"] isEqual:[NSNull null]])
    {
        NSLog(@"Pref value set to yes");
        [DEFAULTS setValue:@"no" forKey:@"isFirstLaunch"];
    }
    
}

#pragma mark-AlertView Delegate

/*!
 *  @method alertView:
 *
 *  @param  buttonIndex to read from
 *
 *  @discussion call this method when click the alert view
 *
 */
- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alertBool = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    [DEFAULTS setBool:NO forKey:IS_CONNECTED];
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

//Application will restore its state
- (BOOL)application:(UIApplication*)application shouldSaveApplicationState:(NSCoder*)coder
{
    return YES;
}

//Did receive memory warning
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Did-receive mem warning");
}

- (BOOL)application:(UIApplication*)application shouldRestoreApplicationState:(NSCoder*)coder
{
    BOOL restore = YES;
    // Compare the app version number to the preserved number.  If they differ,
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* storedVersion = [coder decodeObjectForKey:
                               UIApplicationStateRestorationBundleVersionKey];
    //Check app version is different and try to restore if app version is different or else just hide this function to restore in all the state
    restore = ![version isEqualToString:storedVersion];
    
    if(restore)
    {
        [[logfile logfileObj]  writeLog:@"Notification-3"];
        [dConnect addStatus:[NSString stringWithFormat:@"V.ALRT"]
                    bleName:@"V.ALRT"
                 bleAddress:@"V.ALRT"
                  bleStatus: NSLocalizedString(@"App upgrade", nil)];
        [self didLocalNotification];
    }
    
    return YES;
}
@end
