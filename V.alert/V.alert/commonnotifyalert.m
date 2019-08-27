#import "commonnotifyalert.h"
#import "Constants.h"
#import "SharedData.h"
#import "AppDelegate.h"
#import "dbConnect.h"
#import "customAlertPopUp.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UserNotifications/UserNotifications.h>

@implementation commonnotifyalert
@synthesize backgroundLocalNotify;
+(commonnotifyalert*)alertConstant
{
    static commonnotifyalert *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance)
    {
        myInstance  = [[[self class] alloc] init];
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                                 sizeof(sessionCategory), &sessionCategory);
    }
    return myInstance;
}

//Notify for low Battery status
-(void)Notifybatterystatus:(NSString *)deviceName  deviceId:(NSString *)deviceId device:(NSString *)Status
{
    if([Status integerValue]  <11)
    {
        
        Status = NSLocalizedString(@"Low Battery", nil);
        if([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
        {
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = [NSString stringWithFormat:@"%@ %@ %@",deviceName,NSLocalizedString(@"is", nil),Status];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
            {
                localNotification.soundName = UILocalNotificationDefaultSoundName;
            }
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [DEFAULTS synchronize];
            
        }
        else
        {
              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[SharedData sharedConstants] alertMessage:@"" msg:[NSString stringWithFormat:@"%@ %@ %@",deviceName,NSLocalizedString(@"is", nil),Status]];
                   }];
        }
        //Insert into the database
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dbConnect* dConnect = [[dbConnect alloc]init];
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:deviceName bleAddress:deviceId bleStatus:NSLocalizedString(@"Low Battery", nil)];
        
    }
}
//Repeat ringtone and notify
-(void)repeatRingtone
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {

        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            
            AudioSessionSetProperty (
                                     kAudioSessionProperty_OverrideAudioRoute,
                                     sizeof (audioRouteOverride),
                                     &audioRouteOverride
                                     );
            [self vibratePhone];
            [DEFAULTS synchronize];
            [vibrateTimer invalidate];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(vibratePhone) userInfo:nil repeats:YES];
            });
        }
        
        
    }
}

//Vibrate phone with sound
-(void)vibratePhone
{
    //Bind the ringtone text
    if ([DEFAULTS objectForKey:ALERT_RINGTONE_NAME] == nil)
    {
        [DEFAULTS setObject:TEMPORARY_RINGTONE_NAME forKey:ALERT_RINGTONE_NAME];
        [DEFAULTS setObject:TEMPORARY_RINGTONE_ID forKey:ALERT_RINGTONE_ID];
    }
    
    //Set yes for first time flow if not set already
    if([DEFAULTS objectForKey:IS_PANIC_SOUND_ENABLE] ==nil)
    {
        [DEFAULTS setBool:YES forKey:IS_PANIC_SOUND_ENABLE];
    }
    if ([DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE])
    {
        AudioServicesRemoveSystemSoundCompletion(soundID);
        AudioServicesDisposeSystemSoundID(soundID);
        
        NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], @"Siren_noise.wav"];
        NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
        //SystemSoundID soundID;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
        
        
    }
    else
    {
        AudioServicesPlaySystemSound([[DEFAULTS objectForKey:ALERT_RINGTONE_ID] intValue]);
    }
    [DEFAULTS synchronize];
}

//Invaidate the timer
-(void)invalidateTimer
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    AppDelegate*appDelegatObj =   APP_DELEGATE;
    appDelegatObj.repeatToneFlag =0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoptimer" object:nil];
    [vibrateTimer invalidate];
    vibrateTimer = nil;
    
}



//Repeat Local notify for every 3 secs
-(void)repeatLocalNotify
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        
        //Invalidate the old timers
        [vibrateTimer invalidate];
        
        // Remove previous notifications
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllDeliveredNotifications];
        
        //One notify in background to show alert in progress.
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = NSLocalizedString(@"send sms-notification", nil);
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride
                                 );
        //Call the repeat notify for sound
        [self repeatnotify];
        //Start the Background Expiration handler to
        [self startBackgroundExpiration];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repeatnotify) userInfo:nil repeats:YES];
        });
    }
}

#pragma mark-Tracker Feature

//Repeat ringtone and notify
-(void)repeatTrackertone
{
    //Remove all the previous observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoptimer" object:nil];
    //Add the new observer
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(invalidateTimer) name:@"stoptimer" object:nil];
    //[trackerTimer invalidate];
    
    if ([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] || [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION])
    {
        [vibrateTimer invalidate];
        [trackerTimer invalidate];
        
        
        [self repaeatTrackervibrateTone];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repaeatTrackervibrateTone) userInfo:nil repeats:YES];
        });
    }
}

//Vibrate phone with sound
-(void)repaeatTrackervibrateTone
{
    if ([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND])
    {
        AudioServicesRemoveSystemSoundCompletion(soundID);
        AudioServicesDisposeSystemSoundID(soundID);
        NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], @"Siren_noise.wav"];
        NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
        //SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
    }
    if ([DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
}

//Repeat Local notify for every 3 secs
-(void)repeatTrackerNotify
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        //Invalidate the old timers
        [vibrateTimer invalidate];
        [trackerTimer invalidate];
        
        //@discussion -One notify in background
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"V.ALRT %@ %@", NSLocalizedString(@"is", nil) , NSLocalizedString(@"disconnected", nil)];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        //Call the repeat tracker notify function for siren sound
        [self repeatTrackerLocalnotify];
        
        //Start the Background Expiration handler to
        [self startBackgroundExpiration];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->trackerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(repeatTrackerLocalnotify) userInfo:nil repeats:YES];
        });
    }
}

//call this method to repeat tracker notify for every 5 seconds
-(void)repeatTrackerLocalnotify
{
    
    if ([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND])
    {
        AudioServicesRemoveSystemSoundCompletion(soundID);
        AudioServicesDisposeSystemSoundID(soundID);
        NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], @"Siren_noise.wav"];
        NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
        //SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
    }
    
    if ([DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    [DEFAULTS synchronize];
    
}


//call this method to local notify for every 3 sec
-(void)repeatnotify
{
    //Bind the ringtone text
    if ([DEFAULTS objectForKey:ALERT_RINGTONE_NAME] == nil)
    {
        [DEFAULTS setObject:TEMPORARY_RINGTONE_NAME forKey:ALERT_RINGTONE_NAME];
        [DEFAULTS setObject:TEMPORARY_RINGTONE_ID forKey:ALERT_RINGTONE_ID];
    }
    //Set yes for first time flow if not set already
    if([DEFAULTS objectForKey:IS_PANIC_SOUND_ENABLE] ==nil)
    {
        [DEFAULTS setBool:YES forKey:IS_PANIC_SOUND_ENABLE];
    }
    
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            AudioServicesRemoveSystemSoundCompletion(soundID);
            AudioServicesDisposeSystemSoundID(soundID);
            if([DEFAULTS  boolForKey:IS_PANIC_SOUND_ENABLE])
            {
                NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], @"Siren_noise.wav"];
                NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
                //SystemSoundID soundID;
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
                AudioServicesPlaySystemSound(soundID);
            }
            else
            {
                AudioServicesPlaySystemSound([[DEFAULTS objectForKey:ALERT_RINGTONE_ID] intValue]);
            }
            
        }
        
        [DEFAULTS synchronize];
    }
}

//Stop the timer for sending local notification
-(void)stopNotify
{
    
    [vibrateTimer invalidate];
    [trackerTimer invalidate];
    vibrateTimer = nil;
    trackerTimer = nil;
    //Call endBackgroundExpiration to end background task
    if([UIApplication sharedApplication].applicationState ==UIApplicationStateActive){
        [self endBackgroundExpiration];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioServicesRemoveSystemSoundCompletion(self->soundID);
        AudioServicesDisposeSystemSoundID(self->soundID);
    });
    
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoptimer" object:nil];
}
- (void)stopSound{
    
    [vibrateTimer invalidate];
    [trackerTimer invalidate];
    vibrateTimer = nil;
    trackerTimer = nil;
    if([UIApplication sharedApplication].applicationState ==UIApplicationStateActive){
        [self endBackgroundExpiration];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        AudioServicesRemoveSystemSoundCompletion(self->soundID);
        AudioServicesDisposeSystemSoundID(self->soundID);
    }];
    
    if([UIApplication sharedApplication].applicationState ==UIApplicationStateBackground){
       [[UIApplication sharedApplication]cancelAllLocalNotifications];
    }
}
//Start the background Expiration Handler to run the time for local notify
-(void)startBackgroundExpiration
{
    self.backgroundLocalNotify = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundLocalNotify];
        self.backgroundLocalNotify = UIBackgroundTaskInvalid;
    }];
}

//End the background Expiration
-(void)endBackgroundExpiration
{
    if (self.backgroundLocalNotify != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundLocalNotify];
        self.backgroundLocalNotify = UIBackgroundTaskInvalid;
    }
}

#pragma mark -- Music Player Operations
// Tracker : SetUp And Play the Tracker Ton when it is in forground/Background and set the Volume to max
-(void)setUpAudioPlayer
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        
        
        [[AVAudioSession sharedInstance]setCategory: AVAudioSessionCategoryPlayback error: nil];
        
        NSString *soundFilePath;
        float currentVolume = [[AVAudioSession sharedInstance] outputVolume];
        NSLog(@"currentVolume-%f",currentVolume);
        // float currentVolume= 1.0; // Set The music volume to max
        // [[MPMusicPlayerController applicationMusicPlayer] setVolume: currentVolume];
        soundFilePath = [[NSBundle mainBundle] pathForResource: @"Siren_noise"
                                                        ofType: @"wav"];
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                                          error: nil];
        self.player = newPlayer;
        self.player.numberOfLoops = 0;
        [self.player prepareToPlay];
        [self.player setDelegate:self];
        [self.player play];
        [[AVAudioSession sharedInstance] setActive:(YES) error:nil];
    }];
    
    
}

// Tracker : Repeate the to
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if ([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"] && [DEFAULTS boolForKey:DEVICE_TRAKING_SOUND]) {
        [self setUpAudioPlayer];
    }
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    [self.player pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags{
    
    [self setUpAudioPlayer];
}
//-(void)
// Tracker : Stop the tone alert if playing
-(void)playPauseAction{
    
    // if already playing, then pause
    if (self.player.playing) {
        [self.player stop];
        // if stopped or paused, start playing
    }
}

@end
