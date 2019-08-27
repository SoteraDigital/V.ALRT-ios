#import "advanceview.h"
#import "systemsounds.h"
#import "Constants.h"
#import "SharedData.h"

@interface advanceview ()

@end

@implementation advanceview
@synthesize ObjBLEConnection;
enum {
    kValrtdeviceTag = 1,
    kPhoneTag,
};
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
    _advanceTitle.textColor = BRANDING_COLOR;
    _alertSoundBar.backgroundColor = BRANDING_COLOR;
    _silentModeBar.backgroundColor = BRANDING_COLOR;
    _silentModeTextLbl.text = NSLocalizedString(@"settings_disabledescription", nil);
    NSUInteger languageSelction = [DEFAULTS integerForKey:@"language"];
    if (languageSelction>0)
    {
        [skipBtn setHidden:YES];
    }
    //Objeconnection for bleconnection class
    ObjBLEConnection =[[BLEConnectionClass alloc]init];
    
    _date=[[SharedData sharedConstants] currentDate];
    dConnect = [[dbConnect alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    //text change for label
    [self languagetranslate];

    //Bind the ringtone text
    if ([DEFAULTS objectForKey:ALERT_RINGTONE_NAME] == nil)
    {
        [DEFAULTS setObject:TEMPORARY_RINGTONE_NAME forKey:ALERT_RINGTONE_NAME];
        [DEFAULTS setObject:TEMPORARY_RINGTONE_ID forKey:ALERT_RINGTONE_ID];
        [DEFAULTS setObject:TEMPORARY_SOUND_NAME forKey:ALERT_SOUND_NAME];
        alertsoundLbl.text = [DEFAULTS objectForKey:ALERT_RINGTONE_NAME];
    }
    else
    {
        alertsoundLbl.text = [DEFAULTS objectForKey:ALERT_RINGTONE_NAME];
    }
    //Check Silent mode for device and phone
    if ([DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
    {
        [deviceSilentBtn setSelected:YES];
    }
    if ([DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
    {
        [phoneSilentBtn setSelected:YES];
    }
    //Set selected/Normal for panic sound
    if([DEFAULTS objectForKey:IS_PANIC_SOUND_ENABLE] !=nil)
    {
        ((UIButton*)[self.view viewWithTag:10]).selected = [DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE];
        [alertsoundLbl setEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
        [alertsoundLbl setUserInteractionEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
        [arrowBtn setEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
        [arrowBtn setUserInteractionEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
    }
    else
    {
        [DEFAULTS setBool:YES forKey:IS_PANIC_SOUND_ENABLE];
        ((UIButton*)[self.view viewWithTag:10]).selected = [DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE];
        [alertsoundLbl setEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
        [alertsoundLbl setUserInteractionEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
        [arrowBtn setEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
        [arrowBtn setUserInteractionEnabled:![DEFAULTS boolForKey:IS_PANIC_SOUND_ENABLE]];
    }
    
}
/*!
 *  @method languagetranslate
 *  @discussion language translate for labels and button.
 *
 */
-(void)languagetranslate
{
    alertsoundDftLbl.text = NSLocalizedString(@"settings_alerttitle", nil);
    alertsoundLbl.text = NSLocalizedString(@"settings_alertstring", nil);
    phoneapplnmodeLbl.text = NSLocalizedString(@"settings_disablephone", nil);
    silentmodeLbl.text = NSLocalizedString(@"settings_disabletitle", nil);
    valrtdevicemodeLbl.text = NSLocalizedString(@"settings_disabledevice", nil);
    
}

/*!
 *  @method tapGestureAlertSound:
 *
 *  @param p sender to read from
 *
 *  @discussion load the default system sound and select the sound ,bind the selected sound the alert sound label
 *
 */
- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapGestureAlertSound:(id)sender
{
    
    systemsounds*systemObj = [[systemsounds alloc]init];
    UINavigationController*navObj = [[UINavigationController alloc]initWithRootViewController:systemObj];
    [self presentViewController:navObj animated:YES completion:nil];
    
}
/*!
 *  @method tapPanicSound:
 *
 *  @param p sender to read from
 *
 *  @discussion Check panic is selected or not ,based on the that enable/disable the default sound
 *
 */
- (IBAction)tapPanicSound:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [DEFAULTS setBool:sender.selected forKey:IS_PANIC_SOUND_ENABLE];
    [alertsoundLbl setUserInteractionEnabled:!sender.selected];
    [alertsoundLbl setEnabled:!sender.selected];
    [arrowBtn setEnabled:!sender.selected];
    [arrowBtn setUserInteractionEnabled:!sender.selected];
}
- (IBAction)taplabelClcikPanicSound:(id)sender
{
    [self tapPanicSound:(id)[self.view viewWithTag:10]];
}

/*!
 *  @method didActionValertDeviceSilentMode:
 *
 *  @param p sender to read from
 *
 *  @discussion put the v.alrt device to silent mode or remove the v.alrt device from silent mode
 *
 */
- (IBAction)didActionValertDeviceSilentMode:(id)sender
{
    
    /* Write value to the database to tell the device mode is on or off */
    
    
    //Ends
    if (![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
    {
        [DEFAULTS setBool:YES forKey:DISABLE_VALERTDEVICE_SILENT];
        [deviceSilentBtn setSelected:YES];
        //silent mode
        for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
        {
            [ObjBLEConnection silentNormalmode:0x03 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
        //insert the device connection status
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Device silent mode on", nil)];
    }
    else
    {
        [DEFAULTS setBool:NO forKey:DISABLE_VALERTDEVICE_SILENT];
        [deviceSilentBtn setSelected:NO];
        //Normal mode
        for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
        {
            [ObjBLEConnection silentNormalmode:0x00 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
        //insert the device connection status
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Device silent mode off", nil)];
    }
    [DEFAULTS synchronize];
    
    
}

/*!
 *  @method didActionPhoneApplicationSilentMode:
 *
 *  @param p sender to read from
 *
 *  @discussion put the phone to silent mode or remove the phone from silent mode
 *
 */
- (IBAction)didActionPhoneApplicationSilentMode:(id)sender
{
    
    
    UIAlertView *alertBox;
    if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
    {
        if ([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND])
        {
            alertMsg = NSLocalizedString(@"Tracker_Loud_Alert_will_be_turned_off", nil);
            alertBox = [[UIAlertView alloc]initWithTitle:@"" message:alertMsg delegate:self cancelButtonTitle:NSLocalizedString(@"Tracker_cancel", nil) otherButtonTitles:NSLocalizedString(@"Tracker_accept", nil), nil];
            //user feedback chnages starts
            alertBox.tag=kPhoneTag;
            [alertBox show];
        }
        else
        {
            if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
            {
                [DEFAULTS setBool:YES forKey:DISABLE_PHONEAPPLICATION_SILENT];
                // Tracker : Set the tracker off both Tone and Vibration
                [DEFAULTS setBool:NO forKey:DEVICE_TRAKING_SOUND];
                [DEFAULTS setBool:([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] || [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION]) forKey:IS_DEVICE_TRAKING_FEATURE_ON];
                [DEFAULTS synchronize];
                [phoneSilentBtn setSelected:YES];
                
                //add the status to the database dat device is in phone is silent mode.
                [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Application silent mode on", nil)];
            }
            else
            {
                [DEFAULTS setBool:NO forKey:DISABLE_PHONEAPPLICATION_SILENT];
                [phoneSilentBtn setSelected:NO];
                //add the status to the database dat device is in phone is not in silent mode.
                [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Application silent mode off", nil)];
            }
            [DEFAULTS synchronize];
        }
        
        
    }
    else
    {
        
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            [DEFAULTS setBool:YES forKey:DISABLE_PHONEAPPLICATION_SILENT];
            
            // Tracker : Set the tracker Tone Off
            [DEFAULTS setBool:NO forKey:DEVICE_TRAKING_SOUND];
            [DEFAULTS setBool:([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] || [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION]) forKey:IS_DEVICE_TRAKING_FEATURE_ON];
            [DEFAULTS synchronize];
            [phoneSilentBtn setSelected:YES];
            
            //add the status to the database dat device is in phone is silent mode.
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Application silent mode on", nil)];
        }
        else
        {
            [DEFAULTS setBool:NO forKey:DISABLE_PHONEAPPLICATION_SILENT];
            [phoneSilentBtn setSelected:NO];
            //add the status to the database dat device is in phone is not in silent mode.
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Application silent mode off", nil)];
        }
        [DEFAULTS synchronize];
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
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kValrtdeviceTag:
            if(buttonIndex == kValrtdeviceTag)
            {
                if (![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
                {
                    [DEFAULTS setBool:YES forKey:DISABLE_VALERTDEVICE_SILENT];
                    [deviceSilentBtn setSelected:YES];
                    //silent mode
                    for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
                    {
                        [ObjBLEConnection silentNormalmode:0x03 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
                    }
                }
                else
                {
                    [DEFAULTS setBool:NO forKey:DISABLE_VALERTDEVICE_SILENT];
                    [deviceSilentBtn setSelected:NO];
                    //Normal mode
                    for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
                    {
                        [ObjBLEConnection silentNormalmode:0x00 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
                    }
                    
                }
                [DEFAULTS synchronize];
            }
            break;
        case kPhoneTag:
            if(buttonIndex == kValrtdeviceTag)
            {
                if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
                {
                    [DEFAULTS setBool:YES forKey:DISABLE_PHONEAPPLICATION_SILENT];
                    // Tracker : Set the tracker off both Tone and Vibration
                    [DEFAULTS setBool:NO forKey:DEVICE_TRAKING_SOUND];
                    [DEFAULTS synchronize];
                    [DEFAULTS setBool:([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] || [DEFAULTS boolForKey:DEVICE_TRAKING_VIBRATION]) forKey:IS_DEVICE_TRAKING_FEATURE_ON];
                    [DEFAULTS synchronize];
                    
                    [phoneSilentBtn setSelected:YES];
                    
                    //add the status to the database dat device is in phone is  in silent mode.
                    [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Application silent mode on", nil)];
                    
                    //add the status to the database dat device is in phone is not in silent mode.
                    [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:@"V.ALRT" bleAddress:@"Address" bleStatus:NSLocalizedString(@"Tracker loud tone off", nil)];
                    
                }
                else
                {
                    [DEFAULTS setBool:NO forKey:DISABLE_PHONEAPPLICATION_SILENT];
                    [phoneSilentBtn setSelected:NO];
                }
                [DEFAULTS synchronize];
            }
            break;
        default:
            break;
    }
    
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
