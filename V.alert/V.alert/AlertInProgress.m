#import "AlertInProgress.h"
#import "Constants.h"
#import "ContactsData.h"
#import "commonnotifyalert.h"
#import "AppDelegate.h"

#import "dbConnect.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>

@implementation AlertInProgress
@synthesize rootView, window,tableViewAnnouncement,imgViewBackground,falldetectTimer;
@synthesize delegate,checkmark,vibrateTimer,cancelAllBtn;
@synthesize _isIncomingVOIPEnabled, _isCallInProgress;

+(AlertInProgress *)sharedInstance{
    
    
    
    // the instance of this class is stored here
    static AlertInProgress *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        
        myInstance = [[[self class] alloc] initWithView];
        
    }//End of if statement
    
    myInstance.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myInstance.window.windowLevel = UIWindowLevelStatusBar;
    myInstance.window.hidden = YES;
    // myInstance.window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    myInstance.window.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_tansparent_background.png"]];
    myInstance.onAnnouncementSelect = nil;
    
    return myInstance;
}

-(id)initWithView{
    
    NSLog(@"AlertInProgress::initWithView");
    NSArray *arrayOfViews;
    
    arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AlertInProgress"
                                                 owner:nil
                                               options:nil];
    
    if ([arrayOfViews count] < 1)
    {
        
        return nil;
    }
    
    AlertInProgress *newView = [arrayOfViews objectAtIndex:0];
    
    self = newView;
    
    [_labelAnnouncementTitle setText:NSLocalizedString(@"send sms-notification", nil)];
    [cancelAllBtn setTitle:NSLocalizedString(@"cancel_all_progress", nil) forState:UIControlStateNormal];
    
    //VOIP - initialize the current call index
    //this is used to update the table with the active call
    _currentCallIndex = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isConnecting) name:kTCConnectionIsConnecting object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didConnect:) name:kTCConnectionDidConnect object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didDisconnect:) name:kTCConnectionDidDisconnect object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(smsSent:) name:kSmsSent object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveIncomingCall:) name:kTCConnectionDidReceiveIncomingConnection object:nil];
    
    return self;
    
    
}

-(void)smsSent:(NSNotification *)notification
{
    NSLog(@"AlertInProgress::smsSent");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        
        self->_smssentFlag =1;
        
        //TODO HERE!!! fix sms sent has failurew not being set correctly on 400 resp.
        if([[notification.userInfo objectForKey:@"response"] integerValue]==0)
        {
            self->_smsFailure =1;
        }
        
        //Check incoming call voip enabled
        self->_isIncomingVOIPEnabled = [[[notification userInfo] valueForKey:@"isIncomingVOIPEnabled"] boolValue];
        self->_isCallInProgress = NO;
        
        if([[[ContactsData sharedConstants]arrCallNumbers] count]>0)
        {
            if(self->_currentCallIndex == 4
               && self->_smssentFlag == 1
               && self->_isIncomingVOIPEnabled == NO)
            {
                if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue]  == 1)
                {
                    [self->cancelAllBtn setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateNormal];
                    //[self.tableViewAnnouncement reloadData];
                }
            }
            
        }
        else
        {
            if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue]  == 1)
            {
                if(self->_isIncomingVOIPEnabled == NO)
                {
                    [self->cancelAllBtn setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateNormal];
                }
            }
        }
        [self.tableViewAnnouncement reloadData];
    }];
}

-(void)isConnecting
{
    NSLog(@"AlertInProgress::isConnecting");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        
        [self->_labelAnnouncementTitle setText:NSLocalizedString(@"connecting",nil)];
        //[_bottomButton setTitle:@"End Call" forState:UIControlStateNormal];
    }];
    
}


-(void)didConnect:(NSNotification *)notification
{
    
    int index = [[[notification userInfo] valueForKey:@"userinfo"] intValue];
    
    _currentCallIndex = index;
    NSLog(@"AlertInProgress::didConnect and Calling Contact #%d", _currentCallIndex);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        //[_labelAnnouncementTitle setText:NSLocalizedString(@"Connected...", nil)];
        [self->_labelAnnouncementTitle setText:NSLocalizedString(@"Call in Progress", nil)];
        //[cancelbutton setTitle:NSLocalizedString(@"End Call", nil) forState:UIControlStateNormal];
        [self.cancelAllBtn setTitle:NSLocalizedString(@"End Call", nil) forState:UIControlStateNormal];
        [self.tableViewAnnouncement reloadData];
        
    }];
    
    
    
}

-(void)didDisconnect:(NSNotification *)notification
{
    int index = [[[notification userInfo] valueForKey:@"userinfo"] intValue];
    NSLog(@"AlertInProgress::didDisconnect received while Calling Contact #%d", _currentCallIndex);
    _currentCallIndex = index;
    _isIncomingVOIPEnabled = [[[notification userInfo] valueForKey:@"isIncomingVOIPEnabled"] boolValue];
    _isCallInProgress = NO;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        [self->_labelAnnouncementTitle setText:NSLocalizedString(@"send sms-notification", nil)];
        [self.tableViewAnnouncement reloadData];
    }];
    
    //check sms count and put smssent =1
    if([[[ContactsData sharedConstants]arrSendTextMessage] count] ==0)
    {
        _smssentFlag = 1;
    }
    
    if(_currentCallIndex == 4
       && _smssentFlag ==1 )
    {
        if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue]  ==1)
        {
            if(_isIncomingVOIPEnabled == NO
               || [[[ContactsData sharedConstants]arrSendTextMessage] count] ==0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                {
                    [self->cancelAllBtn setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateNormal];
                }];
                
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self->cancelAllBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
                }];
            }
            
            if([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
            {
                [[commonnotifyalert alertConstant] repeatLocalNotify];
                AppDelegate*appDelegatObj =   APP_DELEGATE;
                appDelegatObj.repeatToneFlag =0;
            }
            else
            {
                [[commonnotifyalert alertConstant] repeatRingtone];
                AppDelegate*appDelegatObj =   APP_DELEGATE;
                appDelegatObj.repeatToneFlag =0;
            }
        }
    }
}

-(void)didReceiveIncomingCall:(NSNotification *)notification
{
     NSLog(@"AlertInProgress::didReceiveIncomingCall");
    _isCallInProgress = YES;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self->_labelAnnouncementTitle setText:NSLocalizedString(@"Incoming Call", nil)];
        
        [self->cancelAllBtn setTitle:NSLocalizedString(@"End Call", nil) forState:UIControlStateNormal];
        
        [self.tableViewAnnouncement reloadData];
        
    }];
}


- (void)didAnnouncementViewLoad:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)annonuncementSelect
{
    NSLog(@"AlertInProgress::didAnnouncementViewLoad");
    // Tracker : Check and Cancel if tracker view in progress
    if ([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
    {
        [self cancelAllActions];
    }
    _titleBar.backgroundColor = BRANDING_COLOR;
    
    [falldetectTimer invalidate];
    //VOIP - initialize the current call index
    //this is used to update the table with the active call
    _currentCallIndex = 0;
    
    //this is used to update the sms sent flag to 0 for before sending sms
    _smssentFlag =0;
    _smsFailure = 0;
    contactNames = [[NSMutableArray alloc]init];
    callcontactNames = [[NSMutableArray alloc]init];
    
    NSArray*enabledCalls = [[SharedData sharedConstants] getEnabledcalls];
    NSArray*enabledTexts = [[SharedData sharedConstants] getEnabledtexts];
    
    for( int i=0;i<[[[ContactsData sharedConstants]contactNames] count]>0;i++)
    {
        
        if(! [[[[ContactsData sharedConstants]contactNames] objectAtIndex:i] isEqualToString:TEXT_ADD_CONTACT] )
        {
            if([[enabledTexts objectAtIndex:i] isEqualToString:@"1"])
            {
                [contactNames addObject:[[[ContactsData sharedConstants]contactNames] objectAtIndex:i]];
            }
            if([[enabledCalls objectAtIndex:i] isEqualToString:@"1"])
            {
                [callcontactNames addObject:[[[ContactsData sharedConstants]contactNames] objectAtIndex:i]];
            }
        }
    }
    //check call or sms is selected
    [noContactsLbl setHidden:NO];
    noContactsLbl.text = NSLocalizedString(@"Enable a Contact with Text or Call to send an Alert", nil);
    if(  [[[ContactsData sharedConstants]arrSendTextMessage] count] >0 || [[[ContactsData sharedConstants]arrCallNumbers] count] >0)
    {
        [noContactsLbl setHidden:YES];
    }
    
    
    [DEFAULTS setObject:@"0" forKey:@"FallDetecct"];

    self.rootView = parentView;
    self.onAnnouncementSelect = annonuncementSelect;
    
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] init];
    int yaxis = (self.window.frame.size.height -440)/2;
    [transparentView setFrame:CGRectMake(0, yaxis,self.bounds.size.width, self.bounds.size.height-20)];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    [transparentView addSubview:self];
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)/2;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>2;
    
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    [self.window setFrame:CGRectMake(0, 0,self.bounds.size.width, self.bounds.size.height)];
    //self.window.windowLevel = UIWindowLevelAlert;
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    
    // Tracker : Set The Alert View Text and Button Action, and Show Table View
    self.labelAnnouncementTitle.text =NSLocalizedString(@"send sms-notification", nil);
    self.tableViewAnnouncement.hidden = NO;
    
    imgViewBackground.layer.cornerRadius = 7.0;
    imgViewBackground.layer.masksToBounds = YES;
    
    [cancelAllBtn setTitle:NSLocalizedString(@"cancel_all_progress", nil) forState:UIControlStateNormal];
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[parentView layer] addAnimation:animation forKey:@"layerAnimation"];
    self.alpha = 1.0f;
    [self.tableViewAnnouncement reloadData];
    
    
    if([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
    {
        [[commonnotifyalert alertConstant] repeatLocalNotify];
    }
    else
    {
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            
            [[commonnotifyalert alertConstant] repeatRingtone];
        }
    }
    
}

- (void)didAnnouncementfallLoad:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)announcementSelect
{
    // Tracker : Check and Cancel if tracker view in progress
    if ([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
    {
        [self cancelAllActions];
    }
    
    
    if([loadingView superview]==nil)
    {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(25, 200, 270, 150)];//  origional
        //loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)]; //testing
        loadingView.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        //Label properties
        loadingView.layer.cornerRadius = 7.0;
        loadingView.layer.borderColor = [UIColor blackColor].CGColor;
        loadingView.clipsToBounds = YES;
        
        falldetectLbl = [[UILabel alloc]initWithFrame:CGRectMake(55, 10, 160, 30)];
        falldetectLbl.backgroundColor = [UIColor clearColor];
        falldetectLbl.textAlignment = NSTextAlignmentCenter;
        falldetectLbl.text = NSLocalizedString(@"fall_detected", nil);
        //Label properties
        timerLbl = [[UILabel alloc]initWithFrame:CGRectMake(70, 40, 130, 30)];
        timerLbl.backgroundColor = [UIColor clearColor];
        timerLbl.textAlignment = NSTextAlignmentCenter;
        timerLbl.text =[NSString stringWithFormat:@"60 %@",NSLocalizedString(@"fall_detected-seconds", nil)];
        //button properties
        cancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelbutton setBackgroundColor:[UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1]];
        [cancelbutton addTarget:self
                         action:@selector(removeTranparentView)
               forControlEvents:UIControlEventTouchDown];
        [cancelbutton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        cancelbutton.frame = CGRectMake(90.0, 100.0, 80.0, 30.0);
        
        [loadingView addSubview:falldetectLbl];
        [loadingView addSubview:timerLbl];
        [loadingView addSubview:cancelbutton];
        [self.window addSubview:loadingView];
        [self.window makeKeyAndVisible];
        [UIView beginAnimations:@"fadeOutSync" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [loadingView setAlpha:0.9];
        [UIView commitAnimations];
        secondsLeft = 60;
        self.backgroundTask = UIBackgroundTaskInvalid;
        [self countdownTimer];
        
        if([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
        {
            [[commonnotifyalert alertConstant] repeatLocalNotify];
        }
        else
        {
            if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
            {
                
                [[commonnotifyalert alertConstant] repeatRingtone];
            }
        }
        
    }
    
}

#pragma mark -- Device Tracker Mathods
// Tracker: Show the popup when periferal Puck device get Disconnected
- (void)didAnnouncementDeviceConnect:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)announcementSelect
{
    
    if([deviceConnectionView superview]==nil)
    {
        self.rootView = parentView;
        self.onAnnouncementSelect = announcementSelect;
        [noContactsLbl setHidden:YES];
        //Add alertview into transparent view to hide parent view interaction
        UIView *transparentView = [[UIView alloc] init];
        int yaxis = (self.window.frame.size.height - 440)/2;
        [transparentView setFrame:CGRectMake(0, yaxis,self.bounds.size.width, self.bounds.size.height-20)];
        [transparentView setBackgroundColor:[UIColor clearColor]];
        [transparentView addSubview:self];
        float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)/2;
        float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>2;
        
        [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
        [self.window setFrame:CGRectMake(0, 0,self.bounds.size.width, self.bounds.size.height)];
        //self.window.windowLevel = UIWindowLevelAlert;
        [self.window addSubview:transparentView];
        [self.window makeKeyAndVisible];
        
        imgViewBackground.layer.cornerRadius = 7.0;
        imgViewBackground.layer.masksToBounds = YES;
        
        
        // Set up the fade-in animation
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [[parentView layer] addAnimation:animation forKey:@"layerAnimation"];
        self.alpha = 1.0f;
        
        self.labelAnnouncementTitle.text = NSLocalizedString(@"Tracker_in_progress", @"Tracker In Progress");// @"Tracker In Progress";
        self.tableViewAnnouncement.hidden = YES;
        [cancelAllBtn setTitle:NSLocalizedString(@"cancel_all_progress", nil) forState:UIControlStateNormal];
        
        [DEFAULTS setObject:@"ShowingYES" forKey:SHOWINGDISCONNECTEDDEVICEPOPUP];
        [DEFAULTS synchronize];
        
        
        
        //Stop notify the alert tracker tone
        if([UIApplication sharedApplication].applicationState ==UIApplicationStateBackground)
        {
            [[commonnotifyalert alertConstant] repeatTrackerNotify];
        }
        else
        {
            [[commonnotifyalert alertConstant] repeatTrackertone];
        }
        
    }
}
//Tracker : Will Vibrate the device
-(void)vibratePhone
{
    if ([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"] && _isKeepFlashOn){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self performSelector:@selector(vibratePhone) withObject:nil afterDelay:2.0];
    }
}


//Tracker : Cancel ALl Device tracking activity
-(void)cancelAllActions{
    
    [DEFAULTS setValue:@"ShowingNO" forKey:SHOWINGDISCONNECTEDDEVICEPOPUP];
    [DEFAULTS synchronize];
    //Stop notify the alert tracker tone
    [[commonnotifyalert alertConstant] stopNotify];
    [self removeFromSuperview];
    [self.window setHidden:YES];
}

//Tracker : Will Cancel The PopUp for disconnected Device
-(void)cancelAlertView
{
    [self cancelAllActions];
}


-(void)countdownTimer
{
    // secondsLeft = hours = minutes = seconds = 0;
    if([falldetectTimer isValid])
    {
        NSLog(@"TImer valid");
    }
    [falldetectTimer invalidate];
    timerLbl.hidden = NO;
    
    falldetectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
}

//Fall detect  value timer
-(void)updateCounter:(NSTimer *)theTimer
{
    if(secondsLeft > 0 )
    {
        NSLog(@"if");
        secondsLeft -- ;
        seconds = (secondsLeft %3600) % 60;
        timerLbl.text = [NSString stringWithFormat:@"%02d %@", seconds,NSLocalizedString(@"fall_detected-seconds", nil)];
        NSLog(@"Timer-%d",seconds);
    }
    else
    {
        [falldetectTimer invalidate];
        [loadingView removeFromSuperview];
        loadingView = nil;
        [self didAnnouncemntViewfallUnload];
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self selector:@selector(callkeyfall) userInfo:nil
                                        repeats:NO];
        
    }
}

-(void)callkeyfall
{
    
    [SharedData sharedConstants].fallDetection = 1;
    [[ContactsData sharedConstants] manageTextsandCalls];
    
    [DEFAULTS setObject:@"0" forKey:@"FallDetecct"];
    [DEFAULTS setValue:@"1" forKey:@"KeyPressed"];
    @try {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:keyFallNotification object:nil]; //
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", [exception description]);
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:[exception description] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

-(void)removeTranparentView
{
    [falldetectTimer invalidate];
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    
    [self didAnnouncemntViewUnload];
    [DEFAULTS setObject:@"0" forKey:@"FallDetecct"];
    
}
-(void)didAnnouncemntViewfallUnload
{
    [self cancelAllActions]; // Tracker : Reset all tracker values
    [self.superview removeFromSuperview];
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.rootView layer] addAnimation:animation forKey:@"layerAnimation"];
    self.window = nil;
    [DEFAULTS setObject:@"0" forKey:@"FallDetecct"];
}
-(void)didAnnouncemntViewUnload
{
    //check Tracker cancel and add status to the database
    if([[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"])
    {
        // Tracker : maintain The Log On Canceling The Tracker in progress
        dbConnect *dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        NSString *strID = [DEFAULTS valueForKey:CURRENTPERIFERALID];;
        strID = [strID substringFromIndex: [strID length] - 20];
        NSString *_date=[[SharedData sharedConstants] currentDate];
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"Tracker_Cancelled", nil)];
    }
    [DEFAULTS setValue:@"0" forKey:@"KeyPressed"];
    [self cancelAllActions]; // Tracker : Reset all tracker values
    
    [falldetectTimer invalidate];
    
    
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    NSLog(@"AlertInProgress::didAnnouncementViewUnLoad");
    
    //@TODO: check if we have a connection. If we do, then disconnect
    //If the remote party has already hung up, then we shouldn't need to call disconnect
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TCConnectionShouldDisconnect" object:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pucktonormal" object:nil];
    [self.superview performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    // Remove old notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllDeliveredNotifications];
    [center removeAllPendingNotificationRequests];
    
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.rootView layer] addAnimation:animation forKey:@"layerAnimation"];
    self.window = nil;
    
}

- (IBAction)actionDidHideAnnoucementList:(id)sender
{
    
    //@discussion ELG - May 13
    [[AVAudioSession sharedInstance] setActive:(NO) error:nil];
    [self didAnnouncemntViewUnload];
}

#pragma mark - Table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0)
    {
        
        return  [[[ContactsData sharedConstants]arrSendTextMessage] count];
        
        
    }
    else if (section == 1)
    {
        
        return [[[ContactsData sharedConstants]arrCallNumbers] count];
        
        
    }
    else if (section == 2)
    {
        
        if(_currentCallIndex >= 4 && _isIncomingVOIPEnabled == YES && _isCallInProgress == NO && [[[ContactsData sharedConstants]arrSendTextMessage] count]>0)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    
    
    cell.textLabel.textColor = TEXT_COLOR;
    cell.textLabel.font =TEXT_FONT_15;
    cell.textLabel.backgroundColor=[UIColor clearColor];
    
    if (indexPath.section == 0)
    {
        cell.textLabel.text= [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"sms-text", nil),[contactNames objectAtIndex:indexPath.row]];
        UIImage *image;
        if([SharedData sharedConstants].isReachable)
        {
            if(_smssentFlag ==1)
            {
                image = [UIImage   imageNamed:@"checkmark.png"] ;
                if(_smsFailure ==1)
                {
                    image = [UIImage   imageNamed:@"img_cancel.png"] ;
                }
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                CGRect frame = CGRectMake(0.0, 0.0, 25, 25);
                button.frame = frame;
                [button setBackgroundImage:image forState:UIControlStateNormal];
                button.backgroundColor = [UIColor clearColor];
                cell.accessoryView = button;
            }
        }
        else
        {
            
            image = [UIImage   imageNamed:@"img_cancel.png"] ;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, 25, 25);
            button.frame = frame;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            //  [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
        }
        
    }
    else if (indexPath.section == 1)
    {
        
        if([SharedData sharedConstants].isReachable)
        {
            if(indexPath.row == _currentCallIndex)
            {
                
                [cell.textLabel setAlpha:1.0];
                //Replace number to contact name
                cell.textLabel.text= [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"sms-call", nil),[callcontactNames objectAtIndex:indexPath.row]];
                
            }
            else if(indexPath.row < _currentCallIndex)
            {
                //[cell.textLabel setAlpha:0.5];
                //Replace number to contact name
                cell.textLabel.text= [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"called", nil),  [callcontactNames objectAtIndex:indexPath.row]];
                UIImage *image = [UIImage   imageNamed:@"checkmark.png"] ;
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                CGRect frame = CGRectMake(0.0, 0.0, 25, 25);
                button.frame = frame;
                [button setBackgroundImage:image forState:UIControlStateNormal];
                button.backgroundColor = [UIColor clearColor];
                cell.accessoryView = button;
            }
            else{
                //Replace number to contact name
                cell.textLabel.text= [NSString stringWithFormat:@"%@",[callcontactNames objectAtIndex:indexPath.row]];
            }
            
            
        }
        else
        {
            //Replace number to contact name
            cell.textLabel.text= [NSString stringWithFormat:@"%@",[callcontactNames objectAtIndex:indexPath.row]];
            UIImage *image = [UIImage   imageNamed:@"img_cancel.png"] ;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, 25, 25);
            button.frame = frame;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
        }
    }
    else if(indexPath.section == 2)
    {
        if(_currentCallIndex >= 4)
        {
            if(_isCallInProgress == NO)
            {
                cell.textLabel.text = NSLocalizedString(@"Ready for incoming call", nil);
            }
            else{
                cell.textLabel.text = @"";
            }
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}



-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    return YES;
}


//Send local notification when the device is disconnected/conneted/otherstatus
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ is %@",deviceName,deviceStatus];
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


- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
