//
//  ItemTableCell.m
//  iPOS
//
//  Created by Torey Lomenda on 5/9/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemTableCell.h"

#define MARGIN_TOP 14.0f
#define MARGIN_SIDE 10.0f

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f

@implementation ItemTableCell

@synthesize item;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        itemDescriptionLabel = [[[UILabel alloc] init] autorelease];
		itemDescriptionLabel.backgroundColor = [UIColor clearColor];
		itemDescriptionLabel.textColor = [UIColor blackColor];
		itemDescriptionLabel.textAlignment = UITextAlignmentLeft;
		itemDescriptionLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		itemDescriptionLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:itemDescriptionLabel];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void) setItem:(ProductItem *) anItem {
	item = anItem;
	
	NSString *descText = [NSString stringWithFormat:@"%@  %@",
						  [item.sku stringValue],
						  item.description];
	itemDescriptionLabel.text = descText;
}

#pragma mark -
#pragma mark Layout Subviews
- (void) layoutSubviews {
    [super layoutSubviews];

    // Layout the content
    CGRect contentRect = self.contentView.bounds;
            
    itemDescriptionLabel.frame = CGRectMake(MARGIN_SIDE, MARGIN_TOP, contentRect.size.width-MARGIN_SIDE, LABEL_HEIGHT);
}

@end
