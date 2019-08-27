#import "Customcell.h"
#import <QuartzCore/QuartzCore.h>


@implementation Customcell
@synthesize primaryLabel,secondaryLabel,thirdLabel,devicetxtLabel,serialtxtLabel,sofverLabel;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        // Initialization code
        
        
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.textAlignment = NSTextAlignmentLeft;
		primaryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
		primaryLabel.backgroundColor = [UIColor clearColor];
		primaryLabel.textColor = [UIColor blackColor];
		primaryLabel.numberOfLines = 2;
		
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.textAlignment = NSTextAlignmentLeft;
		secondaryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
		secondaryLabel.textColor = [UIColor blackColor];
		secondaryLabel.highlightedTextColor = [UIColor blackColor];
		secondaryLabel.backgroundColor = [UIColor clearColor];
		
		thirdLabel = [[UILabel alloc]init];
        thirdLabel.numberOfLines  =2;
		thirdLabel.textAlignment = NSTextAlignmentLeft;
		thirdLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
		thirdLabel.textColor = [UIColor blackColor];
		thirdLabel.highlightedTextColor = [UIColor blackColor];
		thirdLabel.backgroundColor = [UIColor clearColor];
        
        devicetxtLabel = [[UILabel alloc]init];
        devicetxtLabel.numberOfLines  =2;
		devicetxtLabel.textAlignment = NSTextAlignmentLeft;
		devicetxtLabel.font = [UIFont fontWithName:@"NotoSans" size:12];
		devicetxtLabel.textColor = [UIColor blackColor];
		devicetxtLabel.highlightedTextColor = [UIColor blackColor];
		devicetxtLabel.backgroundColor = [UIColor clearColor];
        
        serialtxtLabel = [[UILabel alloc]init];
        serialtxtLabel.numberOfLines  =2;
		serialtxtLabel.textAlignment = NSTextAlignmentLeft;
		serialtxtLabel.font = [UIFont fontWithName:@"NotoSans" size:12];
		serialtxtLabel.textColor = [UIColor blackColor];
		serialtxtLabel.highlightedTextColor = [UIColor blackColor];
		serialtxtLabel.backgroundColor = [UIColor clearColor];
        
        sofverLabel = [[UILabel alloc]init];
        sofverLabel.numberOfLines  =2;
		sofverLabel.textAlignment = NSTextAlignmentLeft;
		sofverLabel.font = [UIFont fontWithName:@"NotoSans" size:12];
		sofverLabel.textColor = [UIColor blackColor];
		sofverLabel.highlightedTextColor = [UIColor blackColor];
		sofverLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        self.contentView.layer.cornerRadius=10;
        
        
        [self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:thirdLabel];
        [self.contentView addSubview:devicetxtLabel];
		[self.contentView addSubview:serialtxtLabel];
		[self.contentView addSubview:sofverLabel];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
    NSLog(@"contentrect:%f %f",contentRect.origin.x,contentRect.origin.y);
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
    
	frame= CGRectMake(boundsX+10 ,7, 158, 15);
	primaryLabel.frame = frame;
	
	frame= CGRectMake(boundsX+10 ,30, 158, 15);
	secondaryLabel.frame = frame;
	
	frame= CGRectMake(boundsX+10 ,55, 200, 15);
	thirdLabel.frame = frame;
    
    frame= CGRectMake(boundsX+150 ,7, 200, 15);
	devicetxtLabel.frame = frame;
    
    frame= CGRectMake(boundsX+150 ,30, 200, 15);
	serialtxtLabel.frame = frame;
    
    frame= CGRectMake(boundsX+150 ,55, 200, 15);
	sofverLabel.frame = frame;
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
