#import "SettingsManageContactsCell.h"
#import "SharedData.h"
#import "ContactsData.h"
#import "customAlertPopUp.h"

@implementation SettingsManageContactsCell

@synthesize lblAddContact,imgViewManageContactIndication,btnEnableForText,btnEnableForCall,isCallEnabled,isTextEnabled,delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        lblAddContact.text = NSLocalizedString(@"Tap to add contact", Nil);
    }
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didActionEnableMakeCall:(id)sender {
    
    
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:CONTACT_NUMBERS];
    NSArray *defaultContacts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];

    UIButton  *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview;
    UITableView *tableView = (UITableView *)cell.superview.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    
    if (![[defaultContacts objectAtIndex:indexPath.row]isEqualToString:TEXT_ADD_CONTACT])
    {
        if ([defaultContacts count] > 0)
        {
            if ([[[SharedData sharedConstants].arrEnabledCalls objectAtIndex:indexPath.row]isEqualToString:@"0"])
            {
                [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:indexPath.row withObject:@"1"];
            }
            else
            {
                [[SharedData sharedConstants].arrEnabledCalls replaceObjectAtIndex:indexPath.row withObject:@"0"];
            }
            
            [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledCalls] forKey:ENABLED_CALLS];
            [DEFAULTS synchronize];
            
            [tableView reloadData];
        }
    else
    {
         //alertview
         [self alertBox];
        }
    }
  else
  {
      //alertview
       [self alertBox];
    }
    
    //Calling to superview to check enable disable call/text
    [[self delegate] calltextEnableDisable];
}

- (IBAction)didActionEnableSendText:(id)sender
{
    
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:CONTACT_NUMBERS];
    NSArray *defaultContacts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    
    UIButton  *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview;
    UITableView *tableView = (UITableView *)cell.superview.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    if (![[defaultContacts objectAtIndex:indexPath.row] isEqualToString:TEXT_ADD_CONTACT])
    {
    
       if ([defaultContacts count] > 0)
       {
        
        NSLog(@"titl %@",[defaultContacts objectAtIndex:indexPath.row]);

        if ([[[SharedData sharedConstants].arrEnabledTexts objectAtIndex:indexPath.row]isEqualToString:@"0"]) {
            
            [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:indexPath.row withObject:@"1"];
        }else{
            [[SharedData sharedConstants].arrEnabledTexts replaceObjectAtIndex:indexPath.row withObject:@"0"];
        }
        
        [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrEnabledTexts] forKey:ENABLED_TEXTS];
        [DEFAULTS synchronize];
        
        [tableView reloadData];
            
        }
       else
       {
            [self alertBox];
        }
    }
    else
    {
        [self alertBox];
    }
    
    //Calling to superview to check enable disable call/text
    [[self delegate] calltextEnableDisable];
}

-(void)alertBox
{
    NSString *myalertMsg = NSLocalizedString(@"Add Contact to Enable Texts and Calls", nil);
    UIAlertView*alertBox2 = [[UIAlertView alloc]initWithTitle:nil message:myalertMsg delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
    [alertBox2 show];
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
