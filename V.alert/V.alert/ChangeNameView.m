#import "ChangeNameView.h"
#import "SharedData.h"
#import "Constants.h"

@implementation ChangeNameView

@synthesize delegate;
@synthesize rootView;
@synthesize button1,button2,txtContent;
@synthesize window;
@synthesize noOfButtons, lblContent;

- (IBAction)actionOk:(id)sender {
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [self.txtFieldChangeName.text stringByTrimmingCharactersInSet:whitespace];
    if (trimmedString > 0 && ![trimmedString isEqualToString:@""] && ![trimmedString isEqual:[NSNull null]]) {
        
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
        NSString *trimmedString = [self.txtFieldChangeName.text stringByTrimmingCharactersInSet:whitespace];
        [SharedData sharedConstants].strChangName = trimmedString;
        self.onConfirm(YES);
        [self didConfirmationViewUnload];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"device_empty", nil)
                                                        message:NSLocalizedString(@"devicename no empty", nil)                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)actionCancel:(id)sender {
    
    self.onConfirm(NO);
    [self didConfirmationViewUnload];
    
}

- (IBAction)actionChange:(id)sender
{
    
    if(noOfButtons == 2)
        self.onConfirm(NO);
    else if(noOfButtons == 3)
        self.onClicked(2);
    
    [self didConfirmationViewUnload];
}

+ (ChangeNameView *) sharedInstance{
    
    // the instance of this class is stored here
    static ChangeNameView *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        
        myInstance  = [[[self class] alloc] initWithView];
        
    }//End of if statement
    
    //Create new window
    myInstance.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myInstance.window.windowLevel = UIWindowLevelStatusBar;
    myInstance.window.hidden = YES;
    myInstance.window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.01];
    myInstance.window.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_tansparent_background.png"]];
    
    
    return myInstance;
    
}//End of class method


-(id)initWithView
{
    NSArray *arrayOfViews;
    
    
    arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ChangeNameView"
                                                 owner:nil
                                               options:nil];
    
    if ([arrayOfViews count] < 1){
        
        return nil;
    }
    
    
    ChangeNameView *newView = [arrayOfViews objectAtIndex:0];
    newView.layer.cornerRadius = 10.0;
    newView.clipsToBounds = YES;
    newView.layer.borderColor = [UIColor blackColor].CGColor;
    newView.layer.borderWidth = 1;
    self = newView;
    
    return self;
}

-(void)didConfirmationViewLoad:(UIView *)parentView andConfirmationViewTitle:(NSString *)strConfirmationViewTitle andConfirmationViewContent:(NSString *)strConfirmationViewContent andConfirmationViewCallback:(OnConfirm)callback
{
    
    [self.txtFieldChangeName becomeFirstResponder];
    
    [UIMenuController sharedMenuController].menuVisible = NO;
    [button1 setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [button2 setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    NSLog(@"strconfirmationtit:%@",strConfirmationViewTitle);
    //Reset title and content
    [self.lblContent setText:strConfirmationViewTitle];
    [self.txtFieldChangeName setText:strConfirmationViewContent];
    self.rootView = parentView;
    //    //Call back goes here
    self.onConfirm = callback;
    self.txtFieldChangeName.delegate = self;
    lblContent.textColor = [UIColor redColor];
    
    
    NSLog(@"my text:%@",self.lblContent.text);
    
    if([lblContent.text isEqualToString:@"Change Name"] ||[lblContent.text isEqualToString:@"(null)" ])
    {
        NSLog(@" change name;");
        
        lblContent.text=strConfirmationViewTitle;
        
    }
    else{
        
        lblContent.text=[NSString stringWithFormat:@"%@",strConfirmationViewTitle];
    }
    
    _confirmBar.backgroundColor = BRANDING_COLOR;
    _confirmBarVertical.backgroundColor = BRANDING_COLOR;
    
    noOfButtons = 2;
    [self.lblContent setText:NSLocalizedString(@"devicedashboard_renameV.ALRT", nil)];
    [self.lblContent setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
    self.lblContent.textColor=TEXT_COLOR;
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] initWithFrame:self.window.bounds];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    
    [transparentView addSubview:self];
    
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)>>1;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>2;
    // y -= 150;
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[parentView layer] addAnimation:animation forKey:@"layerAnimation"];
    
}

-(void)didConfirmationViewLoad:(UIView *)parentView andConfirmationViewTitle:(NSString *)strConfirmationViewTitle andConfirmationViewContent:(NSString *)strConfirmationViewContent andConfirmationViewCallback:(OnConfirm)callback andImagePath:(NSString *)imagePath{
    
    
    NSLog(@"strconfirmationtit:%@",strConfirmationViewTitle);
    
    self.rootView = parentView;
    //Call back goes here
    self.onConfirm = callback;
    
    noOfButtons = 2;
    
    
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] initWithFrame:parentView.bounds];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    
    [transparentView addSubview:self];
    
    CGRect newFrame = self.window.bounds;
    [transparentView setFrame:newFrame];
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)>>1;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>1;
    y -= 150;
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[parentView layer] addAnimation:animation forKey:@"layerAnimation"];
    
}

// Added by #Sneha
-(void)didConfirmationViewLoad:(UIView *)parentView andConfirmationViewTitle:(NSString *)strConfirmationViewTitle andConfirmationViewContent:(NSString *)strConfirmationViewContent andButtonTitle:(NSArray *)buttonNames andConfirmationViewCallback:(OnClickedCallback)callback{
    
    
    NSLog(@"strconfirmationtit:%@",strConfirmationViewTitle);
    
    
    self.rootView = parentView;
    //Call back goes here
    self.onClicked = callback;
    
    // Rearrange Buttons and assign the titles
    [button1 setTitle:[buttonNames objectAtIndex:0] forState:UIControlStateNormal];
    [button1 setTitle:[buttonNames objectAtIndex:0] forState:UIControlStateHighlighted];
    button1.tag = 0;
    
    [button2 setTitle:[buttonNames objectAtIndex:1] forState:UIControlStateNormal];
    [button2 setTitle:[buttonNames objectAtIndex:1] forState:UIControlStateHighlighted];
    button2.tag = 1;
    
    noOfButtons = 3;
    
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] initWithFrame:parentView.bounds];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    
    // Need to change the locations for the three buttons to adjust.
    
    [transparentView addSubview:self];
    
    
    CGRect newFrame = self.window.bounds;
    [transparentView setFrame:newFrame];
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)>>1;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>1;
    y -= 150;
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    
    // x = lblConfirmationViewContent.frame.origin.x;
    button1.frame = CGRectMake(x,button1.frame.origin.y,button1.frame.size.width,button1.frame.size.height);
    
    x = button1.frame.origin.x + button1.frame.size.width + 30;
    button2.frame = CGRectMake(x,button2.frame.origin.y,button2.frame.size.width,button2.frame.size.height);
    
    
    
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    
    
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[parentView layer] addAnimation:animation forKey:@"layerAnimation"];
    
    
}


-(void)didConfirmationViewUnload{
    
    //Self refer only small view not the transparent view self.super.super refer the parent view
    
    [self.superview removeFromSuperview];
    
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.rootView layer] addAnimation:animation forKey:@"layerAnimation"];
    [self removeFromSuperview];
    [self.window setHidden:YES];
    //self.window = nil;
    //[SharedData sharedInstance].confirmationPopup = nil;
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
/*
- (void)rotateView{
    
//    CGAffineTransform newTransform  = [CGAffineTransform alloc];
    self.superview.transform = [CGAffineTransformIdentity]
    CGRect newFrame = self.window.bounds;
    [self.superview setFrame:newFrame];
    float x = (int)(self.superview.bounds.size.width - self.bounds.size.width)>>1;
    float y = (int)(self.superview.bounds.size.height - self.bounds.size.height)>>1;
    y -= 150;
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    
    
}*/
#pragma mark-Textfield Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField selectAll:self];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.onConfirm(NO);
    [self didConfirmationViewUnload];
    return YES;
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(selectAll:))
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
        }];
        return [super canPerformAction:action withSender:sender];
    }
    return [super canPerformAction:action withSender:sender];
}
- (BOOL)canBecomeFirstResponder
{
    return NO;
}
@end
