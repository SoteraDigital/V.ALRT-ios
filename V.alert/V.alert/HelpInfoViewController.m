#import "HelpInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TermsViewController.h"
#import "SharedData.h"
@interface HelpInfoViewController ()

@end

@implementation HelpInfoViewController

@synthesize lblTitle,lblDescription,lblLink,imgViewCheckBox,btnBack,webAgreementDescription;

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
    
    
    if ([[DEFAULTS valueForKey:@"HelpTitle"] isEqualToString:@"AboutInfo"])
    {
        lblTitle.text = NSLocalizedString(@"helpInfo_aboutTitle", nil);
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        NSString *htmlString;
        if([LANGUAGE isEqualToString:@"en"])
        {
            
            htmlString = @"<html><body style='color:#1a172a';><p>VSN Mobil was created with a clear goal - to bring a refreshing approach to the consumer electronics space and deliver devices that meet real needs for the real world. VSN Mobil's leadership has over 200 global patents to its credit and additional patents pending.</p>For More information visit us at <br/><a href='http://vsnmobil.com/'> http://vsnmobil.com/</a></body></html>";
            [lblTitle setTextAlignment:NSTextAlignmentCenter];
        }
        else
        {
            htmlString=@"<html><body style='color:#1a172a';><p>VSN Mobil fue creado con el claro objetivo de traer un enfoque refrescante al espacio de la electrónica de consumo y entregar dispositivos que satisfacen las necesidades reales para el mundo real. El grupo humano de VSN Mobil tiene más de 200 patentes mundiales en su haber y patentes adicionales pendientes.</p>Para más información visítenos en <br/><a href='http://vsnmobil.com/'>http://vsnmobil.com/</a></body></html>";
            
            [lblTitle setTextAlignment:NSTextAlignmentCenter];
            
        }
        
        NSString *str= [NSString stringWithFormat:@"<font face='HelveticaNeue' size='2.5'>%@", htmlString];
        [webAgreementDescription setClipsToBounds:YES];
        webAgreementDescription.layer.cornerRadius=5;
        [webAgreementDescription loadHTMLString:str  baseURL:nil];
    }
    else if ([[DEFAULTS valueForKey:@"HelpTitle"] isEqualToString:@"ProductInfo"])
    {
        lblTitle.text = NSLocalizedString(@"helpInfo_ProductinfoTitle", nil);
        
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *requestURL =[request URL];
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"mailto" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
        return ![[ UIApplication sharedApplication ] openURL:requestURL];
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

- (IBAction)didActionBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
