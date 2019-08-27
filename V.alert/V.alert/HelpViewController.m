#import "HelpViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "deviceinfo.h"
#import "TermsViewController.h"
#import "Qsgview.h"
#import "commonnotifyalert.h"
#import <MediaPlayer/MediaPlayer.h>
@interface HelpViewController ()

@end

@implementation HelpViewController
@synthesize btnBackViewController;
@synthesize imgAboutVsn,imgHistory,imgInstructionManual,imgInstructionVideo,imgProductInfo,imgTerms;
@synthesize btnAboutVsn,btnHistory,btnInstructionManual,btnInstructionVideo,btnProductInfo,btnTerms;
@synthesize lblAboutVsn,lblHistory,lblInstructionManual,lblInstructionVideo,lblProductInfo,lblTerms,lblTitle;

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
    lblTitle.text = NSLocalizedString(@"help_title", nil);
    lblTitle.textColor = BRANDING_COLOR;
    lblAboutVsn.text = NSLocalizedString(@"help_about", nil);
    lblHistory.text = NSLocalizedString(@"help_history", nil);
    lblInstructionManual.text = NSLocalizedString(@"help_instManual", nil);
    lblInstructionVideo.text = NSLocalizedString(@"help_instVideo", nil);
    lblProductInfo.text = NSLocalizedString(@"help_productInfo", nil);
    lblTerms.text = NSLocalizedString(@"help_terms", nil);
    [btnBackViewController setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
#ifdef HNALERT
    _viewInstructionVideo.hidden = TRUE;
    _viewQSG.hidden = TRUE;
#endif
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [scroller setScrollEnabled:YES];
    scroller.userInteractionEnabled = YES;
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    scroller.frame =CGRectMake(0, 67, 320, self.view.frame.size.height-70);
    scroller.contentSize = CGSizeMake(320, 580);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playbackFinished:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
    NSNumber* reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue])
    {
		case MPMovieFinishReasonPlaybackEnded:
			NSLog(@"playback end");
		case MPMovieFinishReasonPlaybackError:
			NSLog(@"playback error");
		case MPMovieFinishReasonUserExited:
        default:
			NSLog(@"default");
			[self dismissMoviePlayerViewControllerAnimated];
            break;
    }
}
- (IBAction)didActionBackViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)history:(id)sender {
    
    NSLog(@"history");
    
    HistoryViewController *ObjHelp;
    
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjHelp = [storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    ObjHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ObjHelp animated:YES completion:nil];
}

-(IBAction)instructionManual:(id)sender {
    NSLog(@"instructionManual");
    
    
    Qsgview *ObjHelp;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjHelp = [storyboard instantiateViewControllerWithIdentifier:@"qsgview"];
    ObjHelp.strPageTitle = NSLocalizedString(@"qsg_view", nil);
    ObjHelp.urlLinkstr = @"http://vsnmobil.com/valrt/manuals/VAlrt_quick_start.pdf";
    ObjHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ObjHelp animated:YES completion:nil];
}

-(IBAction)instructionVideo:(id)sender
{
    NSLog(@"instructionVideo");
    NSURL *movieURL;
    if([LANGUAGE isEqualToString:@"en"])
    {
        movieURL= [NSURL URLWithString:VSN_INSTRN_VIDEO_ENG_URL];
    }
    else
    {
        movieURL= [NSURL URLWithString:VSN_INSTRN_VIDEO_SPN_URL];
        //
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    NSLog(@"movi:%@",movieURL);
    
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer prepareToPlay];
    [movieController.moviePlayer play];
    
}

-(IBAction)productInfo:(id)sender {
    [DEFAULTS setValue:@"ProductInfo" forKey:@"HelpTitle"];
    deviceinfo *ObjHelp;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjHelp = [storyboard instantiateViewControllerWithIdentifier:@"deviceinfo"];
    ObjHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ObjHelp animated:YES completion:nil];
}

-(IBAction)aboutVsn:(id)sender
{
    [DEFAULTS setValue:@"AboutInfo" forKey:@"HelpTitle"];
    Qsgview *ObjHelp;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    ObjHelp = [storyboard instantiateViewControllerWithIdentifier:@"qsgview"];
    ObjHelp.strPageTitle = NSLocalizedString(@"help_about", nil);
    ObjHelp.navLbl.textColor = BRANDING_COLOR;
    if([LANGUAGE isEqualToString:@"en"])
    {
        ObjHelp.urlLinkstr = VSN_FAQ_ENG_URL;
    }
    else
    {
        ObjHelp.urlLinkstr = VSN_FAQ_SPN_URL;
    }
    ObjHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ObjHelp animated:YES completion:nil];
}

-(IBAction)terms:(id)sender
{
    [DEFAULTS setValue:@"TermsInfo" forKey:@"HelpTitle"];
    TermsViewController *terms;
    
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    terms = [storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
    terms.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:terms animated:YES completion:nil];
    
}


//Delegate method call for battery status
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral
{
    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    
    //Notify alert to user for low battery
    [[commonnotifyalert alertConstant] Notifybatterystatus:[DEFAULTS objectForKey:strID]  deviceId:strID device:[SharedData sharedConstants].strBatteryLevelStatus];
    
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
