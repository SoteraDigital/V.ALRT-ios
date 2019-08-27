#import "logfile.h"

@implementation logfile
+ (logfile *) logfileObj{
    // the instance of this class is stored here
    static logfile *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance)
    {
        myInstance  = [[[self class] alloc] init];
        
    }
    return myInstance;
}
-(void)writeLog:(NSString *)cnt1
{
    NSString *content = [NSString stringWithFormat:@"%@\r\n", cnt1];
    
    //Get the file path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"valrt_logfile.txt"];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}
-(NSString *)openLog
{
    //get file path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"valrt_logfile.txt"];
    
    return fileName;
}
@end
