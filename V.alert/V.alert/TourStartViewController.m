#import "TourStartViewController.h"
#import "Constants.h"
#import "AnimatedGif.h"
@interface TourStartViewController ()

@end

@implementation TourStartViewController

@synthesize navigationBar;
@synthesize puckImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
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
    [self.view addSubview:puckAnimation];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    
    
}
- (IBAction)startWalkthrough:(id)sender {

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    puckImageView.translatesAutoresizingMaskIntoConstraints = YES;
    setupBtn.translatesAutoresizingMaskIntoConstraints = YES;
    buyonlineBtn.translatesAutoresizingMaskIntoConstraints = YES;
    
    if(IS_IPHONE_4)
    {
        puckImageView.frame = CGRectMake(55, 126, 214, 214);
        setupBtn.frame = CGRectMake(15, 340, 290, 50);
        buyonlineBtn.frame = CGRectMake(15, 400, 290, 50);
        
    }
    else
    {
        puckImageView.frame = CGRectMake(55, 176, 214, 214);
        setupBtn.frame = CGRectMake(15, 440, 290, 50);
        buyonlineBtn.frame = CGRectMake(15, 498, 290, 50);
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
