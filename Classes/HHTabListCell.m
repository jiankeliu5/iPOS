//
//  HHTabListCell.m
//  iPOS
//
//  Created by Enning Tang on 2/8/13.
//
//

#import "HHTabListCell.h"


@implementation HHTabListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) {
		CGRect frame = self.bounds;
		UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
		
		backgroundView.opaque = YES;
		backgroundView.backgroundColor = [UIColor orangeColor];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
        //		self.backgroundView = backgroundView;
		self.selectedBackgroundView = backgroundView;
		
		CGRect lineFrame = self.bounds;
		
		lineFrame.origin.y += lineFrame.size.height;
		lineFrame.size.height = 1.0;
		
		UIView *lineView = [[UIView alloc] initWithFrame:lineFrame];
		
		lineView.opaque = YES;
		lineView.backgroundColor = [UIColor orangeColor];
		lineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
		[self addSubview:lineView];
    }
	
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
