#import "PopViewController.h"
#import "SharedData.h"
#import "ContactsData.h"
#import "Constants.h"

@interface PopViewController ()

@end

@implementation PopViewController
@synthesize deviceName,btnDoneaction,findVALRTDeviceLabel;
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
    
    
    self.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_app_background.png"]];
	// Do any additional setup after loading the view.
    [findVALRTDeviceLabel setText:deviceName];
    findVALRTDeviceLabel.textColor = BRANDING_COLOR;
    findVALRTDeviceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    findVALRTDeviceLabel.font = [UIFont boldSystemFontOfSize:17.0];
    
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:20.0];
    
    findImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find_me_puck.png"]];
    findImage.frame = CGRectMake(45, 169, 230, 230);
    
    //Add more images which will be used for the animation
    findImage.animationImages = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"find_me_puck.png"],
                                 [UIImage imageNamed:@"find_me_puck_with_glow.png"],
                                 nil];
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    findImage.animationDuration = 2;
    [findImage startAnimating];
    [self.view addSubview:findImage];
    
    //bar button
    [btnDoneaction setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    
    if(![LANGUAGE isEqualToString:@"en"])
    {
        [btnDoneaction setTitleEdgeInsets:UIEdgeInsetsMake(-1, 0, 0,0 )];        //
    }
    
    //Language Translation
    bottomTxtLbl.text = NSLocalizedString(@"blink_text", nil);
    
}

//cancel the view
- (IBAction)didActionBackViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopLoading {
    
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
