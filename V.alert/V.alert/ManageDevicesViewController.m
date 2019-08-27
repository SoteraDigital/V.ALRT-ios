#import "ManageDevicesViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "ContactsData.h"
#import "customAlertPopUp.h"
#import "commonnotifyalert.h"
#import "CongratulationsViewController.h"
#import "logfile.h"
#import "AppDelegate.h"

#include <AudioToolbox/AudioToolbox.h>

@interface ManageDevicesViewController ()

@end

@implementation ManageDevicesViewController
@synthesize btnActionBack,
btnActionNext,
tblViewPairedDevices,
tblViewAvailableDevices,
vibrateTimer,
falldetectTimer,
normalPeriperal,
ObjBLEConnection,
activePeripheral,
handImageLabel,
handSecondsLbl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
# pragma mark view Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if(!ObjBLEConnection)
    {
        AppDelegate *appDelegateObj = APP_DELEGATE;
        //If AppDelegate has ObjBLEConnection then use it
        if (appDelegateObj.manageDevice.ObjBLEConnection) {
            ObjBLEConnection = appDelegateObj.manageDevice.ObjBLEConnection;
        } else {
            //Objeconnection for bleconnection class
            ObjBLEConnection =[[BLEConnectionClass alloc]init];
            [ObjBLEConnection controlSetup:1]; // Do initial setup of BLE class.
        }
        ObjBLEConnection.delegate = self;
        
    }
    
    
   	// Do any additional setup after loading the view.
    imageView = [[UIImageView alloc]init];
    [AlertInProgress sharedInstance].delegate =self;
    
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [ac startAnimating];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(254, 6, 100, 100)];
    [view addSubview:ac]; // <-- Your UIActivityIndicatorView
    self.tblViewAvailableDevices.layer.cornerRadius=7;
    self.tblViewPairedDevices.layer.cornerRadius=7;
    handImageLabel.text = NSLocalizedString(@"deviceHandLabel", Nil);
    _activateLbl.text = NSLocalizedString(@"activate_device", nil);
    
    headerLabel.text = NSLocalizedString(@"devices_title", nil);
    headerLabel.textColor = BRANDING_COLOR;
    _manageImageBar.backgroundColor = BRANDING_COLOR;
    [btnActionBack setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    [btnActionNext setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    
    if([LANGUAGE isEqualToString:@"en"])
    {
        handSecondsLbl.text=NSLocalizedString(@"handimgae_seconds",nil);
        handSecondsLbl.font =[UIFont boldSystemFontOfSize:15.0];
        [handSecondsLbl setTextAlignment:(NSTextAlignmentLeft)];
        [handSecondsLbl sizeToFit];
        
    }
    else
    {
        
        handImageLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [handImageLabel sizeToFit];
        handSecondsLbl.text=NSLocalizedString(@"handimgae_seconds",nil);
        handSecondsLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [handSecondsLbl sizeToFit];
    }
    
    
    // For refresh the available devices
    [[SharedData sharedConstants].arrDiscovereUUIDs removeAllObjects];
    [[SharedData sharedConstants].arrAvailableIdentifiers removeAllObjects];
    [[SharedData sharedConstants].arrPeriperhalNames removeAllObjects];
    
    
    //check active peripheral is not nil and array count to 0
    if(activePeripheral !=nil && [SharedData sharedConstants].arrActivePeripherals.count ==0)
    {
        [[SharedData sharedConstants].arrActivePeripherals addObject:activePeripheral];
    }
    tblViewAvailableDevices.separatorColor=[UIColor  lightGrayColor];
    [tblViewAvailableDevices reloadData];
    [tblViewPairedDevices reloadData];
    
}

//View will appear

-(void)receiveNotification:(NSNotification *) notification
{
    printf("Key values updated ! \r\n");
    if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT]) {
        
        [[commonnotifyalert alertConstant] repeatRingtone];
    }
    
    [[ContactsData sharedConstants] manageTextsandCalls];
    
    if ([[ContactsData sharedConstants].dictMessageResponse isKindOfClass:[NSNull class]]) {
        
        [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:NSLocalizedString(@"invalid_number", nil)];
    }
    
    
    [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"viewControllerCNotification" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Check bluetooth is disabled
    if([[DEFAULTS valueForKey:@"Bluetooth"]isEqualToString:@"off"])
    {
        UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"bluetooth-off", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        [alertBox show];
    }
    
    if([LANGUAGE isEqualToString:@"en"])
    {
        [btnActionBack setTitleEdgeInsets:UIEdgeInsetsMake(1, 4, 0,0)];
    }
    
    //check button is yes and hide the back button
    if([DEFAULTS boolForKey:REMOVE_BACK])
    {
        [btnActionBack setHidden:YES];
    }
    else
    {
        [btnActionBack setHidden:NO];
    }
    if ([[DEFAULTS valueForKey:@"devicesDone"] isEqualToString:@"set"])
    {
        [btnActionNext setHidden:YES];
    }
    else
    {
        //Set flow step
        [DEFAULTS setInteger:2 forKey:FLOW_STEP];
    }
    //Scan for Devices
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(scanDevices:) userInfo:nil repeats:YES];
    
    [super viewWillAppear:animated];
    [self performSelector:@selector(referreshavailabledevice) withObject:self afterDelay:1.0];
    
   
    
    //@log to check the issue
    if ( [SharedData sharedConstants].arrActivePeripherals.count >0)
    {
       CBPeripheral *peripheral =[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:0];
        
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        NSString*logValue = [NSString stringWithFormat:@"Active peripheral ID-%@- State-%@ Time Stamp -%@",
                             strID,
                             [self getConnectionStatus:peripheral.state]
                             ,[[SharedData sharedConstants] currentDate]];
        [[logfile logfileObj] writeLog:logValue];
       
        //@discussion -Retreive the connected peripheral from os and check our active peripheral is present in that peripherals array.
        //If present replace that peripheral object  to our active peripheral object array.
        NSArray *connectedPeripheral = [ObjBLEConnection.CM retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]]];
        
        if ( [connectedPeripheral count] >0 && [connectedPeripheral containsObject:peripheral])
        {
            NSUInteger index = [connectedPeripheral indexOfObject:peripheral];
            [[SharedData sharedConstants].arrActivePeripherals replaceObjectAtIndex:0 withObject:[connectedPeripheral objectAtIndex:index]];
            CBPeripheral *peripheral =[connectedPeripheral objectAtIndex:0];
           
            NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
            NSString*logValue = [NSString stringWithFormat:@"Connected peripheral ID-%@- State-%@ Time Stamp -%@",
                                 strID,
                                 [self getConnectionStatus:peripheral.state],
                                 [[SharedData sharedConstants] currentDate]];
            [[logfile logfileObj] writeLog:logValue];
            
        }
    }
    
    [self tableviewreloaddata];
    [self checkAvailableorPaired];
}

/*!
 *  @method checkAvailableorPaired:
 *  @discussion check device is in available or paired
 *
 */
-(void)checkAvailableorPaired
{
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
    NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    
    // if(([defaultUUIDS  count] ==0 || defaultUUIDS == nil) && [SharedData sharedConstants].arrActivePeripherals.count ==0)
    dispatch_async(dispatch_get_main_queue(), ^{
      
        if([defaultUUIDS  count] ==0 || defaultUUIDS == nil)
        {
            [self->tblViewPairedDevices setHidden:YES];
            [self->tblViewAvailableDevices setHidden:NO];
            [self->manageimageView setHidden:NO];
            [self->availableView setHidden:NO];
        }
        else
        {
            [self->tblViewPairedDevices setHidden:NO];
            [self->tblViewAvailableDevices setHidden:YES];
            [self->manageimageView setHidden:YES];
            [self->availableView setHidden:YES];
        }
        
    });
}
-(void)referreshavailabledevice
{
    [[SharedData sharedConstants].arrDiscovereUUIDs removeAllObjects];
    [[SharedData sharedConstants].arrAvailableIdentifiers removeAllObjects];
    [[SharedData sharedConstants].arrPeriperhalNames removeAllObjects];
    //[self scanDevices:nil];
    
}
-(void)scanDevices:(NSTimer *)timer{
    
    
    [ObjBLEConnection findBLEPeripherals:5];
    //Remove image
    
    [tblViewAvailableDevices reloadData];
    [tblViewPairedDevices reloadData];
    
}
-(void)tableviewreloaddata
{
    //Remove image
    
    [tblViewAvailableDevices reloadData];
    [tblViewPairedDevices reloadData];
    
}
-(void)referreshtabledata
{
    //Remove image
    
    [tblViewAvailableDevices reloadData];
    [tblViewPairedDevices reloadData];
}
#pragma mark - TABLEVIEW DELEGATES

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == tblViewAvailableDevices) {
        
        if ([[SharedData sharedConstants].arrPeriperhalNames count] > 1) {
            
            return  [[SharedData sharedConstants].arrPeriperhalNames count];
        }else{
            
            return 1;
        }
    }else if (tableView == tblViewPairedDevices){
        
        if ([[SharedData sharedConstants].arrActivePeripherals count] > 1) {
            [tblViewAvailableDevices setFrame:CGRectMake(20, 208, 280, 120)];
            return [[SharedData sharedConstants].arrActivePeripherals count];
        }else{
            return 1;
        }
        
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}

-(void)viewDidDisappear:(BOOL)animated
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Get the dictionary value
    static NSString *strAvailableIdentifier = @"AvailableDevicesCustomCell";
    static NSString *strPairedIdentifier    = @"PairedDevicesCustomCell";
    
    @try {
        
        if (tableView == tblViewPairedDevices )
        {
            
            PairedDevicesCustomCell *cell=(PairedDevicesCustomCell *)[tableView dequeueReusableCellWithIdentifier:strPairedIdentifier];
            
            if (cell == nil)
            {
                cell = [[PairedDevicesCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strPairedIdentifier];
            } //End of cell creation
            NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
            NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
            if (defaultUUIDS != nil)
            {
                if ( [SharedData sharedConstants].arrActivePeripherals.count >0)
                {
                    [cell.lblDetectdevice setHidden:NO];
                    if (![[DEFAULTS valueForKey:@"devicesDone"] isEqualToString:@"set"])
                    {
                        [btnActionNext setEnabled:YES];
                        [btnActionNext setHidden:NO];
                    }
                    CBPeripheral *peripheral =[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:0];
                    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                    strID = [strID substringFromIndex: [strID length] - 20];
                    [cell.lblnoPaireddevice setHidden:YES];
                    [cell.lblPaireddevice setHidden:NO];
                    [cell.lblPaireddevice setText:[DEFAULTS objectForKey:strID]];
                    
                    [cell.btnDeleteDevices setHidden:NO];
                    cell.lblDetectdevice.text = [self getConnectionStatus:peripheral.state];
                }
                else
                {
                    [SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
                    if( [[SharedData sharedConstants].arrDiscovereUUIDs count]>0)
                    {
                        [cell.lblnoPaireddevice setHidden:YES];
                        [cell.lblPaireddevice setHidden:NO];
                        [cell.lblDetectdevice setHidden:NO];
                        if (![[DEFAULTS valueForKey:@"devicesDone"] isEqualToString:@"set"])
                        {
                            [btnActionNext setEnabled:YES];
                            [btnActionNext setHidden:NO];
                        }
                        NSString *strID = [NSString stringWithFormat:@"%@", [[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0]];
                        strID = [strID substringFromIndex: [strID length] - 20];
                        [cell.lblPaireddevice setText:[DEFAULTS objectForKey:strID]];
                        
                        [cell.btnDeleteDevices setHidden:NO];
                        cell.lblDetectdevice.text = [self getConnectionStatus:0];
                    }
                    else
                    {
                        [cell.lblDetectdevice setHidden:YES];
                        [btnActionNext setHidden:YES];
                        [cell.lblPaireddevice setHidden:YES];
                        [cell.lblnoPaireddevice setHidden:NO];
                        cell.lblnoPaireddevice.frame = CGRectMake(7, 1, 260, 44);
                        cell.lblPaireddevice.textAlignment = NSTextAlignmentLeft;
                        cell.lblnoPaireddevice.text = NSLocalizedString(@"lblPaireddevice_text", nil);
                        [cell.btnDeleteDevices setHidden:YES];
                        
                    }
                }
            }
            else
            {
                [cell.lblDetectdevice setHidden:YES];
                [btnActionNext setHidden:YES];
                [cell.lblPaireddevice setHidden:YES];
                [cell.lblnoPaireddevice setHidden:NO];
                cell.lblnoPaireddevice.frame = CGRectMake(7, 1, 260, 44);
                cell.lblPaireddevice.textAlignment = NSTextAlignmentLeft;
                cell.lblnoPaireddevice.text = NSLocalizedString(@"lblPaireddevice_text", nil);
                [cell.btnDeleteDevices setHidden:YES];
                
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
            
        }
        else if (tableView == tblViewAvailableDevices)
        {
            
            AvailableDevicesCustomCell *cell=(AvailableDevicesCustomCell *)[tableView dequeueReusableCellWithIdentifier:strAvailableIdentifier];
            if (cell == nil)
            {
                cell = [[AvailableDevicesCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strAvailableIdentifier];
                
            } //End of cell creation
            if ( [SharedData sharedConstants].arrPeriperhalNames.count >0)
            {
                [cell.lblnoAvailableDeviceName setHidden:YES];
                [cell.lblAvailableDeviceName setHidden:NO];
                [cell.btnAddDevices setHidden:NO];
                CBPeripheral *peripheral =[[SharedData sharedConstants].arrPeriperhalNames objectAtIndex:indexPath.row];
                NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                strID = [strID substringFromIndex: [strID length] - 20];
                cell.lblAvailableDeviceName.textAlignment = NSTextAlignmentLeft;
                [cell.lblAvailableDeviceName setText:[DEFAULTS objectForKey:strID]];
                //Stop animating the activity indicator
                [activityManage removeFromSuperview];
                
            }
            else
            {
                [cell.lblAvailableDeviceName setHidden:YES];
                [cell.lblnoAvailableDeviceName setHidden:NO];
                [cell.btnAddDevices setHidden:YES];
                cell.lblnoAvailableDeviceName.frame = CGRectMake(7, 1, 230, 44);
                cell.lblAvailableDeviceName.textAlignment = NSTextAlignmentLeft;
                cell.lblnoAvailableDeviceName.text = NSLocalizedString(@"no_device", nil);
                
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
            
        }
        
    }@catch (NSException *exception) {
        
        NSLog(@"Exception %@", [exception description]);
        
    }
    
}//End of method

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView == tblViewAvailableDevices)
    {
        NSLog(@"ManageDevicesViewController::didSelectRowAtIndexPath pairing with device");
        if ([SharedData sharedConstants].arrPeriperhalNames.count >0 )
        {
            CBPeripheral *peripheral =[[SharedData sharedConstants].arrPeriperhalNames objectAtIndex:indexPath.row];
            activePeripheral = peripheral;
            NSLog(@"selected peripheral - %@",peripheral);
            NSLog(@"selected peripheral state - %d",(int)peripheral.state);
            NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
            NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
            if (defaultUUIDS != nil)
            {
                if([SharedData sharedConstants].arrActivePeripherals.count >=1)
                {
                    UIAlertView*moreDevAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"forget_device", nil) message:@""
                                                                         delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                    [moreDevAlert show];
                }
                else
                {
                    [SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
                    if( [[SharedData sharedConstants].arrDiscovereUUIDs count]>0)
                    {
                        UIAlertView*moreDevAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"forget_device", nil) message:@""
                                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                        [moreDevAlert show];
                    }
                    else
                    {
                        [ObjBLEConnection connectPeripheral:peripheral];
                        [[SharedData sharedConstants].arrPeriperhalNames removeObject:peripheral];
                        
                    }
                }
            }
            else
            {
                [ObjBLEConnection connectPeripheral:peripheral];
                [[SharedData sharedConstants].arrPeriperhalNames removeObject:peripheral];
            }
            [tblViewAvailableDevices reloadData];
            [tblViewPairedDevices reloadData];
            ObjBLEConnection.isFullyDisconnected = YES;
            // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            // Regiser for HUD callbacks so we can remove it from the window at the right time
            HUD.delegate = self;
            // Show the HUD while the provided method executes in a new thread
            [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
        }
        
        
    }
    else if (tableView == tblViewPairedDevices)
    {
        NSLog(@"ManageDevicesViewController::didSelectRowAtIndexPath clicked pairing device");
        NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
        NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (defaultUUIDS != nil)
        {
            if([SharedData sharedConstants].arrActivePeripherals.count>0)
            {
                CBPeripheral *peripheral = [[SharedData sharedConstants].arrActivePeripherals objectAtIndex:indexPath.row];
                activePeripheral = peripheral;
                
                //user feedback chnages starts
                UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Are you sure want to forgot this device", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil)  otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
                [alertBox show];
                
            }
            else
            {
                [SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
                if( [[SharedData sharedConstants].arrDiscovereUUIDs count]>0)
                {
                    
                    UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Are you sure want to forgot this device", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil)  otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
                    [alertBox show];
                }
                
            }
        }
        
    }
    
}

#pragma mark : Tracker Get Activated/Diactivated

//Tracker: Called when Periferal Device Get disconnected
-(void)deviceDisconnected{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertInProgress sharedInstance] didAnnouncementDeviceConnect:self.view andAnnouncementSelect:^(int announcemntId){}];
    });
}

//Tracker: Called when Periferal Device Get Connected Again
-(void)deviceConnectedAgain{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertInProgress sharedInstance] cancelAllActions];
    });
    
}

#pragma mark -
#pragma mark Execution code
//To stop the progress view
- (void)myTask {
    // Do something usefull in here instead of sleeping ...
    sleep(3);
    //check device in paired or available
    [self checkAvailableorPaired];
}

#pragma mark-Custom Actions
/*
 *  @method pairedDeviceAction
 *
 *  @param sender
 *
 *
 *  @discussion check the activepheral count and if >0 , add to the paired device
 *
 */
- (IBAction)pairedDeviceAction:(id)sender
{
    NSLog(@"ManageDeviceViewController::pairedDeviceAction");
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
    NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    if (defaultUUIDS != nil)
    {
        if([SharedData sharedConstants].arrActivePeripherals.count>0)
        {
            UITableViewCell *clickedCell = (PairedDevicesCustomCell *)[[[sender superview] superview]  superview];
            NSIndexPath *indexPath = [tblViewPairedDevices indexPathForCell:clickedCell];
            CBPeripheral *peripheral = [[SharedData sharedConstants].arrActivePeripherals objectAtIndex:indexPath.row];
            activePeripheral = peripheral;
            
            //user feedback chnages starts
            UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Are you sure want to forgot this device", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil)  otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
            [alertBox show];
            
        }
        else
        {
            UIAlertView*alertBox = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Are you sure want to forgot this device", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"alrt_no", nil)  otherButtonTitles:NSLocalizedString(@"alrt_yes", nil), nil];
            [alertBox show];
        }
    }
    
    
}

/*
 *  @method AvailableDeviceAction
 *
 *  @param sender
 *
 *
 *  @discussion get the scan device and show in the available device section in tableview
 *
 */
- (IBAction)AvailableDeviceAction:(id)sender
{
    if ([SharedData sharedConstants].arrPeriperhalNames.count >0 )
    {   UITableViewCell *clickedCell;
        if([SYSTEM_VERSION integerValue] <8.0)
        {
            clickedCell = (AvailableDevicesCustomCell *)[[[sender superview] superview] superview];
        }
        else
        {
            clickedCell = (AvailableDevicesCustomCell *)[[sender superview] superview];
        }
        NSIndexPath *indexPath = [tblViewAvailableDevices indexPathForCell:clickedCell];
        CBPeripheral *peripheral =[[SharedData sharedConstants].arrPeriperhalNames objectAtIndex:indexPath.row];
        activePeripheral = peripheral;
        NSLog(@"selected peripheral - %@",peripheral);
        
        NSLog(@"selected peripheral state - %d",(int)peripheral.state);
        NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
        NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (defaultUUIDS != nil)
        {
            if([SharedData sharedConstants].arrActivePeripherals.count >=1)
            {
                UIAlertView*moreDevAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"forget_device", nil) message:@""
                                                                     delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                [moreDevAlert show];
            }
            else
            {
                [SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
                if( [[SharedData sharedConstants].arrDiscovereUUIDs count]>0)
                {
                    UIAlertView*moreDevAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"forget_device", nil) message:@""
                                                                         delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                    [moreDevAlert show];
                }
                else
                {
                    [ObjBLEConnection connectPeripheral:peripheral];
                    [[SharedData sharedConstants].arrPeriperhalNames removeObject:peripheral];
                    
                }
            }
        }
        else
        {
            [ObjBLEConnection connectPeripheral:peripheral];
            [[SharedData sharedConstants].arrPeriperhalNames removeObject:peripheral];
        }
        [tblViewAvailableDevices reloadData];
        [tblViewPairedDevices reloadData];
        
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    }
    
}
//Heade and Footer Views of TableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    
    return 30.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (tableView == tblViewAvailableDevices) {
        //return 10.0f;
    }
    return 0;
    
    
    
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width, 30)];
    UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0,5, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [subview setBackgroundColor:[UIColor colorWithRed:218.0/255.0f green:218.0f/255.0f blue:218.0/255.0f alpha:0.85]];
    
    
    UIImageView *imgHeaderBackground=[[UIImageView alloc]initWithFrame:CGRectMake(-8,0, tableView.bounds.size.width+12, 30)];
    
    imgHeaderBackground.frame =headerView.frame;
    imgHeaderBackground.backgroundColor =[UIColor colorWithRed:218.0/255.0f green:218.0f/255.0f blue:218.0/255.0f alpha:0.85];
    imgHeaderBackground.layer.cornerRadius =7.0;
    [headerView addSubview:imgHeaderBackground];
    [imgHeaderBackground addSubview:subview];
    
    //Label
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0, headerView.bounds.size.width, 30 )];
    //headerLabel.font= TEXT_FONT_16;
    [headerLabel setBackgroundColor:[UIColor colorWithRed:218.0/255.0f green:218.0f/255.0f blue:218.0/255.0f alpha:0.85]];
    headerLabel.textColor = TEXT_COLOR;
    headerLabel.font = [UIFont boldSystemFontOfSize:17.0];
    
    
    
    
    UIImageView *borderfordevice=[[UIImageView alloc] initWithFrame:(CGRectMake(0,31,headerView.bounds.size.width, 1))];
    [borderfordevice setBackgroundColor:BRANDING_COLOR];
    
    //user feedback changes starts
    if (tableView == tblViewAvailableDevices)
    {
        [headerLabel setText:NSLocalizedString(@"available_device", nil)];
        if ( [SharedData sharedConstants].arrPeriperhalNames.count ==0)
        {
            activityManage = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityManage startAnimating];
            activityManage.frame = CGRectMake(255, 0, 30, 30);
            [headerLabel addSubview:activityManage];
        }
    }else if (tableView == tblViewPairedDevices) {
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6,0, headerView.bounds.size.width, 30 )];
        // headerLabel.font= TEXT_FONT_16;
        [headerLabel setBackgroundColor:[UIColor colorWithRed:218.0/255.0f green:218.0f/255.0f blue:218.0/255.0f alpha:0.85]];
        headerLabel.textColor = TEXT_COLOR;
        headerLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [headerLabel setText:NSLocalizedString(@"paired_device", nil)];
    }
    //user feedback changes ends
    
    [imgHeaderBackground addSubview:headerLabel];
    [imgHeaderBackground addSubview:borderfordevice];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width, 10)];
    [footerView setBackgroundColor:[UIColor colorWithRed:218.0/255.0f green:218.0f/255.0f blue:218.0/255.0f alpha:0.85]];
    
    return footerView;
}

#pragma mark-Alertview Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // user tapped a button, don't dismiss alert programatically (i.e. invalidate timer)
    //user feedback changes starts
    if(buttonIndex==1)  //user feedback changes ends
    {
        if(activePeripheral !=nil)
        {
            [DEFAULTS setBool:YES forKey:IS_DEVICE_REMOVED];
            
            [self.ObjBLEConnection.CM cancelPeripheralConnection:activePeripheral];
           
            [[SharedData sharedConstants].arrActivePeripherals removeAllObjects];
            [[SharedData sharedConstants].arrActiveIdentifiers removeAllObjects];
            [[SharedData sharedConstants].arrAvailableIdentifiers removeAllObjects];
            NSString *strID = [NSString stringWithFormat:@"%@",activePeripheral.identifier];
            strID = [strID substringFromIndex: [strID length] - 20];
            dConnect = [[dbConnect alloc]init];
            [dConnect deleteDeviceInfo:strID];
            [dConnect addfallenableDevice:strID bleFlag:@"0"];
            
            //Insert value to the database
            NSString *_date=[[SharedData sharedConstants] currentDate];
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date]  bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"devicedashboard_forgetme", nil)];
            
            [[SharedData sharedConstants].arrDiscovereUUIDs removeAllObjects];
            [DEFAULTS removeObjectForKey:BLE_DISCOVERED_UUIDS];
            [DEFAULTS synchronize];
            activePeripheral = nil;
            [SharedData sharedConstants].activePeripheral = nil;
            ObjBLEConnection.activePeripheral = nil;
            
            [tblViewPairedDevices reloadData];
            
        }
        else
        {
            [[SharedData sharedConstants].arrActivePeripherals removeAllObjects];
            [[SharedData sharedConstants].arrActiveIdentifiers removeAllObjects];
            [[SharedData sharedConstants].arrAvailableIdentifiers removeAllObjects];
            [[SharedData sharedConstants].arrDiscovereUUIDs removeAllObjects];
            [DEFAULTS removeObjectForKey:BLE_DISCOVERED_UUIDS];
            [DEFAULTS synchronize];
            [tblViewPairedDevices reloadData];
        }
        //check device in paired or available
        [self checkAvailableorPaired];
    }
    else{
        [DEFAULTS setBool:NO forKey:IS_DEVICE_REMOVED];
        [DEFAULTS synchronize];
    }
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES;
}




#pragma mark-textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (BOOL)canBecomeFirstResponder
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


//Delegate method call for battery status
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral
{
    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strID = [strID substringFromIndex: [strID length] - 20];
    
    //Notify alert to user for low battery
    [[commonnotifyalert alertConstant] Notifybatterystatus:[DEFAULTS objectForKey:strID]  deviceId:strID device:[SharedData sharedConstants].strBatteryLevelStatus];
    
}


-(void)invalidateTimer{
    
    [self performSelectorOnMainThread:@selector(print) withObject:nil waitUntilDone:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoptimer" object:nil];
    
}

-(void)print{
    [vibrateTimer invalidate];
    vibrateTimer = nil;
}


-(NSString*)getConnectionStatus:(int)peripheralState
{
    
    switch(peripheralState)
    {
        case 0:
            return[NSString stringWithFormat:NSLocalizedString(@"not_connected", nil)];
        case 1:
            return  [NSString stringWithFormat:NSLocalizedString(@"connecting", nil)];
        case 2:
           return [NSString stringWithFormat:NSLocalizedString(@"connected", nil)];
   }
    NSLog(@"Uknown Connection State: %d",peripheralState);
    return [NSString stringWithFormat:NSLocalizedString(@"waiting", nil)];
}


- (IBAction)didActionBackViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didActionNextViewController:(id)sender {
    
    UIStoryboard *storyboard = IPHONE_STORYBOARD;
    
    NSUInteger initialSetup = [DEFAULTS integerForKey:INITIAL_SETUP];
    
    if (initialSetup==0)
    {
        CongratulationsViewController *ObjCongratulationsViewController;
        ObjCongratulationsViewController = [storyboard instantiateViewControllerWithIdentifier:@"CongratulationsViewController"];
        ObjCongratulationsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        ObjCongratulationsViewController.ObjBLEConnection = ObjBLEConnection;
        [self presentViewController:ObjCongratulationsViewController animated:YES completion:nil];
    }
}

#pragma mark-Custom Delegates

/*!
 *  @method keyValuesUpdated:
 *@param peripheral object
 *
 *  @discussion Function get called when key value pressed from the puck
 Here updating the key status to the dababase for log,put the puck to the normal mode
 *
 */
-(void) keyValuesUpdated:(CBPeripheral *)peripheral
{
    ///short press handler??
    if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue] !=1 )
    {
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        //insert the device connection status
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName: [DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"V.ALRT Key pressed", nil)];
        
        [DEFAULTS setValue:@"1" forKey:@"KeyPressed"];
        
        normalPeriperal = peripheral;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(normalMode) name:@"pucktonormal" object:nil];
        
        
        [[ContactsData sharedConstants] manageTextsandCalls];
        if ([[ContactsData sharedConstants].dictMessageResponse isKindOfClass:[NSNull class]])
        {
            
            [[customAlertPopUp sharedInstance] didCustomPopUpAlertLoad:self.view andtitle:NSLocalizedString(@"invalid_number", nil)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
        });
        
    }
    
}



//Delagate for key fall
-(void)keyfall
{
    [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
}

//Key fall popup
-(void)keyfallpopup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:keyFallNotification object:nil];
    //Open the popup in a  main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlertInProgress sharedInstance] didAnnouncementViewLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
    });
    
}

//put the puck to silent mode
-(void)normalMode
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:keyFallNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pucktonormal" object:nil];
    [SharedData sharedConstants].normalMode =1;
    [ObjBLEConnection disableAlert:normalPeriperal];
}

// Method from BLEDelegate, called when fall detection values are updated
-(void) fallDetected:(CBPeripheral *)peripheral
{
    if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue] !=1)
    {
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(normalMode) name:@"pucktonormal" object:nil];
        
        //Add observer for keyfall popup
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyfallpopup) name:keyFallNotification object:nil];
        
        normalPeriperal = peripheral;
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        
        //insert the device connection status
        NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        strID = [strID substringFromIndex: [strID length] - 20];
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"V.FALL fall Detect", nil)];
        
        //open the pop up in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertInProgress sharedInstance] didAnnouncementfallLoad:self.view andAnnouncementSelect:^(int announcemntId){}];
        });
        
        [DEFAULTS setObject:@"1" forKey:@"FallDetecct"];
    }
    
}

///
-(void) keyfobReady
{
    NSLog(@"ManageDevicesViewController::keyfobReady -- initialize puck settings");

    [SharedData sharedConstants].verifyMode = 1;
    [ObjBLEConnection verifyPairing:[ObjBLEConnection activePeripheral]];
    [ObjBLEConnection enableButtons:[ObjBLEConnection activePeripheral]];
    if ([DEFAULTS boolForKey:DISABLE_VALERTDEVICE_SILENT])
    {
        for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
        {
            [ObjBLEConnection silentNormalmode:0x03 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
    }
    else
    {
        for(int i=0;i<[[SharedData sharedConstants].arrActivePeripherals count] ; i++)
        {
            [ObjBLEConnection silentNormalmode:0x00 periperal:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
        }
    }
    //Read Battery
    [SharedData sharedConstants].readBtry =1;
    [ObjBLEConnection readBattery:[ObjBLEConnection activePeripheral]];
    //Write value to adjust connection interval
    [SharedData sharedConstants].adjustMode =1;
    [ObjBLEConnection adjustInterval:[ObjBLEConnection activePeripheral]];
    
    //Add the device info to the table
    dConnect = [[dbConnect alloc]init];
    //insert the device connection status
    
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    tblViewAvailableDevices.translatesAutoresizingMaskIntoConstraints = YES;
    tblViewPairedDevices.translatesAutoresizingMaskIntoConstraints = YES;
    handimageView.translatesAutoresizingMaskIntoConstraints = YES;
    handImageLabel.translatesAutoresizingMaskIntoConstraints = YES;
    handSecondsLbl.translatesAutoresizingMaskIntoConstraints = YES;
   // tblViewAvailableDevices.frame = CGRectMake(10, 315, 300, 160);
    tblViewAvailableDevices.backgroundColor = [UIColor clearColor];
    handSecondsLbl.frame = CGRectMake(200, 115, 92, 21);
    if(IS_IPHONE_5)
    {
        
        tblViewAvailableDevices.frame = CGRectMake(10, 315, 300, 160);
    }
    
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
#pragma MEMORY MANAGEMENT

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
