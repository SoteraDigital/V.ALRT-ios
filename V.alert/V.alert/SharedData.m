#import "SharedData.h"
#import "Constants.h"
#import <UserNotifications/UserNotifications.h>

@implementation SharedData

@synthesize strCurrentPeriPheralName,isAnswered,arrPeriperhalNames,arrActivePeripherals,activePeripheral,strBatteryLevelStatus,selectedLang,strDidSelectContacts,arrSelectMultipleContacts,arrConnectedPeripherals,arrDiscovereUUIDs,strChangName,arrActiveIdentifiers,laststateIdentifiers,arrAvailableIdentifiers,normalMode,fallMode,fallenableIdentifiers,verifyMode,strserialNumber,strSofwareVer,fallDetection,activeIdentifier,activeSerialno,readMac,readBtry,internetReachability;


+ (SharedData *) sharedConstants{
    // the instance of this class is stored here
    static SharedData *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance)
    {
        // check for internet connection
        // Set up Reachability
        
        
        myInstance  = [[[self class] alloc] init];
        
        myInstance.arrPeriperhalNames = [[NSMutableArray alloc]init];
        
        myInstance.arrActivePeripherals = [[NSMutableArray alloc]init];
        
        myInstance.arrActiveIdentifiers = [[NSMutableArray alloc]init];
        myInstance.fallenableIdentifiers = [[NSMutableArray alloc]init];
        
        myInstance.arrAvailableIdentifiers = [[NSMutableArray alloc]init];
        
        myInstance.laststateIdentifiers = [[NSMutableDictionary alloc]init];
        
        myInstance.arrConnectedPeripherals = [[NSMutableArray alloc]init];
        
        myInstance.arrDisconnectedIdentifers = [[NSMutableArray alloc]init];
        
        myInstance.arrDiscovereUUIDs = [[NSMutableArray alloc]init];
        
        myInstance.strDidSelectContacts = [[NSMutableString alloc] init];
        
        myInstance.arrSelectMultipleContacts = [[NSMutableArray alloc]init];
        
        myInstance.isAnswered = FALSE;
        
        myInstance.selectedLang = 0; // Default no select
        myInstance.normalMode = 0;
        myInstance.fallMode = 0;
        myInstance.fallDetection = 0;
        myInstance.verifyMode = 0;
        myInstance.adjustMode =0;
        myInstance.readMac =0;
        myInstance.notifyserialSoft =0;
        myInstance.readBtry = 0;
        myInstance.readSoftver = 0;
        
        myInstance.arrEnabledCalls = [[NSMutableArray alloc]init];
        
        myInstance.arrEnabledTexts = [[NSMutableArray alloc]init];
        
    }
    // return the instance of this class
    return myInstance;
    
    
}
//End of class method
- (BOOL)isReachable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability  currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){
        /// Create an alert if connection doesn't work,no internet connection
        return NO;
    }
    else{
        return YES;
    }
}

//Local notify to alert no interne avialble
-(void)localnotify:(NSString *)Status
{
    //Send local notification when the device is disconnected/conneted/otherstatus
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@",Status];
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


//@discussion - check the disconnect device and if device is disconnect throw local notification
-(void)checkDisconnectdevice
{
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
    NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    //@discussion -check if any device is paired
    if([defaultUUIDS  count]>0 && defaultUUIDS != nil)
    {
        //@discussion -check the activeperipheral count ,If any devices is paired the paired devices is save in activeperipheral array
        //@comment-Check the count of  the active peripheral is greater than 0
        if([[SharedData sharedConstants].arrActivePeripherals count]>0)
        {
            CBPeripheral *peripheral =[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:0];
            //@discussion check the activiperipheral state if it is not in connected state
            if(peripheral.state !=2)
            {
                // Tracker: Set Tracker Wording in Conncetion and disconnction state
                if (![DEFAULTS boolForKey:IS_DEVICE_TRAKING_FEATURE_ON])
                {
                    [self disconnectNotification:NSLocalizedString(@"V.ALRT", nil) deviceStatus:NSLocalizedString(@"valrt_disconnected", nil)];
                }
                else
                {
                    [self disconnectNotification:NSLocalizedString(@"V.ALRT", nil) deviceStatus:NSLocalizedString(@"disconnected", nil)];
                }
            }
        }
        else
        {
            //@discussion -If devices is paired but there is no activeperipheral ie,activieperipheral count is 0
            //@comment-This occur when you switch off/on the phone the activeperipheral array(singelton class) will get clear but  device is in paired based on defaultUUIDS(Defaults wont clear) count so throw local notification.
            // Tracker: Set Tracker Wording in Conncetion and disconnction state
            if (![DEFAULTS boolForKey:IS_DEVICE_TRAKING_FEATURE_ON])
            {
                [self disconnectNotification:NSLocalizedString(@"V.ALRT", nil) deviceStatus:NSLocalizedString(@"valrt_disconnected", nil)];
            }
            else
            {
                [self disconnectNotification:NSLocalizedString(@"V.ALRT", nil) deviceStatus:NSLocalizedString(@"disconnected", nil)];
            }
        }
    }
    
}

-(void)disconnectNotification:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        // Remove previous notifications
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllDeliveredNotifications];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //Tracker : Set Tracker In Notification
        localNotification.alertBody = [NSString stringWithFormat:@"%@ %@ %@",deviceName, NSLocalizedString(@"is", nil) , deviceStatus];
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

//Get the curent date
-(NSString *)currentDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSString *curDate=[_formatter stringFromDate:date];
    
    return curDate;
}

- (BOOL) numericText: (NSString *) numeric
{
    NSString *emailRegex = @"^(?:|0|[1-9-+]\\d*)(?:\\.\\d*)?$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:numeric];
}
//Alert message
-(void) alertMessage:(NSString*)alertTitle msg:(NSString*)alertMsg
{
    alert = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMsg   delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
    [alert show];
}
//dismiss the alert
-(void)dismissalert
{
    if([alert.message isEqualToString:NSLocalizedString(@"No Internet Connection is Avaialable", nil)])
    {
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

//Get the enable calls
-(NSArray *)getEnabledcalls
{
    //Get enable call from
    NSData *dataRepresentingSavedEnabledNumberArray = [DEFAULTS objectForKey:ENABLED_CALLS];
    NSArray *arrCallEnabledIndices = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedEnabledNumberArray];
    return arrCallEnabledIndices;
}
//Get the enabled texts
-(NSArray *)getEnabledtexts
{
    NSData *dataRepresentingSavedEnabledTextArray = [DEFAULTS objectForKey:ENABLED_TEXTS];
    NSArray *arrTextEnabledIndices = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedEnabledTextArray];
    return arrTextEnabledIndices;
}

/*!
 *  Check the name(string) if exists in any one of the value in the array
 *
 *  @param substring get the substring to compare
 *
 *  @return return bool response if string found
 */
- (BOOL)ContainValue:(NSString *)substring
{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
    [array addObject:@"V.ALRT"];
    [array addObject:@"V-Alert"];
    [array addObject:@"VALRT"];
    
    BOOL containsSubstring = NO;
    
    for (NSString *string in array)
    {
        if ([substring rangeOfString:string].location != NSNotFound && substring!=nil && ![substring isEqual:[NSNull null]] && ![substring isEqualToString:@""])
        {
            containsSubstring = YES;
            break;
        }
    }
    return containsSubstring;
}

@end

