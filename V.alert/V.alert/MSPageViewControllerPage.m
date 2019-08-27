#import "Constants.h"
#import "MSPageViewControllerPage.h"
#import "AnimatedGif.h"

@implementation MSPageViewControllerPage
{
    
}

@synthesize pageIndex;
@synthesize navigationBar,tourPageOverlayView;

- (void)viewDidLoad
{
    NSLog(@"pageIndex-%d",(int)pageIndex);
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.translucent = YES;

    puckImageView.translatesAutoresizingMaskIntoConstraints = YES;
     puckAnimation.translatesAutoresizingMaskIntoConstraints = YES;
    setupBtn.translatesAutoresizingMaskIntoConstraints = YES;
    buyonlineBtn.translatesAutoresizingMaskIntoConstraints = YES;
    tourPageOverlayView.translatesAutoresizingMaskIntoConstraints = YES;
    headerLbl.translatesAutoresizingMaskIntoConstraints = YES;
    contentLbl.translatesAutoresizingMaskIntoConstraints = YES;
#ifdef HNALERT
#endif
    if(IS_IPHONE_4)
    {
        tourPageOverlayView.frame = CGRectMake(0, 290, 320, 165);
        puckImageView.frame = CGRectMake(55, 116, 214, 214);
        setupBtn.frame = CGRectMake(15, 330, 290, 50);
        buyonlineBtn.frame = CGRectMake(15, 390, 290, 50);
        headerLbl.frame = CGRectMake(8, 295, 304, 70);
        contentLbl.frame = CGRectMake(8, 350, 304, 100);
    }
    else
    {
        tourPageOverlayView.frame = CGRectMake(0, 384, 320, 165);
    }
 /*   NSArray * imageArray  = [[NSArray alloc] initWithObjects:
                             [UIImage imageNamed:@"0_0.png"],
                             [UIImage imageNamed:@"0_1.png"],
                             [UIImage imageNamed:@"0_2.png"],
                             [UIImage imageNamed:@"0_3.png"],
                             [UIImage imageNamed:@"0_4.png"],
                             [UIImage imageNamed:@"0_5.png"],
                             [UIImage imageNamed:@"0_6.png"],
                             [UIImage imageNamed:@"0_7.png"],
                             [UIImage imageNamed:@"0_8.png"],
                             [UIImage imageNamed:@"0_9.png"],
                             [UIImage imageNamed:@"0_10.png"],
                             [UIImage imageNamed:@"0_11.png"],
                             [UIImage imageNamed:@"0_12.png"],
                             [UIImage imageNamed:@"0_13.png"],
                             [UIImage imageNamed:@"0_14.png"],
                             [UIImage imageNamed:@"0_15.png"],
                             [UIImage imageNamed:@"0_16.png"],
                             [UIImage imageNamed:@"0_17.png"],
                             [UIImage imageNamed:@"0_18.png"],
                             [UIImage imageNamed:@"0_19.png"],
                             [UIImage imageNamed:@"0_20.png"],
                             [UIImage imageNamed:@"0_21.png"],
                             [UIImage imageNamed:@"0_22.png"],
                             [UIImage imageNamed:@"0_23.png"],
                             [UIImage imageNamed:@"0_24.png"],
                             [UIImage imageNamed:@"0_25.png"],
                             [UIImage imageNamed:@"0_26.png"],
                             [UIImage imageNamed:@"0_27.png"],
                             [UIImage imageNamed:@"0_28.png"],
                             [UIImage imageNamed:@"0_29.png"],
                             [UIImage imageNamed:@"0_30.png"],
                             [UIImage imageNamed:@"0_31.png"],
                             [UIImage imageNamed:@"0_32.png"],
                             [UIImage imageNamed:@"0_33.png"],
                             [UIImage imageNamed:@"0_34.png"],
                             [UIImage imageNamed:@"0_35.png"],
                             [UIImage imageNamed:@"0_36.png"],
                             [UIImage imageNamed:@"0_37.png"],
                             [UIImage imageNamed:@"0_38.png"],
                             [UIImage imageNamed:@"0_39.png"],
                             [UIImage imageNamed:@"0_40.png"],
                             [UIImage imageNamed:@"0_41.png"],
                             [UIImage imageNamed:@"0_42.png"],
                             [UIImage imageNamed:@"0_43.png"],
                             [UIImage imageNamed:@"0_44.png"],
                             [UIImage imageNamed:@"0_45.png"],
                             [UIImage imageNamed:@"0_46.png"],
                             [UIImage imageNamed:@"0_47.png"],
                             [UIImage imageNamed:@"0_48.png"],
                             [UIImage imageNamed:@"0_49.png"],
                             [UIImage imageNamed:@"0_50.png"],
                             [UIImage imageNamed:@"0_51.png"],
                             [UIImage imageNamed:@"0_52.png"],
                             [UIImage imageNamed:@"0_53.png"],
                             [UIImage imageNamed:@"0_54.png"],
                             [UIImage imageNamed:@"0_55.png"],
                             [UIImage imageNamed:@"0_56.png"],
                             [UIImage imageNamed:@"0_57.png"],
                             [UIImage imageNamed:@"0_58.png"],
                             [UIImage imageNamed:@"0_59.png"],
                             [UIImage imageNamed:@"0_60.png"],
                             [UIImage imageNamed:@"0_61.png"],
                             [UIImage imageNamed:@"0_62.png"],
                             [UIImage imageNamed:@"0_63.png"],
                             [UIImage imageNamed:@"0_64.png"],
                             [UIImage imageNamed:@"0_65.png"],
                             [UIImage imageNamed:@"0_66.png"],
                             [UIImage imageNamed:@"0_67.png"],
                             [UIImage imageNamed:@"0_68.png"],
                             [UIImage imageNamed:@"0_69.png"],
                             [UIImage imageNamed:@"0_70.png"],
                             [UIImage imageNamed:@"0_71.png"],
                             [UIImage imageNamed:@"0_72.png"],
                             [UIImage imageNamed:@"0_73.png"],
                             [UIImage imageNamed:@"0_74.png"],
                             [UIImage imageNamed:@"0_75.png"],
                             [UIImage imageNamed:@"0_76.png"],
                             nil];
    
    puckImageView.animationImages = imageArray;
    puckImageView.animationDuration = 4.0;
	[puckImageView startAnimating];
    */
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"animated_puck" ofType:@"gif"]];
    puckAnimation = [AnimatedGif getAnimationForGifAtUrl: localUrl];
    if(IS_IPHONE_4)
    {
        puckAnimation.frame = CGRectMake(55, 116, 214, 214);
    }
    else
    {
        puckAnimation.frame = CGRectMake(55, 176, 214, 214);
    }
    if ([buyonlineBtn isKindOfClass:[self.view class]]) {
        [self.view addSubview:puckAnimation];
    }
   
    
}

-(IBAction)playVideo:(id)sender
{
    NSURL *movieURL;
    if([LANGUAGE isEqualToString:@"en"])
    {
        movieURL= [NSURL URLWithString:VSN_INSTRN_VIDEO_ENG_URL];
    }
    else
    {
        movieURL= [NSURL URLWithString:VSN_INSTRN_VIDEO_SPN_URL];
    }
    movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer prepareToPlay];
    [movieController.moviePlayer play];
}
- (void)playbackFinished:(NSNotification*)notification
{
    [movieController.moviePlayer stop];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
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
-(IBAction)logInPressed:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Open in Safari?", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil), nil];
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"user pressed OK");
#ifdef HNALERT
        NSURL *url = [NSURL URLWithString:@"http://store.vsnmobil.com"];
#else
        NSURL *url = [NSURL URLWithString:@"http://store.vsnmobil.com"];
#endif
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        NSLog(@"user pressed Cancel");
    }
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
