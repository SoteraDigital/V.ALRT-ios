#import <Foundation/Foundation.h>

@interface EncodeData : NSObject <NSCoding>



@property (retain,nonatomic) NSDictionary *dictAdvertismentData;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;



@end
