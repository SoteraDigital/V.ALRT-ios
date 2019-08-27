#import "systemsounds.h"
#import "ContactsData.h"
#import "Constants.h"
#import "UINavigationItem+Additions.h"
#include <AudioToolbox/AudioToolbox.h>
#import "UINavigationController+UINavigationController_rotation_h.h"
@interface systemsounds ()

@end

@implementation systemsounds

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[ContactsData sharedConstants] loadSystemSoundsss];
    //left bar button
    UIButton *lftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lftBtn setBackgroundImage:[UIImage imageNamed:@"img_btn_back.png"]
                      forState:UIControlStateNormal];
    lftBtn.frame = CGRectMake(-10, 0,70, 26);
    [lftBtn addTarget:self action:@selector(back)
     forControlEvents:UIControlEventTouchUpInside];
    lftBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    [lftBtn setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    [lftBtn setTitleColor:[UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1] forState:UIControlStateNormal];
    UIBarButtonItem *leftbarButton = [[UIBarButtonItem alloc] initWithCustomView:lftBtn];
    self.navigationItem.leftBarButtonItem = leftbarButton;
    
}
- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets;
    if ([self.navigationItem backBarButtonItem]) {
        insets = UIEdgeInsetsMake(-6, 9.0f, 0, 0);
    }
    else { // IF ITS A RIGHT BUTTON
        insets = UIEdgeInsetsMake(0, 0, 0, 9.0f);
    }
    return insets;
}

//dimisst th current view
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [ContactsData sharedConstants].systemSounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
    // Conf
    
    // Configure the cell...
    NSDictionary *systemSoundItem=[[ContactsData sharedConstants].systemSounds objectAtIndex:indexPath.row];
    cell.textLabel.text=[systemSoundItem valueForKey:@"category"];
    cell.textLabel.textColor = TEXT_COLOR;
    cell.textLabel.font = TEXT_FONT_15;
    
    if ([[systemSoundItem valueForKey:@"soundId"] isEqualToString:[DEFAULTS objectForKey:ALERT_RINGTONE_ID]])
    {
        oldIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (oldIndexPath==nil)
    {
        // No selection made yet
        oldIndexPath=indexPath;
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        UITableViewCell *formerSelectedcell = [tableView cellForRowAtIndexPath:oldIndexPath]; // finding the already selected cell
        [formerSelectedcell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        oldIndexPath=indexPath;
    }
    
    // Save the select sound to defaults
    NSDictionary *systemSoundItem=[[ContactsData sharedConstants].systemSounds objectAtIndex:indexPath.row];
    int systemSoundId=[[systemSoundItem valueForKey:@"soundId"]intValue];
    [DEFAULTS setObject:[systemSoundItem valueForKey:@"category"] forKey:ALERT_RINGTONE_NAME];
    [DEFAULTS setObject:[systemSoundItem valueForKey:@"iphoneFileName"] forKey:ALERT_SOUND_NAME];
    [DEFAULTS setObject:[systemSoundItem valueForKey:@"soundId"] forKey:ALERT_RINGTONE_ID];
    [DEFAULTS synchronize];
    
    //Play the sound
    AudioServicesPlaySystemSound (systemSoundId);
    
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //Return YES for supported orientations
    return (interfaceOrientation== UIInterfaceOrientationMaskPortrait);
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
    
}
@end
