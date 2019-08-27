#import "contactview.h"
#import "ContactsData.h"
#import "Constants.h"
#import "SharedData.h"
#import "ConfirmationView.h"
#import "customAlertPopUp.h"
#import "AnnoncementView.h"
#import "editContactPopUp.h"

@interface contactview ()
{
    int contactIndex;
}
@end

@implementation contactview

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
    
    [editContactPopUp sharedInstance].contactField.delegate = self;
	// Do any additional setup after loading the view.
    _addContactTitle.textColor = BRANDING_COLOR;
    _contactTitleBar.backgroundColor = BRANDING_COLOR;
    
    //Intialize the contact navigation picker
    pickContactViewController = [[ABPeoplePickerNavigationController alloc] init];
    pickContactViewController.peoplePickerDelegate = self;
    
    //Contact Request for ios9 and above
    //@For ios 10 fix
    if ([SYSTEM_VERSION integerValue] >=9) {
        [self contactPermission];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //Bind the contacts
    //if([DEFAULTS boolForKey:@""])
    [self bindContactsandcall];
    
    //Bind the text and call
    [self bindEnabletextCall];
    [DEFAULTS setBool:YES forKey:@"initial_view"];
    [self checkEnableNextbtn];
}

#pragma mark- Contact Request For IOS9 and above
- (void)contactPermission
{
        CNContactStore *store = [[CNContactStore alloc] init];
        
        //keys with fetching properties
        NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey,CNContactPostalAddressesKey, CNLabelWork, CNLabelDateAnniversary];
        
        NSString *containerId = store.defaultContainerIdentifier;
        
        NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
    
        NSError *error;
    
        NSLog(@"cnContacts %lu",(unsigned long) [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error].count);
    
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
    for(int i=0;i<3;i++)
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
        int tag = i+7;
        //Call
        UIButton * callBtn =(UIButton *) [self.view viewWithTag:tag];
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
    NSLog(@"contact id:%d",(int)[sender tag]);
    UIButton * contactBtn =(UIButton *) [self.view viewWithTag:[sender tag]];
    if([contactBtn isSelected])
    {
        [self removeContact:(int)[sender tag]-1];
    }
    else
    {
        if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
        {
            contactIndex = (int)[sender tag];
            [self addContact:(int)[sender tag]];
        }
        else
        {
            contactIndex = (int)[sender tag];
            [self alertMessage];
        }
    }
}

/*!
 *  @method frameTapGesture:
 *
 *  @param p tagIndex to read tag index value
 *
 *  @discussion add contact from the contacts picker
 */
- (IBAction)frameTapGesture:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    
    UIButton * contactBtn =(UIButton *) [self.view viewWithTag:[gesture.view tag]-9];
    if([contactBtn isSelected])
    {
        [self removeContact:(int)[gesture.view tag]-10];
    }
    else
    {
        if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
        {
            contactIndex = (int)[gesture.view tag]-9;
            [self addContact:(int)[gesture.view tag]-9];
        }
        else
        {
            
            contactIndex = (int)[gesture.view tag]-9;
            [self alertMessage];
            //currentIndex = [gesture.view tag]-10;
        }
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
    
    //[self.view addSubview:pickContactViewController.view];
    [self presentViewController:pickContactViewController animated:true completion:nil];
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
        if([self checkEnable:(int)[sender tag]-4])
        {
            [textBtn setSelected:YES];
        }
        else
        {
            [[SharedData sharedConstants] alertMessage:@"" msg:NSLocalizedString(@"Add Contact to Enable Texts and Calls", nil)];
        }
    }
    
    [self enabledisableText:(int)[sender tag]];
    
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
        if([self checkEnable:(int)[sender tag]-7])
        {
            [callBtn setSelected:YES];
        }
        else
        {
            [[SharedData sharedConstants] alertMessage:@"" msg:NSLocalizedString(@"Add Contact to Enable Texts and Calls", nil)];
        }
    }
    
    [self enabledisableCall:(int)[sender tag]];
}

/*!
 *  @method alertMessage:
 *
 *
 *  @discussion through alert if the country code is not us
 *
 */
-(void)alertMessage
{
    UIAlertView*alertMsg = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"country_alert_txt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
    [alertMsg show];
}

#pragma mark-Alert view Delegate
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
    [self addContact:contactIndex];
}
#pragma mark-Contact picker delegates

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    contactnum = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
    CFRelease(phoneNumberProperty);
    
    contactname = (__bridge NSString *)ABRecordCopyCompositeName(person);
    
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
    
    //[pickContactViewController.view removeFromSuperview];
    switch ([contactnum count])
    {
        case 0:
            [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:LABEL_CUSTOMALERT_NOCONTACTS];
            break;
        case 1:
            [self switchCase1];
            break;
        default:
            [[SharedData sharedConstants].arrSelectMultipleContacts removeAllObjects];
            [[SharedData sharedConstants].arrSelectMultipleContacts addObjectsFromArray:contactnum];
            [[AnnoncementView sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId)
             {
                 [[editContactPopUp sharedInstance].contactField becomeFirstResponder];
                 [[editContactPopUp sharedInstance]didCustomPopUpAlertLoad:self.view
                                                                  strTitle:NSLocalizedString(@"editcontactTitle", nil) strTitle2:NSLocalizedString(@"editcontactMessage", nil)
                                                                  txtTitle:[SharedData sharedConstants].strDidSelectContacts];
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
        
        UIButton * callBtn =(UIButton *) [self.view viewWithTag:currentIndex+7];
        [callBtn setSelected:YES];
    }
    //Bind the text to the label
    UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:currentIndex+10];
    [addcontactsLbl setText:[[ContactsData sharedConstants].contactNames objectAtIndex:currentIndex]];
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    //[pickContactViewController.view removeFromSuperview];
    
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier

{
   // [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
   // - (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker    shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
    return NO;
    
}

//@discussion - open the popup to edit the contact number
-(void)switchCase1
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[editContactPopUp sharedInstance].contactField becomeFirstResponder];
        [[editContactPopUp sharedInstance]didCustomPopUpAlertLoad:self.view
                                                         strTitle:NSLocalizedString(@"editcontactTitle", nil) strTitle2:NSLocalizedString(@"editcontactMessage", nil)
                                                         txtTitle:[self->contactnum objectAtIndex:0]];
    }];
    
}
- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)checkEnableNextbtn
{
    //Check all required fields and update the button flag
    if (([[SharedData sharedConstants].arrEnabledCalls containsObject:@"1"] || [[SharedData sharedConstants].arrEnabledTexts containsObject:@"1"]) )
    {
        [nextBtn setEnabled:YES];
    }
    else
    {
        [nextBtn setEnabled:NO];
    }
}

#pragma mark-TextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)_textField{
    NSString*viewStr;
    viewStr = @"AccessoryView";
    if(![LANGUAGE isEqualToString:@"en"])
    {
        
        viewStr = @"AccessoryView_sp";
    }
    UIView *accessoryView=[[[NSBundle mainBundle] loadNibNamed:viewStr owner:self options:nil] lastObject];
    _textField.inputAccessoryView=accessoryView;
    accessoryView=nil;
    
    return YES;
}

- (IBAction)DoneTapped:(id)sender
{
    NSString *originalStr = [editContactPopUp sharedInstance].contactField.text;
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[\\s\\-()]+"];
    originalStr = [[originalStr componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    NSArray* words = [originalStr componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* nospacestring;
     nospacestring = [words componentsJoinedByString:@""];
    if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
    {
        if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
        {
            if(nospacestring.length>=10 && [[SharedData sharedConstants] numericText:nospacestring])
            {
                [self saveNumber];
            }
            else
            {
                [[editContactPopUp sharedInstance] changeText:NSLocalizedString(@"code_not_match", nil)];
            }
        }
        else
        {
            [[editContactPopUp sharedInstance] changeText:NSLocalizedString(@"code_not_match", nil)];
        }
    }
    else
    {
        //NSDictionary*codeCheckDict = [[NSDictionary alloc]initWithObjectsAndKeys:@"+52",@"MX",@"+55",@"BR", nil];
        //NSString *phoneStr;
        if([[editContactPopUp sharedInstance].contactField.text length]>2)
        {
            nospacestring = [[editContactPopUp sharedInstance].contactField.text substringWithRange:NSMakeRange(0, 1)];
        }
        else
        {
            nospacestring = @"000";
        }
        NSString *phone = [[editContactPopUp sharedInstance].contactField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        int length = (int)[phone length];
        if([nospacestring isEqualToString:@"+"] && length>=8
           && [[SharedData sharedConstants] numericText:nospacestring])
        {
            
            [[ContactsData sharedConstants].contactNumbers replaceObjectAtIndex:currentIndex withObject:[editContactPopUp sharedInstance].contactField.text];
            [[ContactsData sharedConstants].contactNames replaceObjectAtIndex:currentIndex withObject:contactname];
            [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:currentIndex withObject:@"1"];
            [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:currentIndex withObject:@"1"];
            [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
            [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledCalls] forKey:ENABLED_CALLS];
            [DEFAULTS synchronize];
            [self saveContacts];
            UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:currentIndex+10];
            [addcontactsLbl setText:[[ContactsData sharedConstants].contactNames objectAtIndex:currentIndex]];
            
            [self.view endEditing:YES];
            
            // self.window.super.label.text = @"aadad";
            [[editContactPopUp sharedInstance] didCustomPopUpUnload];
            //if([DEFAULTS boolForKey:@""])
            [self bindContactsandcall];
            
            //Bind the text and call
            [self bindEnabletextCall];
        }
        else
        {
            [[editContactPopUp sharedInstance] changeText:NSLocalizedString(@"code_not_match", nil)];
        }
    }
}

-(void)saveNumber
{
    [[ContactsData sharedConstants].contactNumbers replaceObjectAtIndex:currentIndex withObject:[editContactPopUp sharedInstance].contactField.text];
    [[ContactsData sharedConstants].contactNames replaceObjectAtIndex:currentIndex withObject:contactname];
    [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:currentIndex withObject:@"1"];
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
    [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:currentIndex withObject:@"1"];
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledCalls] forKey:ENABLED_CALLS];
    [DEFAULTS synchronize];
    [self saveContacts];
    UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:currentIndex+10];
    [addcontactsLbl setText:[[ContactsData sharedConstants].contactNames objectAtIndex:currentIndex]];
    
    [self.view endEditing:YES];
    
    [[editContactPopUp sharedInstance] didCustomPopUpUnload];
    
    [self bindContactsandcall];
    
    //Bind the text and call
    [self bindEnabletextCall];
}

- (IBAction)CancelTapped:(id)sender
{
    
    
    [self.view endEditing:YES];
    [[editContactPopUp sharedInstance] didCustomPopUpUnload];
    //[self removeContact:contactIndex];
    UIButton * contactBtn =(UIButton *) [self.view viewWithTag:contactIndex];
    UIButton * textBtn =(UIButton *) [self.view viewWithTag:contactIndex+3];
    UIButton * callBtn =(UIButton *) [self.view viewWithTag:contactIndex+6];
    //Bind the text to the label
    UILabel *addcontactsLbl = (UILabel *)[self.view viewWithTag:contactIndex+9];
    [addcontactsLbl setText:NSLocalizedString(@"Tap to add contact",nil)];
    [contactBtn setSelected:NO];
    [textBtn setSelected:NO];
    [callBtn setSelected:NO];
    
    
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


//Save contact to the Default with NSKeyedArchiver array
-(void)saveContacts
{
    
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[ContactsData sharedConstants].contactNumbers] forKey:CONTACT_NUMBERS];
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[ContactsData sharedConstants].contactNames] forKey:CONTACT_NAMES];
    [DEFAULTS synchronize];
    
    [self checkEnableNextbtn];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
}
-(IBAction)unwindToRootVC:(UIStoryboardSegue *)segue
{
    
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
