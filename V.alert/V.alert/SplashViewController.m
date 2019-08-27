#import "SplashViewController.h"
#import "WelcomeViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "ContactsData.h"
#import "SharedData.h"
#import "navigationview.h"
#import "deviceoffscreen.h"
#import "AgreementViewController.h"
#import "ManageDevicesViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize activityIndicatorSplash,imageSplashScreen,progressView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [activityIndicatorSplash startAnimating];
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    progressValue = 0.1;
    progressTimer  = [NSTimer scheduledTimerWithTimeInterval: 0.01
                                                      target: self
                                                    selector:@selector(startLoading)
                                                    userInfo: nil repeats:YES];
    //Handling empty Contact numbers and names
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:CONTACT_NUMBERS];
    NSArray *defaultContacts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    
    if (defaultContacts.count ==0)
    {
        [[ContactsData sharedConstants].contactNumbers addObject:TEXT_ADD_CONTACT];
        [[ContactsData sharedConstants].contactNumbers addObject:TEXT_ADD_CONTACT];
        [[ContactsData sharedConstants].contactNumbers addObject:TEXT_ADD_CONTACT];
    }
    else
    {
        [ContactsData sharedConstants].contactNumbers= [[NSMutableArray alloc] initWithArray:defaultContacts];
    }
    NSData *dataRepresentingSavedNameArray = [DEFAULTS objectForKey:CONTACT_NAMES];
    NSArray *defaultNames = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedNameArray];
    if (defaultNames.count ==0)
    {
        [[ContactsData sharedConstants].contactNames addObject:TEXT_ADD_CONTACT];
        [[ContactsData sharedConstants].contactNames addObject:TEXT_ADD_CONTACT];
        [[ContactsData sharedConstants].contactNames addObject:TEXT_ADD_CONTACT];
    }
    else
    {
        [ContactsData sharedConstants].contactNames= [[NSMutableArray alloc] initWithArray:defaultNames];
    }
    NSData *dataRepresentingCallArray = [DEFAULTS objectForKey:ENABLED_CALLS];
    NSArray *defaultCalls = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCallArray];
    if (defaultCalls.count ==0)
    {
        [[SharedData sharedConstants].arrEnabledCalls addObject:@"0"];
        [[SharedData sharedConstants].arrEnabledCalls addObject:@"0"];
        [[SharedData sharedConstants].arrEnabledCalls addObject:@"0"];
    }
    else
    {
        [SharedData sharedConstants].arrEnabledCalls= [[NSMutableArray alloc] initWithArray:defaultCalls];
    }
    NSData *dataRepresentingTextArray = [DEFAULTS objectForKey:ENABLED_TEXTS];
    NSArray *defaultTexts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingTextArray];
    if (defaultTexts.count ==0) {
        [[SharedData sharedConstants].arrEnabledTexts addObject:@"0"];
        [[SharedData sharedConstants].arrEnabledTexts addObject:@"0"];
        [[SharedData sharedConstants].arrEnabledTexts addObject:@"0"];
    }
    else
    {
        [SharedData sharedConstants].arrEnabledTexts= [[NSMutableArray alloc] initWithArray:defaultTexts];
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    if(IS_IPHONE_4)
    {
        imageSplashScreen.image = [UIImage imageNamed:@"img_splash_screen_460.png"];
        [imageSplashScreen sizeToFit];
    }
}

//startLoading

-(void)startLoading {
    [self.progressView setProgress:progressValue animated:YES];
    
    progressValue += 0.1;
    if(progressValue >=1)
    {
        [self stopLoading];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    
}

// Fade in and Out

-(void)fadeInandOut{
    
    //Animations for fade in and out of splash screen.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:0.25];
    [imageSplashScreen setAlpha:0.6];
    [UIView commitAnimations];
    
}

//This delegate is called after the completion of Animation for splash screen fade in and out.
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [imageSplashScreen setAlpha:1];
    [UIView commitAnimations];
}
- (void)stopLoading
{
    [progressTimer invalidate];
    [activityIndicatorSplash stopAnimating];
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
  
    //Welcome view
    navigationview *ObjWelcomeViewController;
    ObjWelcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"navigationview"];
    //Home view
    HomeViewController *ObjHomeViewController;
    ObjHomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    //Home view
    AgreementViewController *ObjAggrement;
    ObjAggrement = [storyboard instantiateViewControllerWithIdentifier:@"AgreementViewController"];
    //Home view
    ManageDevicesViewController *Objmanage;
    Objmanage = [storyboard instantiateViewControllerWithIdentifier:@"ManageDevicesViewController"];
   

    switch ([DEFAULTS integerForKey:FLOW_STEP])
    {
        case 0:
            if([DEFAULTS integerForKey:@"language"])
            {
                [self presentViewController:ObjHomeViewController animated:YES completion:nil];
            }
            else
            {
                [self presentViewController:ObjWelcomeViewController animated:YES completion:nil];
            }
            break;
        case 1:
            [self presentViewController:ObjAggrement animated:YES completion:nil];
            break;
        case 2:
            [DEFAULTS setBool:YES forKey:REMOVE_BACK];
            [self presentViewController:Objmanage animated:YES completion:nil];
            break;
        case 3:
            [self presentViewController:ObjHomeViewController animated:YES completion:nil];
            break;
        default:
            [self presentViewController:ObjHomeViewController animated:YES completion:nil];
            break;
            break;
    }
        [DEFAULTS setValue:@"0" forKey:@"welcomeEnable"];
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
