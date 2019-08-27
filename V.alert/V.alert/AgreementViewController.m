#import "AgreementViewController.h"
#import "vsnsettingsviewcontroller.h"


@interface AgreementViewController ()

@end

@implementation AgreementViewController
@synthesize lblTermsAndConditions,lblTermsandConditionsDescription,lblTitle;
@synthesize btnNextView,imgViewCheckBox,webAgreementDescription;

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
    
    lblTitle.text = NSLocalizedString(@"agreement_title", nil);
    lblTitle.textColor = BRANDING_COLOR;
    //Userfeedback changes starts
    lblTitle.numberOfLines = 2;
    
    lblTermsAndConditions.text = NSLocalizedString(@"agreement_terms", nil);
    lblTermsandConditionsDescription.text = NSLocalizedString(@"agreement_termsDescription", nil);
    
    [btnNextView setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    if(![LANGUAGE isEqualToString:@"en"])
    {
        
        //  [btnNextView setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0,0 )];        //
    }
    
    //  [btnNextView sizeToFit];
    //  [btnNextView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    NSString *detail;
    if([LANGUAGE isEqualToString:@"en"])
    {
        detail = @"http://vsnmobil.com/tandc/";
    }
    else
    {
        detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/spanish/";
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"det %@",detail);
    NSURL *url = [NSURL URLWithString:detail];
    requestURL =[NSURLRequest requestWithURL:url];
    webAgreementDescription.opaque = NO;
    webAgreementDescription.layer.cornerRadius = 7.0f;
    webAgreementDescription.clipsToBounds = YES;
    webAgreementDescription.autoresizesSubviews = YES;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    //Set flow step
    [DEFAULTS setInteger:1 forKey:FLOW_STEP];
    //userfeedback changes starts
    NSString *path;
    if([LANGUAGE isEqualToString:@"en"])
    {
        path = [[NSBundle mainBundle] pathForResource:@"Valert_Agreement" ofType:@"html"];
    }else if([LANGUAGE containsString:@"nl"]){
         path = [[NSBundle mainBundle] pathForResource:@"Valert_Agreement_Dutch" ofType:@"html"];
    }
    else
    {
        path = [[NSBundle mainBundle] pathForResource:@"Valert_Agreement_Spanish" ofType:@"html"];
    }
    
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // Tell the web view to load it
    [webAgreementDescription loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    //userfeedback changes ends
    
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    
    if ( ( [ [ [request URL] scheme ] isEqualToString: @"http" ] || [ [ [request URL] scheme ] isEqualToString: @"http" ] || [ [ [request URL] scheme ] isEqualToString: @"mailto" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) )
    {
        return ![[ UIApplication sharedApplication ] openURL:[request URL]];
    }
    //[ requestURL release ];
    return YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [webAgreementDescription stopLoading];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)didActionNextView:(id)sender {
    
    
    //To enable device sound by default
    [DEFAULTS setBool:NO forKey:DISABLE_VALERTDEVICE_SILENT];
    [DEFAULTS setInteger:10 forKey:@"language"];
    [DEFAULTS synchronize];
    vsnsettingsviewcontroller*ObjSettingsViewController;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjSettingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"vsnsettings"];
    [self presentViewController:ObjSettingsViewController animated:YES completion:nil];
    
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
