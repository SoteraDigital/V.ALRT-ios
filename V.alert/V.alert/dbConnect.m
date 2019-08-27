#import "dbConnect.h"
#import "Constants.h"

@implementation dbConnect

//@synthesize date,name,address,status;

#pragma mark DBConnections
///
- (void)verifyDatabase:(NSString *)dbName databasePath:(NSString *)dbPath { 
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	if (![fileManager fileExistsAtPath:dbPath]) 
	{ 
		NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName]; 
		[fileManager copyItemAtPath:databasePathFromApp toPath:dbPath error:nil]; 
	} 
	
}
///
-(bool)openDB
{
	databaseName = @"valert.sql";
	documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]; 
    documentsPath = [documentsDir stringByAppendingPathComponent:databaseName];
    
	
	[self verifyDatabase:databaseName databasePath:documentsPath];
    int err = sqlite3_open([documentsPath UTF8String], &database);
	if( err != SQLITE_OK)
    {
        NSLog(@"Failed openDB error:%d",err);
        return false;
	}
    return true;
}
///Use this to write a message to the database history log
-(void)addStatus:(NSString *)bledate
         bleName:(NSString *)bleName
      bleAddress:(NSString *)bleAddress
       bleStatus:(NSString *)bleStatus
{
    const char *sql = nil;
	if(![self openDB])
    {
        NSLog(@"Cannot open database for addStatus ");
        return;
    }
    
    sql = [[NSString stringWithFormat:@"insert into history(dates,devicename,macaddress,status) values ('%@','%@','%@','%@')",
            bledate,
            bleName,
            bleAddress,
            bleStatus] UTF8String];

    char* errorMessage = NULL;
    int err = sqlite3_exec(database, sql, NULL,NULL, &errorMessage);
    if (err != SQLITE_OK)
    {
        NSLog(@"failure to add to status logs error:%d Sql:%s",err,sql);
    }

    sqlite3_close(database);
}

///Update the device info
-(void)updatestatus:(NSString *)fieldName value:(NSString *)FieldValue mac:(NSString *)StrId
{
    [self openDB];
    const char *sqlStatement = nil;
    static sqlite3_stmt *compiledStatement;
    if(sqlite3_open([documentsPath UTF8String], &database) != SQLITE_OK)
    {
        NSLog(@"error opening database: %s",[documentsPath UTF8String]);
    }else
    {
        sqlStatement = [[NSString stringWithFormat:@"update history set %@ = '%@'  where macaddress = '%@'",fieldName,FieldValue,StrId] UTF8String] ;
        NSLog(@"field value sql:%@", [NSString stringWithFormat:@"update history set %@ = '%@'  where macaddress = '%@'",fieldName,FieldValue,StrId]);
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"error updating device info Updated: %s", sqlite3_errmsg(database));
        }
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
        {
            NSLog(@"Error insert failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_finalize(compiledStatement);
    sqlite3_close(database);
}

///Add device info
-(void)adddeviceinfo:(NSString *)bleserialno
             bleName:(NSString *)bleName
          bleAddress:(NSString *)bleAddress
         softwarever:(NSString *)softwarever
{


	const char *sql = nil;
    static sqlite3_stmt *compiledStatement;
	[self openDB];
    
    NSString *playlist = @"";
	
	// Open the database from the users filessytem
	if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
		
        sql =[[NSString stringWithFormat:@"select id from deviceinfo where macaddress = '%@'",bleAddress]UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                // Read the data from the result row
                playlist = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSLog(@"addDeviceInfoResultId:%@",playlist);
            }
        }
        else
        {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }

        if([playlist integerValue]==0)
        {
            sql = [[NSString stringWithFormat:@"insert into deviceinfo(serialno,devicename,macaddress,macId,softwarever) values ('%@','%@','%@','%@','%@')",@"12356",bleName,bleAddress,@"32:09:56",@"23233:09"] UTF8String];
            if (sqlite3_exec(database, sql, NULL,NULL, NULL) == SQLITE_OK)
            {
                
                NSLog(@"Inserted bleserial and name:%s",sql);
            }
            else {
                 NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
                NSLog(@"Not Inserted");
            }
        }
	}
    sqlite3_finalize(compiledStatement);
    sqlite3_close(database);
}
///Update the device info
-(void)updatedeviceinfo:(NSString *)fieldName value:(NSString *)FieldValue mac:(NSString *)StrId
{
    [self openDB];
    const char *sqlStatement = nil;
    static sqlite3_stmt *compiledStatement;
    if(sqlite3_open([documentsPath UTF8String], &database) != SQLITE_OK)
    {
        NSLog(@"error opening database: %s",[documentsPath UTF8String]);
    }else
    {
        sqlStatement = [[NSString stringWithFormat:@"update deviceinfo set %@ = '%@'  where macaddress = '%@'",fieldName,FieldValue,StrId] UTF8String] ;
        NSLog(@"field value sql:%s", sqlStatement);
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"error updating device info Updated: %s", sqlite3_errmsg(database));
        }
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
        {
            NSLog(@"Error insert failed: failed to prepare statement with message '%s'", sqlite3_errmsg(database));
        }
    }
    sqlite3_finalize(compiledStatement);
    sqlite3_close(database);
}
///Delete the Device
-(void)deleteDeviceInfo:(NSString *)StrId
{
    [self openDB];
    //BOOL result;
    const char *sqlStatement = nil;
    
    sqlStatement =[[NSString stringWithFormat:@"delete from deviceinfo where macaddress ='%@'",StrId] UTF8String];
    
    
    if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
        if (sqlite3_exec(database, sqlStatement, NULL,NULL, NULL) == SQLITE_OK)
        {
            
           
        }
        else
        {
            NSLog(@"Failed");
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            
        }
    }
    sqlite3_close(database);
   
}

///Fetch the device information
///Code by ashok
-(NSMutableArray *)fetchDeviceinfo
{
    
    [self openDB];
    NSMutableArray *dataArray;
    if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = "select * from deviceinfo order by id desc limit 0,1";
        sqlite3_stmt *compiledStatement;
          dataArray = [[NSMutableArray alloc]init];
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            // Loop through the results and add them to the feeds array
         
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                // Read the data from the result row
                idValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                serialno = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                deviceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                macaddr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                macId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                softvers = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:idValue forKey:@"deviceid"];
                [dic setValue:serialno forKey:@"serialno"];
                [dic setValue:deviceName forKey:@"vname"];
                [dic setValue:macaddr forKey:@"vaddress"];
                [dic setValue:macId forKey:@"macid"];
                [dic setValue:softvers forKey:@"sofver"];
                [dataArray addObject:dic];
                NSLog(@"dataArray %@",dataArray);
                
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    return dataArray;
}

///Add device info
-(void)addfallenableDevice:(NSString *)bleaddress bleFlag:(NSString *)bleFlag
{
	
	const char *sql = nil;
    static sqlite3_stmt *compiledStatement;
	[self openDB];
    
    NSString *playlist = @"";
	
	// Open the database from the users filessytem
	if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
		
        sql =[[NSString stringWithFormat:@"select id from falldetect where macaddress = '%@'",bleaddress]UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                // Read the data from the result row
                playlist = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSLog(@"fallDetectRow select result:%@",playlist);
            }
        }
        else
        {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        //          sqlite3_finalize(compiledStatement);
		//sqlite3_stmt *insert_statement = nil;
        if([playlist integerValue]==0)
        {
            sql = [[NSString stringWithFormat:@"insert into falldetect(macaddress,fallenable) values ('%@','%@')",bleaddress,bleFlag] UTF8String];
          
        }
        else
        {
            sql = [[NSString stringWithFormat:@"update falldetect set fallenable ='%@' where macaddress ='%@'",bleFlag,bleaddress] UTF8String];
        }
        if (sqlite3_exec(database, sql, NULL,NULL, NULL) != SQLITE_OK)
        {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            NSLog(@"Not Inserted");
        }
	}
    sqlite3_finalize(compiledStatement);
    sqlite3_close(database);
}

///
-(int)checkfallenableDevice:(NSString *)address
{
    	[self openDB];
        int count = 0;
    if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = nil;
        sqlStatement =[[NSString stringWithFormat:@"select count(id) from falldetect where macaddress='%@' and fallenable =1",address] UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                count = sqlite3_column_int(compiledStatement, 0);
                //count = 1;
            }
        }
    }
    //sqlite3_finalize(compiledStatement);
    sqlite3_close(database);
    NSLog(@"dbConnect::checkfallenableDevice %@:%d",address,count);
    return count;
    
}

///Fetch history logs
 -(NSMutableArray *)fetchTable
{
 
    [self openDB];
    NSMutableArray *dataArray;
    if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
        //For future use.
        // Setup the SQL Statement and compile it for faster access
        /*  NSString*filterString = [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','App upgrade','Power up or normal kill by user','system kill by OS','LaunchedForBluetoothRestore','will restore state','%@','%@','%@','%@','%@','%@','%@','%@','%@'",NSLocalizedString(@"db_fall_enable", nil),NSLocalizedString(@"V.ALRT Key pressed", nil),NSLocalizedString(@"connected", nil),NSLocalizedString(@"disconnected", nil),NSLocalizedString(@"db_fall_diable", nil),NSLocalizedString(@"Low Battery", nil), NSLocalizedString(@"Find  V.ALRT Device", nil),NSLocalizedString(@"V.FALL fall Detect", nil),NSLocalizedString(@"Valrt_off", nil),NSLocalizedString(@"Valrt_on", nil),NSLocalizedString(@"sms_sent_failure", nil),NSLocalizedString(@"sms_sent_success", nil), NSLocalizedString(@"Tracker_connected", nil),NSLocalizedString(@"Tracker_disconnected", nil),    NSLocalizedString(@"Tracker Cancelled", nil),NSLocalizedString(@"devicedashboard_forgetme", nil),NSLocalizedString(@"Application silent mode on", nil),NSLocalizedString(@"Application silent mode off", nil),NSLocalizedString(@"Device silent mode off", nil),NSLocalizedString(@"Device silent mode on", nil),NSLocalizedString(@"Tracker loud tone off", nil),NSLocalizedString(@"Tracker loud tone on", nil),NSLocalizedString(@"Tracker vibrate on", nil),NSLocalizedString(@"Tracker vibrate off", nil)];
        */
        // const char *sqlStatement = [[NSString stringWithFormat:@"select * from history where status in(%@) order by id desc limit 0,100",filterString] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"select * from history order by id desc limit 0,100"] UTF8String];
         sqlite3_stmt *compiledStatement;

         if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
         {
             // Loop through the results and add them to the feeds array
             dataArray = [[NSMutableArray alloc]init];
             while(sqlite3_step(compiledStatement) == SQLITE_ROW)
             {
                 // Read the data from the result row
                 idValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                 date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                 deviceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                 macaddr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                 status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                 
                 NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                 [dic setValue:idValue forKey:@"vid"];
                 [dic setValue:date forKey:@"vdata"];
                 [dic setValue:deviceName forKey:@"vname"];
                 [dic setValue:macaddr forKey:@"vaddress"];
                 [dic setValue:status forKey:@"vstatus"];
                 [dataArray addObject:dic];
             }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return dataArray;
}
///Battery Information
///Add Battery percentage info
-(void)addBatteryStatus:(NSString *)bleaddress batteryPercent:(NSString *)batteryPercent
{
	const char *sql = nil;
    static sqlite3_stmt *compiledStatement;
	[self openDB];
    
    NSString *playlist = @"";
	
	// Open the database from the users filessytem
	if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
		
        sql =[[NSString stringWithFormat:@"select id from batteryStatus where macaddress = '%@'",bleaddress]UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                // Read the data from the result row
                playlist = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSLog(@"addBatteryStatus sql id:%@",playlist);
            }
        }
        else
        {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        if([playlist integerValue]==0)
        {
            sql = [[NSString stringWithFormat:@"insert into batteryStatus(macaddress,battery) values ('%@','%@')",bleaddress,batteryPercent] UTF8String];
            
        }
        else
        {
            sql = [[NSString stringWithFormat:@"update batteryStatus set battery ='%@' where macaddress ='%@'",batteryPercent,bleaddress] UTF8String];
        }
        if (sqlite3_exec(database, sql, NULL,NULL, NULL) != SQLITE_OK)
        {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            NSLog(@"Not Inserted");
        }
	}
    sqlite3_finalize(compiledStatement);
    sqlite3_close(database);
}

///Get Battert percentage
-(int)getBattertyStatus:(NSString *)address
{
    [self openDB];
    int count = 0;
    if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = nil;
        sqlStatement =[[NSString stringWithFormat:@"select battery from batteryStatus where macaddress='%@'",address]UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                count = sqlite3_column_int(compiledStatement, 0);
                //count = 1;
            }
        }
    }
    sqlite3_close(database);
    NSLog(@"dbConnect::getBattertyStatus %@:%d",address,count);
    return count;
    
}

///Get the device infotmation
-(NSMutableDictionary *)getDeviceInfo:(NSString *)deviceId
{
    [self openDB];
    NSString * serial;
    NSString * macIdadd;
    NSMutableDictionary *dic;
    if(sqlite3_open([documentsPath UTF8String], &database) == SQLITE_OK)
    {
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = nil;
        sqlStatement =[[NSString stringWithFormat:@"select serialno,macId from deviceinfo where macaddress='%@'",deviceId]UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            // Loop through the results and add them to the feeds array
            dic = [[NSMutableDictionary alloc] init];
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                
                serial =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                macIdadd =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)];
                [dic setValue:serial forKey:@"serialno"];
                [dic setValue:macIdadd forKey:@"macid"];
                //count = 1;
            }
        }
    }
    sqlite3_close(database);
    return dic;

}

@end
