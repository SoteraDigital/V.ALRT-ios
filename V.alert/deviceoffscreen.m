#import "deviceoffscreen.h"
#import "Constants.h"
#import "HomeViewController.h"

@interface deviceoffscreen ()

@end

@implementation deviceoffscreen

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-Custom Action

/*!
 *  @method deviceonAction:
 *@param sender
 *
 *  @discussion Function to switch on the valrt app
 Here is used to set the defaults false for valrt device off and present the home screen
 *
 */
-(IBAction)deviceonAction:(id)sender
{
    [DEFAULTS setBool:NO forKey:VALRT_DEVICE_OFF];
    HomeViewController*Objhome;
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    Objhome = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    Objhome.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:Objhome animated:YES completion:nil];
}

@end
