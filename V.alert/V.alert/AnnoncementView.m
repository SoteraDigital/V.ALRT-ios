#import "AnnoncementView.h"
#import "Constants.h"


@implementation AnnoncementView
@synthesize rootView, window,tableViewAnnouncement;

+(AnnoncementView *)sharedInstance{
    
    // the instance of this class is stored here
    static AnnoncementView *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        
        myInstance = [[[self class] alloc] initWithView];
        
    }//End of if statement
    
    myInstance.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myInstance.window.windowLevel = UIWindowLevelStatusBar;
    myInstance.window.hidden = YES;
    myInstance.window.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_tansparent_background.png"]];
    myInstance.onAnnouncementSelect = nil;
    
    return myInstance;
}
-(id)initWithView{
    
    NSArray *arrayOfViews;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AnnoncementViewiPad"
                                                     owner:nil
                                                   options:nil];
    }else{
        
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AnnoncementView"
                                                     owner:nil
                                                   options:nil];
    }
    
    
    if ([arrayOfViews count] < 1){
        
        return nil;
    }
    
    AnnoncementView *newView = [arrayOfViews objectAtIndex:0];
    self = newView;
    return self;
    
    
}
- (void)didAnnouncementViewLoad:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)annonuncementSelect {
    
    self.rootView = parentView;
    self.onAnnouncementSelect = annonuncementSelect;
    
    //Add alertview into transparent view to hide parent view interaction
    UIView *transparentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [transparentView setBackgroundColor:[UIColor clearColor]];
    [transparentView addSubview:self];
    float x = (int)(transparentView.bounds.size.width - self.bounds.size.width)/2;
    float y = (int)(transparentView.bounds.size.height - self.bounds.size.height)>>2;
    
    [self setFrame:CGRectMake(x, y, self.bounds.size.width, self.bounds.size.height)];
    
    [self.window setFrame:parentView.frame];
    
    [self.window addSubview:transparentView];
    [self.window makeKeyAndVisible];
    _labelAnnouncementTitle.text = NSLocalizedString(@"select_number", nil);
    _labelAnnouncementTitle.textColor =TEXT_COLOR;
    _titleBar.backgroundColor = BRANDING_COLOR;
    
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[parentView layer] addAnimation:animation forKey:@"layerAnimation"];
    self.alpha = 1.0f;
    [self.tableViewAnnouncement reloadData];
    
}



-(void)didAnnouncemntViewUnload{
    
    [self.superview removeFromSuperview];
    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.rootView layer] addAnimation:animation forKey:@"layerAnimation"];
    [self removeFromSuperview];
    [self.window setHidden:YES];
}

- (IBAction)actionDidHideAnnoucementList:(id)sender {
    [self didAnnouncemntViewUnload];
}

#pragma mark - Table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[SharedData sharedConstants].arrSelectMultipleContacts count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
//    if (cell == nil) {
      UITableViewCell *  cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    }
    cell.textLabel.text=[[SharedData sharedConstants].arrSelectMultipleContacts objectAtIndex:indexPath.row];
    cell.textLabel.textColor = TEXT_COLOR;
    cell.textLabel.backgroundColor=[UIColor clearColor];
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [SharedData sharedConstants].strDidSelectContacts = [[SharedData sharedConstants].arrSelectMultipleContacts objectAtIndex:indexPath.row];
    self.onAnnouncementSelect(1);
    [self didAnnouncemntViewUnload];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}



-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    return YES;
}


- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
