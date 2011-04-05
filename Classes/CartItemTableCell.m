//
//  CartItemTableCell.m
//  iPOS
//
//  Created by Steven McCoole on 3/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemTableCell.h"
#import "NSString+StringFormatters.h"

#pragma mark -
#pragma mark Private Interface
@interface CartItemTableCell ()
@end

#pragma mark -
@implementation CartItemTableCell

@synthesize orderItem;

#pragma mark Constructors
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		descriptionLabel = [[[UILabel alloc] init] autorelease];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor blackColor];
		descriptionLabel.textAlignment = UITextAlignmentLeft;
		descriptionLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		descriptionLabel.adjustsFontSizeToFitWidth = YES;
		
		quantityLabel = [[[UILabel alloc] init] autorelease];
		quantityLabel = [[[UILabel alloc] init] autorelease];
		quantityLabel.backgroundColor = [UIColor clearColor];
		quantityLabel.textColor = [UIColor blackColor];
		quantityLabel.textAlignment = UITextAlignmentCenter;
		quantityLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		
		lineCostLabel = [[[UILabel alloc] init] autorelease];
		lineCostLabel = [[[UILabel alloc] init] autorelease];
		lineCostLabel.backgroundColor = [UIColor clearColor];
		lineCostLabel.textColor = [UIColor blackColor];
		lineCostLabel.textAlignment = UITextAlignmentCenter;
		lineCostLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];

		[self.contentView addSubview:descriptionLabel];
		[self.contentView addSubview:quantityLabel];
		[self.contentView addSubview:lineCostLabel];
	}
	return self;
}

- (void) dealloc
{
	[self setOrderItem:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (OrderItem *) orderItem {
	return orderItem;
}

- (void) setOrderItem:(OrderItem *)ordItem {
	if (orderItem != ordItem) {
		[orderItem release];
		orderItem = [ordItem retain];
	}
	
	NSString *descText = [NSString stringWithFormat:@"%@  %@  %@ / %@",
						  [orderItem.item.sku stringValue],
						  orderItem.item.description,
						  [NSString formatDecimalNumberAsMoney: orderItem.sellingPrice],
						  orderItem.item.primaryUnitOfMeasure];
	descriptionLabel.text = descText;
	
	NSString *quantityText = [NSString stringWithFormat:@"%@ %@", orderItem.quantity, orderItem.item.primaryUnitOfMeasure];
	quantityLabel.text = quantityText;
	
	lineCostLabel.text = [NSString formatDecimalNumberAsMoney: [orderItem.sellingPrice decimalNumberByMultiplyingBy:orderItem.quantity]];
}

#pragma mark -
#pragma mark Methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) layoutSubviews {
    [super layoutSubviews];
	CGRect cellRect = self.contentView.bounds;
	CGFloat cellWidth = cellRect.size.width;
	
	CGRect frame;
	
	CGFloat cy = START_Y;
	frame = CGRectMake(START_X, cy, cellWidth - (START_X * 2.0f), LABEL_HEIGHT);
	descriptionLabel.frame = frame;
	
	cy += LABEL_HEIGHT;
	CGFloat quantityLabelWidth = floorf((cellWidth - START_X * 2.0f) * (QUANTITY_LABEL_PERCENT_WIDTH / 100.0f));
	frame = CGRectMake(START_X, cy, quantityLabelWidth, LABEL_HEIGHT);
	quantityLabel.frame = frame;
	
	CGFloat lineCostLabelWidth = (cellWidth - START_X * 2.0f) - quantityLabelWidth;
	frame = CGRectMake(quantityLabelWidth, cy, lineCostLabelWidth, LABEL_HEIGHT);
	lineCostLabel.frame = frame;
	
}

@end
