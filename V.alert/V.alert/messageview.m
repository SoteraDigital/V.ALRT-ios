#import "messageview.h"
#import "Constants.h"
#import "SharedData.h"
#import "advanceview.h"
#import "ManageDevicesViewController.h"

@interface messageview ()

@end

@implementation messageview
#define maxx_length 55
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
    _alertMessageTitle.textColor = BRANDING_COLOR;
    _alertMessageBar.backgroundColor = BRANDING_COLOR;
    [messageTxt becomeFirstResponder];
    NSUInteger languageSelction = [DEFAULTS integerForKey:@"language"];
    if (languageSelction>0)
    {
        [nextBtn setHidden:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if([DEFAULTS objectForKey:ALERT_MESSAGE] !=nil)
    {
        messageTxt.text = [DEFAULTS objectForKey:ALERT_MESSAGE];
    }
    [self checkEnableNextbtn];
}

#pragma mark - TextviewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //trimmed the text string in text view
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [DEFAULTS setObject:[messageTxt.text stringByTrimmingCharactersInSet:whitespace] forKey:ALERT_MESSAGE];
    [DEFAULTS synchronize];
    [self checkEnableNextbtn];
    //Bind the text and remove from textview
    if( [text isEqualToString: @"\n" ])
    {
        NSUInteger new = [textView.text length] + [text length] - range.length;
        if(new > maxx_length)
        {
            return NO;
        }
        else
        {
            
            if (![[DEFAULTS valueForKey:ALERT_MESSAGE] isEqualToString:@""] &&[DEFAULTS valueForKey:ALERT_MESSAGE]  !=nil )
            {
                NSUInteger initialSetup = [DEFAULTS integerForKey:INITIAL_SETUP];
                if (initialSetup>0)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    ManageDevicesViewController *Objcon;
                    UIStoryboard *storyboard = IPHONE_STORYBOARD;
                    Objcon = [storyboard instantiateViewControllerWithIdentifier:@"ManageDevicesViewController"];
                    Objcon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:Objcon animated:YES completion:nil];
                }
                
            }
            
            return  YES;
        }
        
    }
    else
    {
        NSUInteger new = [textView.text length] + [text length] - range.length;
        if(new >= maxx_length)
        {
            return NO;
        }
        
        [self checkEnableNextbtn];
    }
    return YES;
}


//Send to back view
- (IBAction)backAction:(id)sender
{
    
    //trimmed the text string in text view
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [DEFAULTS setObject:[messageTxt.text stringByTrimmingCharactersInSet:whitespace] forKey:ALERT_MESSAGE];
    [DEFAULTS synchronize];
    if (![[DEFAULTS valueForKey:ALERT_MESSAGE] isEqualToString:@""] &&[DEFAULTS valueForKey:ALERT_MESSAGE]  !=nil )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-msgerror", nil) ];
    }
}

//Send to next view
- (IBAction)nextAction:(id)sender
{
    //trimmed the text string in text view
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [DEFAULTS setObject:[messageTxt.text stringByTrimmingCharactersInSet:whitespace] forKey:ALERT_MESSAGE];
    [DEFAULTS synchronize];
    if (![[DEFAULTS valueForKey:ALERT_MESSAGE] isEqualToString:@""] &&[DEFAULTS valueForKey:ALERT_MESSAGE]  !=nil  )
    {
        ManageDevicesViewController *Objcon;
        UIStoryboard *storyboard = IPHONE_STORYBOARD;
        Objcon = [storyboard instantiateViewControllerWithIdentifier:@"ManageDevicesViewController"];
        Objcon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:Objcon animated:YES completion:nil];
    }
    else
    {
        [[SharedData sharedConstants] alertMessage:NSLocalizedString(@"settings-personel-error", nil) msg:NSLocalizedString(@"settings-personel-msgerror", nil) ];
    }
    
}

//Check and enable the next button.
-(void)checkEnableNextbtn
{
    //Check all required fields and update the button flag
    if (![[DEFAULTS valueForKey:ALERT_MESSAGE] isEqualToString:@""] &&[DEFAULTS valueForKey:ALERT_MESSAGE]  !=nil )
    {
        [nextBtn setEnabled:YES];
    }
    else
    {
        [nextBtn setEnabled:NO];
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
