#import "TermsViewController.h"
#import "Constants.h"
#import "SharedData.h"
@interface TermsViewController ()

@end

@implementation TermsViewController

@synthesize lblTitle,lblDescription,btnBack,webAgreementDescription;
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
    
    [btnBack setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    NSString *detail;
    webAgreementDescription.delegate = self;
    //webAgreementDescription.frame = CGRectMake(webAgreementDescription.frame.origin.x, webAgreementDescription.frame.origin.y, 320, 484);
    lblTitle.text = NSLocalizedString(@"helpInfo_TermsInfoTitle", nil);
    lblTitle.textColor = BRANDING_COLOR;
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    lblTitle.numberOfLines=0;
    [lblTitle sizeToFit];
#ifndef HNALERT
    if([LANGUAGE isEqualToString:@"es"]||[LANGUAGE isEqualToString:@"es-MX"])
    {
        detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/spanish/";
        [lblTitle setTextAlignment:NSTextAlignmentRight];
    }
    else
    {
        detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/";
    }
    NSURL *url = [NSURL URLWithString:detail];
    NSURLRequest *requestURL =[NSURLRequest requestWithURL:url];
    webAgreementDescription.opaque = NO;
    webAgreementDescription.autoresizesSubviews = YES;
    [webAgreementDescription loadRequest:requestURL];
#else
    if([LANGUAGE isEqualToString:@"es"]||[LANGUAGE isEqualToString:@"es-MX"])
    {
        detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/spanish/";
        [lblTitle setTextAlignment:NSTextAlignmentRight];
    }
    else
    {
        detail = @"http://www.vsnmobil.com/valrt/manuals/tandc/";
    }
    NSURL *url = [NSURL URLWithString:detail];
    NSURLRequest *requestURL =[NSURLRequest requestWithURL:url];
    webAgreementDescription.opaque = NO;
    webAgreementDescription.autoresizesSubviews = YES;
    [webAgreementDescription loadRequest:requestURL];
#endif
	// Do any additional setup after loading the view.
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


//dismiss the current view
-(IBAction)didActionBackViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
