#import "WelcomeViewController.h"
#import "Constants.h"
#import "AgreementViewController.h"
#import "SharedData.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>
@interface WelcomeViewController ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation WelcomeViewController

@synthesize lblAcceptTermsandConditions,lblTermsAndConditions,lblTermsandConditionsDescription,lblTitle;
@synthesize btnAcceptTermsAndConditions,btnNExtViewController,imgViewCheckBox;
@synthesize webTermsandConditionsDescription,alertShowing;

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
    //Set flow step
    [DEFAULTS setInteger:0 forKey:FLOW_STEP];
    
    lblTitle.text = NSLocalizedString(@"welcome_title", nil);
    lblTitle.textColor = BRANDING_COLOR;
    lblTermsAndConditions.text = NSLocalizedString(@"welcome_terms", nil);
    lblTermsandConditionsDescription.text = NSLocalizedString(@"welcome_termsDescription", nil);
    lblAcceptTermsandConditions.text = NSLocalizedString(@"welcome_termAccept", nil);
    [btnNExtViewController setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    btnNExtViewController.hidden = NO;
    NSString *detail;
    
    if([LANGUAGE isEqualToString:@"es"]||[LANGUAGE isEqualToString:@"es-MX"])
    {
        detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/spanish/";
       
    }
    else
    {
         detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/";
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:detail];
    requestURL =[NSURLRequest requestWithURL:url];
    webTermsandConditionsDescription.autoresizesSubviews = YES;
    [webTermsandConditionsDescription.scrollView setShowsVerticalScrollIndicator:YES];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [webTermsandConditionsDescription setClipsToBounds:YES];
    
#ifdef HNALERT
    [webTermsandConditionsDescription loadRequest:requestURL];
#else
    [webTermsandConditionsDescription loadRequest:requestURL];
#endif
}

#pragma mark-Webview Delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    
    if ( ( [ [ [request URL] scheme ] isEqualToString: @"http" ] || [ [ [request URL] scheme ] isEqualToString: @"http" ] || [ [ [request URL] scheme ] isEqualToString: @"mailto" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) )
    {
        //Uncheck the terms and condn starts
        [DEFAULTS setValue:@"0" forKey:@"welcomeEnable"];
        btnNExtViewController.enabled = NO;
        imgViewCheckBox.image = [UIImage imageNamed:@"terms_disable.png"];
        //Uncheck the terms and condn ends
        
        return ![[ UIApplication sharedApplication ] openURL:[request URL]];
    }
    return YES;
}
/*!
 *  @method didFailLoadWithError:
 *  @discussion Throw alert message if page fail to load in the webview
 */
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    [[SharedData sharedConstants] alertMessage:@"" msg:NSLocalizedString(@"No Internet Connection is Avaialable", nil)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [webTermsandConditionsDescription stopLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (IBAction)didActionAcceptTermsAndConditions:(id)sender
{
    
    if ([[DEFAULTS valueForKey:@"welcomeEnable"] isEqualToString:@"1"])
    {
        [DEFAULTS setValue:@"0" forKey:@"welcomeEnable"];
        btnNExtViewController.enabled = NO;
        btnNExtViewController.hidden = NO;
        imgViewCheckBox.image = [UIImage imageNamed:@"terms_disable.png"];
    }
    else
    {
        [DEFAULTS setValue:@"1" forKey:@"welcomeEnable"];
        btnNExtViewController.enabled = YES;
        imgViewCheckBox.image = [UIImage imageNamed:@"img_check_contact.png"];
    }
}

- (IBAction)didActionNextViewController:(id)sender
{
    AgreementViewController *ObjAgreementViewController;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjAgreementViewController = [storyboard instantiateViewControllerWithIdentifier:@"AgreementViewController"];
    [self presentViewController:ObjAgreementViewController animated:YES completion:nil];
    
    
}

//alertview dismissed with button index delegaee
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    self.alertShowing = NO;
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}


#pragma mark Mail Function
- (IBAction)actionEmailComposer:(id)sender {
    NSString *detail;
    
#ifdef HNALERT
    if([LANGUAGE isEqualToString:@"en"])
    {
        detail = VSN_EMAIL_TC_ENG_URL;
    }
    else
    {
        detail = VSN_EMAIL_TC_SPN_URL;
    }
#else
    if([LANGUAGE isEqualToString:@"en"])
    {
        detail = VSN_EMAIL_TC_ENG_URL;
    }
    else
    {
        detail = VSN_EMAIL_TC_SPN_URL;
    }
#endif
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:NSLocalizedString(@"welcome_email_subject", nil)];
#ifdef HNALERT
        [mailViewController setMessageBody:detail isHTML:YES];
#else
        [mailViewController setMessageBody:detail isHTML:NO];
#endif
        
        [self presentViewController:mailViewController animated:YES completion:nil];
        
    }
    else
    {
        
        [[SharedData sharedConstants] alertMessage: NSLocalizedString(@"", nil) msg: NSLocalizedString(@"email_not_configured", nil)];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
