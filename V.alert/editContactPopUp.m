#import "editContactPopUp.h"

@implementation editContactPopUp

@synthesize lblAlertMessage;
@synthesize rootView,window, imgViewBG, lblInternetConnectionStatus,btnPopupViewLoad,lblAlertMessagetext2,contactField;


+(editContactPopUp *)sharedInstance{
    
    // the instance of this class is stored here
    static editContactPopUp *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance)
    {
        
        myInstance = [[[self class] alloc] initWithView];
        myInstance.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        myInstance.window.windowLevel = UIWindowLevelStatusBar;
        myInstance.window.hidden = YES;
        myInstance.window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    }
    
    
    return myInstance;
}
-(id)initWithView
{
    
    NSArray *arrayOfViews;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"editContactPopUpiPad"
                                                     owner:nil
                                                   options:nil];
    }else{
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"editContactPopUp"
                                                     owner:nil
                                                   options:nil];
    }
    
    
    if ([arrayOfViews count] < 1){
        
        return nil;
    }
    //self.contactField.delegate = window;
    newView = [arrayOfViews objectAtIndex:0];
    //[newView setFrame:frame];
    newView.layer.cornerRadius = 10.0;
    newView.layer.borderColor = [UIColor blackColor].CGColor;
    newView.clipsToBounds = YES;
    
    self = newView;
    return self;
    
}

- (void)changeText:(NSString *)titelTxt
{
    if(self.window!=nil)
    {
        self.lblAlertMessage.text = titelTxt;
    }
}

- (void)didCustomPopUpAlertLoad:(UIView *)parentView
                       strTitle:(NSString *)strTitle
                       strTitle2:(NSString *)strTitle2
                      txtTitle:(NSString *)txtTitle
{
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelStatusBar;
    self.window.hidden = YES;
    self.window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [self setRootView:parentView];
    self.lblAlertMessage.text = strTitle;
    self.lblAlertMessagetext2.text =strTitle2;
    self.contactField.text = txtTitle;
    self.titleBar.backgroundColor = BRANDING_COLOR;
    
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] initWithFrame:parentView.bounds];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    [transparentView addSubview:self];
    UIView *subView = [transparentView.subviews objectAtIndex:0];
    if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
    {
        subView.frame =CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width, 100);
    }
    else
    {
        subView.frame =CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width, 170);
    }
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)>>1;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>2;
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    if([[DEFAULTS valueForKey:@"countrycode"] isEqualToString:@"US"])
    {
        self.lblAlertMessagetext2.text =@"";
        
    }
    
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    
    
}

-(void)didCustomPopUpUnload{
    
    [self removeFromSuperview];
    [self.superview removeFromSuperview];
    // Set up the fade-in animation
    [self.window setHidden:YES];
    
}

-(IBAction)didActionOkAlertPopUp:(id)sender{
    
    [self didCustomPopUpUnload];
}


- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
