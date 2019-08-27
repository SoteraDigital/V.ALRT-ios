#import "EncodeData.h"

@implementation EncodeData

@synthesize dictAdvertismentData;


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.dictAdvertismentData = [decoder decodeObjectForKey:@"data"];
    
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.dictAdvertismentData forKey:@"data"];
    
}

@end
