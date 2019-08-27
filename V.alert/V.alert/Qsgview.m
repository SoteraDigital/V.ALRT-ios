#import "Qsgview.h"
#import "SharedData.h"
#import "Constants.h"
@interface Qsgview ()

@end

@implementation Qsgview
@synthesize QsgView,backBtn,urlLinkstr,navLbl,strPageTitle;
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
    QsgView.delegate = self;
    
	// Do any additional setup after loading the view.
    
    [backBtn setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    navLbl.text = strPageTitle;
    navLbl.textColor = BRANDING_COLOR;
    self.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_app_background.png"]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:urlLinkstr];
    NSURLRequest *requestURL =[NSURLRequest requestWithURL:url];
    QsgView.opaque = NO;
    QsgView.autoresizesSubviews = YES;
    [QsgView loadRequest:requestURL];
}

#pragma mark-Webview Delegate

//Load the request in browser
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *requestURL =[request URL];
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"mailto" ] || [ [ requestURL scheme ] isEqualToString: @"https" ] || [ [ requestURL scheme ] isEqualToString: @"www" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
        return ![[ UIApplication sharedApplication ] openURL:requestURL];
    }
    return YES;
}

/*!
 *  @method didFailLoadWithError:
 *  @discussion Throw alert message if page fail to load in the webview
 */
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (![[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"]  && ![[DEFAULTS valueForKey:@"FallDetecct"] isEqualToString:@"1"])
    {
        [[SharedData sharedConstants] alertMessage:@"" msg:NSLocalizedString(@"No Internet Connection is Avaialable", nil)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [QsgView stopLoading];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
