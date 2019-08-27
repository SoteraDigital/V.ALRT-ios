#import "customAlertPopUp.h"

@implementation customAlertPopUp

@synthesize lblAlertMessage;
@synthesize rootView,window, imgViewBG, lblInternetConnectionStatus,btnPopupViewLoad;


+(customAlertPopUp *)sharedInstance{
    
    // the instance of this class is stored here
    static customAlertPopUp *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        
        myInstance = [[[self class] alloc] initWithView];
        
    }//End of if statement
    
    myInstance.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myInstance.window.windowLevel = UIWindowLevelStatusBar;
    myInstance.window.hidden = YES;
    myInstance.window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    return myInstance;
}



-(id)initWithView
{
    
    NSArray *arrayOfViews;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"customAlertPopUpiPad"
                                                     owner:nil
                                                   options:nil];
    }
    else
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"customAlertPopUp"
                                                     owner:nil
                                                   options:nil];
    }
    if ([arrayOfViews count] < 1)
    {
        
        return nil;
    }
    
    customAlertPopUp *newView = [arrayOfViews objectAtIndex:0];
    newView.layer.cornerRadius = 10.0;
    newView.layer.borderColor = [UIColor blackColor].CGColor;
    newView.clipsToBounds = YES;
    self = newView;
    return self;
    
}


- (void)didCustomPopUpAlertLoad:(UIView *)parentView andtitle:(NSString *)strTitle {
    
    [self setRootView:parentView];
    self.lblAlertMessage.text = strTitle;
    
    _confirmBar.backgroundColor = BRANDING_COLOR;
    
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] initWithFrame:parentView.bounds];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    [transparentView addSubview:self];
    
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)>>1;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>2;
    [self setFrame:CGRectMake(x, y+62, self.bounds.size.width, self.bounds.size.height)];
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    
    
}

-(void)didCustomPopUpUnload{
    
    [self.superview removeFromSuperview];
    // Set up the fade-in animation
   // self.window = nil;
    [self removeFromSuperview];
    [self.window setHidden:YES];
   // [self.window setHidden:YES];
    
}

-(IBAction)didActionOkAlertPopUp:(id)sender{
    
    [self didCustomPopUpUnload];
}


- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
