#import "personalinfo.h"
#import "Constants.h"
#import "SharedData.h"
#import "ContactsData.h"
#import "contactview.h"

@interface personalinfo ()
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@end

@implementation personalinfo
@synthesize selectedIndexPath = _selectedIndexPath;
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
    _personalInfoTitle.textColor = BRANDING_COLOR;
    
    countryArr = [[NSArray alloc]initWithObjects:@"United States",@"Other",nil];
    countrycodeArr = [[NSArray alloc]initWithObjects:@"US",@"-" ,nil];
    
    //user feedback changes starts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    NSUInteger languageSelction = [DEFAULTS integerForKey:@"language"];
    if (languageSelction>0)
    {
        
        [nextBtn setHidden:YES];
    }
    if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"MX"] ||[[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"MX"] || [[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"BR"]|| [[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"IN"])
    {
        [DEFAULTS setObject:@"Other" forKey:@"countryname"];
        [DEFAULTS setObject:@"-" forKey:@"countrycode"];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    
    //language translate
    [self languagetranslate];
    //Check Enable Btn
    [self checkEnableNextbtn];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [listView dismiss];
}

/*!
 *  @method languagetranslate:
 *  @discussion binding the text to label
 *
 */
-(void)languagetranslate
{
    nameLbl.text = NSLocalizedString(@"name-lbl", nil);
    phonenoLbl.text = NSLocalizedString(@"phone-lbl", nil);
    countrydftLbl.text = NSLocalizedString(@"country-lbl", nil);
    
    if([DEFAULTS objectForKey:@"userName"] !=nil)
    {
        nameField.text = [DEFAULTS objectForKey:@"userName"];
    }
    
    if([DEFAULTS objectForKey:@"phonenumber"] !=nil)
    {
        phonenoField.text = [DEFAULTS objectForKey:@"phonenumber"];
    }
    
    if([DEFAULTS objectForKey:@"countryname"] ==nil || [[DEFAULTS objectForKey:@"countrycode"] isEqualToString:@"US"])
    {
        phonenoField.keyboardType = UIKeyboardTypeNumberPad;
        [DEFAULTS setObject: @"United States" forKey:@"countryname"];
        [DEFAULTS setObject:@"US" forKey:@"countrycode"];
    }
    
    countryTxtLbl.text = NSLocalizedString([DEFAULTS objectForKey:@"countryname"], nil);
    
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(IS_IPHONE_4)
    {
        [countrydftLbl setHidden:YES];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self->personalinfoView.frame;
            f.origin.y =  20.f;
            self->personalinfoView.frame = f;
            
        }];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    if(IS_IPHONE_4)
    {
        [countrydftLbl setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self->personalinfoView.frame;
            f.origin.y =  90.f;
            self->personalinfoView.frame = f;
        }];
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
    
    if(_textField ==phonenoField)
    {
        if ([_textField.text length] > 0 && _textField.text != nil && [_textField.text isEqual:@""] == FALSE)
        {
            [self checkEnableNextbtn];
        }
    }
    _textField.inputAccessoryView=accessoryView;
    accessoryView=nil;
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([nameField isFirstResponder])
    {
        [phonenoField becomeFirstResponder];
    }
    return YES;
}

#pragma mark - TextviewDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField ==nameField)
    {
        [DEFAULTS setObject:nameField.text forKey:@"userName"];
        NSUInteger newLength = [nameField.text length] + [string length] - range.length;
        return (newLength > 13) ? NO : YES;
    }
    else
    {
        [DEFAULTS setObject:phonenoField.text forKey:@"phonenumber"];
        NSUInteger newLength = [phonenoField.text length] + [string length] - range.length;
        return (newLength > 13) ? NO : YES;
    }
    [self checkEnableNextbtn];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark- IBAction

- (IBAction)DoneTapped:(id)sender
{
    
    if([nameField isFirstResponder])
    {
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
        NSString *trimmedString = [nameField.text stringByTrimmingCharactersInSet:whitespace];
        if([trimmedString isEqualToString:@""])
        {
            [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-namemsg", nil)];
            nameField.text = @"";
            [nameField becomeFirstResponder];
        }
        else
        {
            [DEFAULTS setObject:trimmedString forKey:@"userName"];
            [self.view endEditing:YES];
        }
    }
    else
    {
        NSString *phoneStr = phonenoField.text;
        int phoneLen= (int)[phoneStr length];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
        NSString *trimmedString = [nameField.text stringByTrimmingCharactersInSet:whitespace];
        if([trimmedString isEqualToString:@""])
        {
            [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-namemsg", nil)];
            nameField.text = @"";
            [nameField becomeFirstResponder];
        }
        else if((phoneLen==0)|| (phoneLen <8) )
        {
            [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
            [phonenoField becomeFirstResponder];
        }
        else if(![[SharedData sharedConstants] numericText:phonenoField.text])
        {
            [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
            [phonenoField becomeFirstResponder];
        }
        else
        {
            [DEFAULTS setObject:phonenoField.text forKey:@"phonenumber"];
            [DEFAULTS setObject:trimmedString forKey:@"userName"];
            [self.view endEditing:YES];
        }
    }
    [self checkEnableNextbtn];
    
}

- (IBAction)CancelTapped:(id)sender
{
    
    [self checkEnableNextbtn];
    [self.view endEditing:YES];
}

- (IBAction)backAction:(id)sender
{
    NSString *phoneStr = phonenoField.text;
    int phoneLen= (int)[phoneStr length];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [nameField.text stringByTrimmingCharactersInSet:whitespace];
    if([trimmedString isEqualToString:@""])
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-namemsg", nil)];
        [nameField becomeFirstResponder];
    }
    else if((phoneLen==0)|| (phoneLen <8) )
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
        [phonenoField becomeFirstResponder];
    }
    else if(![[SharedData sharedConstants] numericText:phonenoField.text])
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
        [phonenoField becomeFirstResponder];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(IBAction)countryTap:(id)sender
{
    
    [listView dismiss];
    listView = [[ZSYPopoverListView alloc] initWithFrame:CGRectMake(0, 0, 250, 150)];
    listView.titleName.text = NSLocalizedString(@"Select a Country",nil);
    listView.datasource = self;
    listView.delegate = self;
    [listView setCancelButtonTitle:NSLocalizedString(@"cancel", nil) block:^{
        NSLog(@"cancel");
        self.view.userInteractionEnabled = YES;
    }];
    [listView show];
    
    if ([DEFAULTS boolForKey:@"initial_view"])
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"Warning", nil) msg:NSLocalizedString(@"country_warning", nil)];
    }
    
    self.view.userInteractionEnabled = NO;
}

#pragma mark -ZSYPopoverListViewdelegates
- (NSInteger)popoverListView:(ZSYPopoverListView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)popoverListView:(ZSYPopoverListView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusablePopoverCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
    }
    
    cell.textLabel.text = NSLocalizedString([countryArr objectAtIndex:indexPath.row],nil);
    cell.textLabel.textColor = [UIColor colorWithRed:(80/255.f) green:(74/255.f) blue:(103/255.f) alpha:1.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}


- (void)popoverListView:(ZSYPopoverListView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [countryTxtLbl setText: NSLocalizedString([countryArr objectAtIndex:indexPath.row], nil)];
    if(![[DEFAULTS objectForKey:@"countrycode"] isEqualToString:[countrycodeArr objectAtIndex:indexPath.row]])
    {
        [self clearallContacts];
    }
    
    [DEFAULTS setObject:[countryArr objectAtIndex:indexPath.row] forKey:@"countryname"];
    [DEFAULTS setObject:[countrycodeArr objectAtIndex:indexPath.row] forKey:@"countrycode"];
    if(![[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
    {
        phonenoField.keyboardType = UIKeyboardTypePhonePad;
        phonenoField.placeholder = NSLocalizedString(@"placehold_countrycode", nil);
    }
    else
    {
        phonenoField.keyboardType = UIKeyboardTypeNumberPad;
        phonenoField.placeholder = NSLocalizedString(@"placehold_countrycode", nil);
    }
    [listView dismiss];
    self.view.userInteractionEnabled = YES;
}

-(void)checkEnableNextbtn
{
    //Check all required fields and update the button flag
    if (![[DEFAULTS objectForKey:@"phonenumber"] isEqualToString:@""] && ![[DEFAULTS objectForKey:@"phonenumber"] isEqual:[NSNull null]] &&[DEFAULTS objectForKey:@"phonenumber"] !=nil &&[DEFAULTS objectForKey:@"userName"] !=nil)
    {
        [nextBtn setEnabled:YES];
    }
    else
    {
        [nextBtn setEnabled:NO];
    }
}

//Clear all contacts
- (IBAction)nextAction:(id)sender
{
    NSString *phoneStr = phonenoField.text;
    int phoneLen= (int)[phoneStr length];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [nameField.text stringByTrimmingCharactersInSet:whitespace];
    if([trimmedString isEqualToString:@""])
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-namemsg", nil)];
        [nameField becomeFirstResponder];
    }
    else if((phoneLen==0)|| (phoneLen <8) )
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
        [phonenoField becomeFirstResponder];
    }
    else if(![[SharedData sharedConstants] numericText:phonenoField.text])
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-numbermsg", nil) ];
        [phonenoField becomeFirstResponder];
    }
    else
    {
        [DEFAULTS setObject:phonenoField.text forKey:@"phonenumber"];
        [DEFAULTS setObject:trimmedString forKey:@"userName"];
        contactview *Objcon;
        UIStoryboard *storyboard = IPHONE_STORYBOARD;
        Objcon = [storyboard instantiateViewControllerWithIdentifier:@"contactview"];
        Objcon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:Objcon animated:YES completion:nil];
    }
    
}

-(void)clearallContacts
{
    for(int tagIndex=0;tagIndex<3;tagIndex++)
    {
        [[ContactsData sharedConstants].contactNumbers replaceObjectAtIndex:tagIndex withObject:TEXT_ADD_CONTACT];
        [[ContactsData sharedConstants].contactNames replaceObjectAtIndex:tagIndex withObject:TEXT_ADD_CONTACT];
        [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:tagIndex withObject:@"0"];
        [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:tagIndex withObject:@"0"];
        [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
        [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledCalls] forKey:ENABLED_CALLS];
        [DEFAULTS synchronize];
    }
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[ContactsData sharedConstants].contactNumbers] forKey:CONTACT_NUMBERS];
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[ContactsData sharedConstants].contactNames] forKey:CONTACT_NAMES];
    [DEFAULTS synchronize];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
