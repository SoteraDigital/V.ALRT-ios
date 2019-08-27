#import "vsnsettingsviewcontroller.h"
#import "Constants.h"
#import "SharedData.h"
#import "systemsounds.h"
#import "ContactsData.h"
#import "customAlertPopUp.h"
#import "AnnoncementView.h"
#import "ConfirmationView.h"
#import "ManageDevicesViewController.h"
#import "commonnotifyalert.h"
#define maxx_length 55

@interface vsnsettingsviewcontroller ()

@end

@implementation vsnsettingsviewcontroller
@synthesize viewShowAlertMessage,txtFieldEnterAlertMessage,viewShowPersonalinfo,normalPeriperal;
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
    
    //Customizing the views
    //Background for messageview
    viewShowAlertMessage.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_tansparent_background.png"]];
    viewShowPersonalinfo.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_tansparent_background.png"]];

    //Add Observer for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    //Objeconnection for bleconnection class
    ObjBLEConnection =[[BLEConnectionClass alloc]init];
    [ObjBLEConnection controlSetup:1]; // Do initial setup of BLE class.
    ObjBLEConnection.delegate = self;
    

}

-(void)viewWillAppear:(BOOL)animated
{
    //text change for label
    [self languagetranslate];
    
    //Bind the contacts
    [self bindContactsandcall];
    
    //Bind the text and call
    [self bindEnabletextCall];
    
    //Check First flow has done and remove the next button
    if ([[DEFAULTS valueForKey:@"devicesDone"] isEqualToString:@"set"])
    {
        [nextBtn removeFromSuperview];
    }
    if(![LANGUAGE isEqualToString:@"en"])
    {
        [nextBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0,0 )];
    }
     [self checkEnableNextbtn];
    [self drawLines];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 *  @method languagetranslate:
 *  @discussion binding the text to label
 *
 */
-(void)languagetranslate
{
    navLbl.text = NSLocalizedString(@"settings_title", nil);
    contactLbl.text = NSLocalizedString(@"settings_contact", nil);
    txtLbl.text = NSLocalizedString(@"settings_text", nil);
    callLbl.text = NSLocalizedString(@"settings_calls", nil);
    alertsoundDftLbl.text = NSLocalizedString(@"settings_alerttitle", nil);
    alertsoundLbl.text = NSLocalizedString(@"settings_alertstring", nil);
    msgDefaultLbl.text = NSLocalizedString(@"settings_message", nil);
    messageDescLbl.text = NSLocalizedString(@"settings_messagedescription", nil);
    phoneapplnmodeLbl.text = NSLocalizedString(@"settings_disablephone", nil);
    silentmodeLbl.text = NSLocalizedString(@"settings_disabletitle", nil);
    valrtdevicemodeLbl.text = NSLocalizedString(@"settings_disabledevice", nil);
    addeditLbl.text =NSLocalizedString(@"settings-personel-add", nil);
    personalInfoLbl.text =  NSLocalizedString(@"settings-personel", nil);
    personalinfoTitleLbl.text =  NSLocalizedString(@"settings-personel", nil);
    messagetitleLbl.text = NSLocalizedString(@"settings alert_message", nil);
    [backBtn setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    [nextBtn setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];

    if([DEFAULTS objectForKey:@"userName"] !=nil)
    {
        addeditLbl.text =NSLocalizedString(@"personellabel-edit", nil);
        [saveBtn setTitle:NSLocalizedString(@"keyboard-apply", nil) forState:UIControlStateNormal];
        
    }
    
    //Bind the message text
    if ([DEFAULTS objectForKey:ALERT_MESSAGE] == nil)
    {
        [DEFAULTS setObject:TEMPORARY_ALERT_MESSAGE forKey:ALERT_MESSAGE];
        messageLbl.text = [DEFAULTS objectForKey:ALERT_MESSAGE];
    }
    else
    {
        messageLbl.text = [DEFAULTS objectForKey:ALERT_MESSAGE];
    }
    
    //Bind the ringtone text
    if ([DEFAULTS objectForKey:ALERT_RINGTONE_NAME] == nil)
    {
        [DEFAULTS setObject:TEMPORARY_RINGTONE_NAME forKey:ALERT_RINGTONE_NAME];
        [DEFAULTS setObject:TEMPORARY_RINGTONE_ID forKey:ALERT_RINGTONE_ID];
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
}

/*!
 *  @method bindContactsandcall:
 *  @discussion binding the contacts to label
 */

-(void)bindContactsandcall
{
    //Key Archiver for contact name
    NSData *dataRepresentingSavedNameArray = [DEFAULTS objectForKey:CONTACT_NAMES];
    NSArray *defaultNames = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedNameArray];
    
    if (defaultNames != nil)
    {
        [ContactsData sharedConstants].contactNames = [[NSMutableArray alloc] initWithArray:defaultNames];
    }
    
    //Key Archiver for contact numbers
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:CONTACT_NUMBERS];
    NSArray *defaultContacts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    if (defaultContacts != nil)
    {
        [ContactsData sharedConstants].contactNumbers = [[NSMutableArray alloc] initWithArray:defaultContacts];
    }

    for (int i=0; i<[ContactsData sharedConstants].contactNames.count; i++)
    {
        UIButton * contactBtn =(UIButton *) [self.view viewWithTag:i+1];
        UILabel * addcontactsLbl =(UILabel *) [self.view viewWithTag:i+10];
        [addcontactsLbl setText:[[ContactsData sharedConstants].contactNames objectAtIndex:i]];
        if([[[ContactsData sharedConstants].contactNames objectAtIndex:i] isEqualToString:TEXT_ADD_CONTACT])
        {
            [contactBtn setSelected:NO];
            [addcontactsLbl setText:NSLocalizedString(@"Tap to add contact",nil)];
            
        }
        else
        {
             [contactBtn setSelected:YES];
        }
        
    }
    
}

/*!
 *  @method bindEnabletextCall:
 *  @discussion binding the Enable Text and call
 */
-(void)bindEnabletextCall
{
    //Enabled Calls
    NSData *dataRepresentingCallArray = [DEFAULTS objectForKey:ENABLED_CALLS];
    NSArray *defaultCalls = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCallArray];
    if (defaultCalls != nil){
        [SharedData sharedConstants].arrEnabledCalls = [[NSMutableArray alloc] initWithArray:defaultCalls];
    }

    //Enabled Texts
    NSData *dataRepresentingTextArray = [DEFAULTS objectForKey:ENABLED_TEXTS];
    NSArray *defaultTexts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingTextArray];
    if (defaultTexts != nil)
    {
        [SharedData sharedConstants].arrEnabledTexts = [[NSMutableArray alloc] initWithArray:defaultTexts];
    }
    
    
    //Text/Call Enable Code
    for(int i=0;i<[SharedData sharedConstants].arrEnabledTexts.count;i++)
    {
        
        //Text
        UIButton * textBtn =(UIButton *) [self.view viewWithTag:i+4];
        if([[[SharedData sharedConstants].arrEnabledTexts objectAtIndex:i] isEqualToString:@"0"])
        {
            [textBtn setSelected:NO];
        }
        else
        {
            [textBtn setSelected:YES];
            
        }
        
        //Call
        UIButton * callBtn =(UIButton *) [self.view viewWithTag:i+7];
        if([[[SharedData sharedConstants].arrEnabledCalls objectAtIndex:i] isEqualToString:@"0"])
        {
            [callBtn setSelected:NO];
        }
        else
        {
            [callBtn setSelected:YES];
            
        }
    }
    
 
}

/*!
 *  @method contactAction:
 *
 *  @param p sender to read from
 *
 *  @discussion add the contact/remove the contact
 *
 */

- (IBAction)contactAction:(id)sender
{
 UIButton * contactBtn =(UIButton *) [self.view viewWithTag:[sender tag]];
    if([contactBtn isSelected])
    {
        [self removeContact:[sender tag]-1];
    }
    else
    {
        [self addContact:[sender tag]];
        //[contactBtn setSelected:YES];
    }
}

/*!
 *  @method addContact:
 *
 *  @param p tagIndex to read tag index value
 *
 *  @discussion add contact from the contacts picker
 */
-(void)addContact:(int)tagIndex
{
    NSData *dataRepresentingSavedNameArray = [DEFAULTS objectForKey:CONTACT_NAMES];
    NSArray *defaultNames = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedNameArray];
    if (defaultNames != nil)
    {
        [ContactsData sharedConstants].contactNames = [[NSMutableArray alloc] initWithArray:defaultNames];
    }
    pickContactViewController = [[ABPeoplePickerNavigationController alloc] init];
    pickContactViewController.peoplePickerDelegate = self;
    [self.view addSubview:pickContactViewController.view];
    currentIndex = tagIndex-1;
}

/*!
 *  @method removeContact:
 *
 *  @param p tagIndex to read tag index value
 *
 *  @discussion remove contact from the contacts picker
 */
-(void)removeContact:(int)tagIndex
{
        [[ConfirmationView sharedInstance] didConfirmationViewLoad:self.view andConfirmationViewTitle:NSLocalizedString(@"Are you sure Do you want to remove the selected contact?", nil)  andConfirmationViewContent:@"" andConfirmationViewCallback:^(BOOL onConfirm) {
            if(onConfirm)
            {
                 [[ContactsData sharedConstants].contactNumbers replaceObjectAtIndex:tagIndex withObject:TEXT_ADD_CONTACT];
                [[ContactsData sharedConstants].contactNames replaceObjectAtIndex:tagIndex withObject:TEXT_ADD_CONTACT];
                [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:tagIndex withObject:@"0"];
                [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:tagIndex withObject:@"0"];
                [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
                [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledCalls] forKey:ENABLED_CALLS];
                [DEFAULTS synchronize];
               
                //Save the contacts
                [self saveContacts];
                
                UIButton * contactBtn =(UIButton *) [self.view viewWithTag:tagIndex+1];
                UIButton * textBtn =(UIButton *) [self.view viewWithTag:tagIndex+4];
                UIButton * callBtn =(UIButton *) [self.view viewWithTag:tagIndex+7];
                //Bind the text to the label
                UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:tagIndex+10];
               // [addcontactsLbl setText: [[ContactsData sharedConstants].contactNames objectAtIndex:tagIndex]];
                [addcontactsLbl setText:NSLocalizedString(@"Tap to add contact",nil)];
                [contactBtn setSelected:NO];
                [textBtn setSelected:NO];
                [callBtn setSelected:NO];
            }
        }];
        
}

/*!
 *  @method textAction:
 *
 *  @param p sender to read from
 *
 *  @discussion check the selected text(sms) for contact added/remove the text(sms) for the selected contact
 *
 */
- (IBAction)textAction:(id)sender {

    UIButton * textBtn =(UIButton *) [self.view viewWithTag:[sender tag]];
    if([textBtn isSelected])
    {
        [textBtn setSelected:NO];
        
    }
    else
    {
        if([self checkEnable:[sender tag]-4])
        {
            [textBtn setSelected:YES];
        }
        else
        {
            [[SharedData sharedConstants] alertMessage:@"" msg:NSLocalizedString(@"Add Contact to Enable Texts and Calls", nil)];
        }
    }
    
    [self enabledisableText:[sender tag]];
    
}

/*!
 *  @method enabledisableText:
 *
 *
 *  @discussionEnable/Disable the text
 *
 */
-(void)enabledisableText:(int)tagIndex
{

   if(! [[[ContactsData sharedConstants].contactNames objectAtIndex:tagIndex-4] isEqualToString:TEXT_ADD_CONTACT])
   {
       if ([[[SharedData sharedConstants].arrEnabledTexts objectAtIndex:tagIndex-4]isEqualToString:@"0"])
       {
           [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:tagIndex-4 withObject:@"1"];
       }
       else
       {
           [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:tagIndex-4 withObject:@"0"];
       }
       [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
       [DEFAULTS synchronize];
   }
    
    //Check all required field to enable the next btn
    [self checkEnableNextbtn];
}

/*!
 *  @method enabledisableCall:
 *
 *
 *  @discussionEnable/Disable the call
 *
 */
-(void)enabledisableCall:(int)tagIndex
{
    if(! [[[ContactsData sharedConstants].contactNames objectAtIndex:tagIndex-7] isEqualToString:TEXT_ADD_CONTACT])
    {
        if ([[[SharedData sharedConstants].arrEnabledCalls objectAtIndex:tagIndex-7] isEqualToString:@"0"])
        {
            [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:tagIndex-7 withObject:@"1"];
        }
        else
        {
            [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:tagIndex-7 withObject:@"0"];
        }
        
        [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledCalls] forKey:ENABLED_CALLS];
        [DEFAULTS synchronize];
    }
    
    //Check all required field to enable the next btn
    [self checkEnableNextbtn];
}

/*!
 *  @method callAction:
 *
 *  @param p sender to read from
 *
 *  @discussion check the selected call for contacts added/remove the call for the selected contact
 *
 */

- (IBAction)callAction:(id)sender
{
    UIButton * callBtn =(UIButton *) [self.view viewWithTag:[sender tag]];
    if([callBtn isSelected])
    {
        [callBtn setSelected:NO];
    }
    else
    {
        if([self checkEnable:[sender tag]-7])
        {
            [callBtn setSelected:YES];
        }
        else
        {
             [[SharedData sharedConstants] alertMessage:@"" msg:NSLocalizedString(@"Add Contact to Enable Texts and Calls", nil)];
        }
    }

     [self enabledisableCall:[sender tag]];
}

/*!
 *  @method cancelAction:
 *
 *  @param p sender to read from
 *
 *  @cancel the personal view popup
 *
 */
- (IBAction)cancelAction:(id)sender
{
    [viewShowPersonalinfo removeFromSuperview];
    [self checkEnableNextbtn];
}

/*!
 *  @method backAction:
 *
 *  @param p sender to read from
 *
 *  @Dismiss the view
 *
 */
- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 *  @method saveAction:
 *
 *  @param p sender to read from
 *
 *  @save the name and phone number and close the popup
 *
 */
- (IBAction)saveAction:(id)sender
{
    NSString *nameStr = nameField.text;
    int nameLen=[nameStr length];
    
    NSString *phoneStr = phoneField.text;
    int phoneLen=[phoneStr length];
    
    if([nameField.text isEqualToString:@""] && [phoneField.text isEqualToString:@""])
    {
         [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personelmsg", nil)];
    }
    else if((phoneLen==0)|| (phoneLen <8) )
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
   
    }
    else if( (![self checkIfUsernameValidation]) || nameLen<1)
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-namemsg", nil) ];
    }
    else
    {
        //Save username and password in defaults
        [DEFAULTS setObject:nameField.text forKey:@"userName"];
        [DEFAULTS setObject:phoneField.text forKey:@"phonenumber"];
        [DEFAULTS synchronize];
        nameField.text=[NSString stringWithFormat:@"%@", [DEFAULTS objectForKey:@"userName"]];
        phoneField.text=[NSString stringWithFormat:@"%@", [DEFAULTS objectForKey:@"phonenumber"]];
        addeditLbl.text =NSLocalizedString(@"personellabel-edit", nil);
        [saveBtn setTitle:NSLocalizedString(@"keyboard-apply", nil) forState:UIControlStateNormal];
        //Remove from view
        [viewShowPersonalinfo removeFromSuperview];
        [self checkEnableNextbtn];
    }

}

/*!
 *  @method nextAction:
 *
 *  @param p sender to read from
 *
 *  @discussion present to next view if all required filed are fllled
 *
 */
- (IBAction)nextAction:(id)sender
{
    if(btnNextFlag ==1)
    {
        UIStoryboard *storyboard = IPHONE_STORYBOARD;
        ManageDevicesViewController *ObjManageDevicesViewController;
        ObjManageDevicesViewController = [storyboard instantiateViewControllerWithIdentifier:@"ManageDevicesViewController"];
        ObjManageDevicesViewController.ObjBLEConnection = ObjBLEConnection;
        [self presentViewController:ObjManageDevicesViewController animated:YES completion:nil];
    }
    else
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings_title",nil)  msg:NSLocalizedString(@"personel-alert-msg", nil)];
    }
}
/*!
 *  @method tapGestureAlertSound:
 *
 *  @param p sender to read from
 *
 *  @discussion load the default system sound and select the sound ,bind the selected sound the alert sound label
 *
 */
- (IBAction)tapGestureAlertSound:(id)sender
{

    systemsounds*systemObj = [[systemsounds alloc]init];
    UINavigationController*navObj = [[UINavigationController alloc]initWithRootViewController:systemObj];
    [self presentViewController:navObj animated:YES completion:nil];
    
}
/*!
 *  @method tapGestureAlertMessage:
 *
 *  @param p sender to read from
 *
 *  @discussion open the popup to bind the message for alert message
 *
 */
- (IBAction)tapGestureAlertMessage:(id)sender
{
 
    [txtFieldEnterAlertMessage becomeFirstResponder];
    
    txtFieldEnterAlertMessage.text = [DEFAULTS objectForKey:ALERT_MESSAGE];
    
    [self.view addSubview:viewShowAlertMessage];
    
}

/*!
 *  @method tapGesturePersonalInfo:
 *
 *  @param p sender to read from
 *
 *  @discussion open the popup to get the personal information
 *
 */
- (IBAction)tapGesturePersonalInfo:(id)sender
{
    
    if( [DEFAULTS objectForKey:@"userName"] ==nil)
    {
            nameField.text = @"";
            phoneField.text= @"";
    }
    else
    {
        nameField.text=[NSString stringWithFormat:@"%@", [DEFAULTS objectForKey:@"userName"]];
        phoneField.text=[NSString stringWithFormat:@"%@", [DEFAULTS objectForKey:@"phonenumber"]];
    }
    [self.view addSubview:viewShowPersonalinfo];
    
    //Draw lines
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 110.0)];
    [path addLineToPoint:CGPointMake(300, 110.0)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    [personalInfoSubview.layer addSublayer:shapeLayer];
    
    //Draw lines
    UIBezierPath *verticalpath = [UIBezierPath bezierPath];
    [verticalpath moveToPoint:CGPointMake(150.0,110.0)];
    [verticalpath addLineToPoint:CGPointMake(150.0, 150.0)];
    CAShapeLayer *verticalshapeLayer = [CAShapeLayer layer];
    verticalshapeLayer.path = [verticalpath CGPath];
    verticalshapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    verticalshapeLayer.lineWidth = 1.0;
    [personalInfoSubview.layer addSublayer:verticalshapeLayer];
    
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
    
    if (![DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
    {
        alertMsg = NSLocalizedString(@"valert_checked_message", nil);
        alertTitle = NSLocalizedString(@"valert_alert_checked_title", nil);
    }
    else
    {
        alertMsg = NSLocalizedString(@"valert_unchecked_message", nil);
        alertTitle = NSLocalizedString(@"valert_alert_unchecked_title", nil);
    }
    
    UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil) otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
    alertBox.tag=kValrtdeviceTag;
    [alertBox show];
    
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
    if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
    {
        
        alertMsg = NSLocalizedString(@"phone_checked_message", nil);
        alertTitle = NSLocalizedString(@"valert_alert_checked_title", nil);
    }
    else
    {
        
        alertMsg = NSLocalizedString(@"phone_unchecked_message", nil);
        alertTitle = NSLocalizedString(@"valert_alert_unchecked_title", nil);
    }
    
    //user feedback chnages starts
    UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil) otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
    alertBox.tag=kPhoneTag;
    [alertBox show];

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
                    [phoneSilentBtn setSelected:YES];
                    
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

#pragma mark - TextviewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //trimmed the text string in text view
    NSString *rawString = [textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    
    [DEFAULTS setObject:[txtFieldEnterAlertMessage.text stringByTrimmingCharactersInSet:whitespace] forKey:ALERT_MESSAGE];
    [DEFAULTS synchronize];
    
    //Bind the text and remove from textview
    messageLbl.text = [DEFAULTS objectForKey:ALERT_MESSAGE];
    
    if([text isEqualToString:@"\n"] && [trimmed length] != 0)
    {
        NSUInteger new = [textView.text length] + [text length] - range.length;
        if(new > maxx_length)
        {
            return NO;
        }
        else
        {
            [viewShowAlertMessage removeFromSuperview];
            [textView resignFirstResponder];
            [self checkEnableNextbtn];
            return  YES;
        }
        
    }
        return YES;
}

#pragma mark - Validation
/*!
 *  @method checkEnable:
 *
 *
 *  @discussion find the contact is already added not then return no
 *
 */

-(BOOL)checkEnable:(int)tagIndex
{
    if([[[ContactsData sharedConstants].contactNames objectAtIndex:tagIndex] isEqualToString:TEXT_ADD_CONTACT] )
    {
        return NO;
    }
    return YES;
}


-(BOOL)checkIfUsernameValidation
{
    
    NSString *_username = nameField.text;
    NSCharacterSet * set = [[NSCharacterSet    characterSetWithCharactersInString:@".!#$%&'*+-/=?^_`{|}~@,;"] invertedSet];
    if ([_username rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        return YES;
    }
    else
        return NO;
}

- (BOOL)validPhone:(NSString*) phoneString
{
    
    if ([[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, [phoneString length]) phoneNumber:phoneString] resultType] == NSTextCheckingTypePhoneNumber)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)checkEnableNextbtn
{
    //Check all required fields and update the button flag
    if (![[DEFAULTS objectForKey:@"phonenumber"] isEqualToString:@""] && ![[DEFAULTS objectForKey:@"phonenumber"] isEqual:[NSNull null]] &&[DEFAULTS objectForKey:@"phonenumber"] !=nil &&([[SharedData sharedConstants].arrEnabledCalls containsObject:@"1"] || [[SharedData sharedConstants].arrEnabledTexts containsObject:@"1"]) && ![[DEFAULTS valueForKey:ALERT_MESSAGE] isEqualToString:@""] )
    {
        btnNextFlag =1;
    }
    else
    {
        btnNextFlag =0;
    }
}

#pragma mark - Keyboard Observers-(show/hide)

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = personalInfoSubview.frame;
        CGSize result1 = [[UIScreen mainScreen] bounds].size;
        if(result1.height == 480)
        {
            f.origin.y =  70.f;
        }
        else
        {
            f.origin.y =  140.f;
        }
        personalInfoSubview.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = personalInfoSubview.frame;
        CGSize result1 = [[UIScreen mainScreen] bounds].size;
        if(result1.height == 480)
        {
            f.origin.y =  160.f;
        }
        else
        {
            f.origin.y =  200.f;
        }
        personalInfoSubview.frame = f;
    }];
}

#pragma  mark-TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark-Contact picker delegates

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSArray *contactnum = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
    CFRelease(phoneNumberProperty);
    
    NSString *contactname = (__bridge NSString *)ABRecordCopyCompositeName(person);
    
    if ([ContactsData sharedConstants].contactNumbers.count == 0)
    {
        NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:CONTACT_NUMBERS];
        if (dataRepresentingSavedArray != nil)
        {
            NSArray *defaultContacts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
            if (defaultContacts != nil){
                [ContactsData sharedConstants].contactNumbers = [[NSMutableArray alloc] initWithArray:defaultContacts];
            }
            
        }
        
    }
    
    [pickContactViewController.view removeFromSuperview];
    switch ([contactnum count])
    {
        case 0:
            [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:LABEL_CUSTOMALERT_NOCONTACTS];
            break;
        case 1:
            [[ContactsData sharedConstants].contactNames replaceObjectAtIndex:currentIndex withObject:contactname];
            [[ContactsData sharedConstants].contactNumbers replaceObjectAtIndex:currentIndex withObject:[contactnum objectAtIndex:0]];
            [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:currentIndex withObject:@"1"];
            [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
            [DEFAULTS synchronize];
            //Save the contacts
            [self saveContacts];
            break;
        default:
            [[SharedData sharedConstants].arrSelectMultipleContacts removeAllObjects];
            [[SharedData sharedConstants].arrSelectMultipleContacts addObjectsFromArray:contactnum];
            [[AnnoncementView sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId)
             {
                 
                 [[ContactsData sharedConstants].contactNumbers replaceObjectAtIndex:currentIndex withObject:[SharedData sharedConstants].strDidSelectContacts];
                 [[ContactsData sharedConstants].contactNames replaceObjectAtIndex:currentIndex withObject:contactname];
                 [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:currentIndex withObject:@"1"];
                 [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
                 [DEFAULTS synchronize];
                 [self saveContacts];
                 UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:currentIndex+10];
                 [addcontactsLbl setText:[[ContactsData sharedConstants].contactNames objectAtIndex:currentIndex]];
             }];
            break;
    }
   
    if([contactnum count] !=0)
    {
        //Contact button
        UIButton * contactBtn =(UIButton *) [self.view viewWithTag:currentIndex+1];
        [contactBtn setSelected:YES];
        //Enable Text Btn
        UIButton * textBtn =(UIButton *) [self.view viewWithTag:currentIndex+4];
        [textBtn setSelected:YES];
    }
    //Bind the text to the label
    UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:currentIndex+10];
        [addcontactsLbl setText:[[ContactsData sharedConstants].contactNames objectAtIndex:currentIndex]];
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [pickContactViewController.view removeFromSuperview];
    
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker    shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
    return NO;
    
}

//Save contact to the Default with NSKeyedArchiver array
-(void)saveContacts
{
    
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[ContactsData sharedConstants].contactNumbers] forKey:CONTACT_NUMBERS];
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[ContactsData sharedConstants].contactNames] forKey:CONTACT_NAMES];
    [DEFAULTS synchronize];
    
    [self checkEnableNextbtn];

}
#pragma mark-Custom Delegates

/*!
 *  @method keyValuesUpdated:
 *@param peripheral object
 *
 *  @discussion Function get called when key value pressed from the puck
 Here updating the key status to the dababase for log,put the puck to the normal mode
 *
 */
-(void) keyValuesUpdated:(CBPeripheral *)peripheral
{
    
    if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue] !=1)
    {
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName: [DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"V.ALRT Key pressed", nil)];
        
        [DEFAULTS setValue:@"1" forKey:@"KeyPressed"];
        
        normalPeriperal = peripheral;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(normalMode) name:@"pucktonormal" object:nil];
        
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
        //[ObjBLEConnection normalmode:peripheral];
        [[ContactsData sharedConstants] manageTextsandCalls];
        if ([[ContactsData sharedConstants].dictMessageResponse isKindOfClass:[NSNull class]])
        {
            
            [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:NSLocalizedString(@"invalid_number", nil)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
        });
        
    }
    
}

//Delegate method call for battery status
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral
{
    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    
    //Notify alert to user for low battery
    [[commonnotifyalert alertConstant] Notifybatterystatus:[DEFAULTS objectForKey:strID]  deviceId:strID device:[SharedData sharedConstants].strBatteryLevelStatus];
    
}


//Delagate for key fall
-(void)keyfall
{
    [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
}

//Key fall popup
-(void)keyfallpopup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:keyFallNotification object:nil];
    //Open the popup in a  main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
    });
    
}

//put the puck to silent mode
-(void)normalMode
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:keyFallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pucktonormal" object:nil];
    [SharedData sharedConstants].normalMode =1;
    [ObjBLEConnection normalmode:normalPeriperal];
}

// Method from BLEDelegate, called when fall detection values are updated
-(void) fallDetectValuesUpdated:(CBPeripheral *)peripheral
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
        [DEFAULTS setObject:@"1" forKey:@"FallDetecct"];
    }
    
}


-(void) keyfobReady
{
    //For App verification
    [SharedData sharedConstants].verifyMode = 1;
    // [ObjBLEConnection verifyMode:[ObjBLEConnection activePeripheral]];
    [ObjBLEConnection verifyModetemp:[ObjBLEConnection activePeripheral]];
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
            [ObjBLEConnection silentNormalmode:0x00 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
    }
    //Read Battery
    [SharedData sharedConstants].readBtry =1;
    [ObjBLEConnection readBattery:[ObjBLEConnection activePeripheral]];
    //Write value to adjust connection interval
    [SharedData sharedConstants].adjustMode =1;
    [ObjBLEConnection adjustInterval:[ObjBLEConnection activePeripheral]];
    
    //Add the device info to the table
    dConnect = [[dbConnect alloc]init];
    //insert the device connection status
    NSString *strID = [NSString stringWithFormat:@"%@",[ObjBLEConnection activePeripheral].identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    NSString*deviceName = [DEFAULTS objectForKey:strID];
    
    [dConnect adddeviceinfo:[SharedData sharedConstants].strserialNumber  bleName:deviceName bleAddress:strID softwarever:[SharedData sharedConstants].strSofwareVer];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nameField resignFirstResponder];
    [phoneField resignFirstResponder];
}


-(void)drawLines
{
    //Draw lines
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 35.0)];
    [path addLineToPoint:CGPointMake(300, 35.0)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    [messageView.layer addSublayer:shapeLayer];
    
    //Draw lines
    UIBezierPath *soundpath = [UIBezierPath bezierPath];
    [soundpath moveToPoint:CGPointMake(0, 40.0)];
    [soundpath addLineToPoint:CGPointMake(300, 40.0)];
    CAShapeLayer *soundpathLayer = [CAShapeLayer layer];
    soundpathLayer.path = [soundpath CGPath];
    soundpathLayer.strokeColor = [[UIColor grayColor] CGColor];
    soundpathLayer.lineWidth = 1.0;
    [soundView.layer addSublayer:soundpathLayer];
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
