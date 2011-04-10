//
//  CartItemTableCell.m
//  iPOS
//
//  Created by Steven McCoole on 3/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemTableCell.h"
#import "NSString+StringFormatters.h"

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f
#define START_X 10.0f
#define START_Y 4.0f
#define QUANTITY_LABEL_PERCENT_WIDTH 66.0f
#define LINE_COST_LABEL_PERCENT_WIDTH 34.0f

#pragma mark -
#pragma mark Private Interface
@interface CartItemTableCell ()
- (void) updateDeleteButtonState;
- (void) updateCloseButtonState;
@end

#pragma mark -
@implementation CartItemTableCell

@synthesize orderItem, deleteChecked, closeChecked, multiEditing, cellDelegate;

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
		[self.contentView addSubview:descriptionLabel];
		
		quantityLabel = [[[UILabel alloc] init] autorelease];
		quantityLabel = [[[UILabel alloc] init] autorelease];
		quantityLabel.backgroundColor = [UIColor clearColor];
		quantityLabel.textColor = [UIColor blackColor];
		quantityLabel.textAlignment = UITextAlignmentCenter;
		quantityLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		quantityLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:quantityLabel];
		
		lineCostLabel = [[[UILabel alloc] init] autorelease];
		lineCostLabel = [[[UILabel alloc] init] autorelease];
		lineCostLabel.backgroundColor = [UIColor clearColor];
		lineCostLabel.textColor = [UIColor blackColor];
		lineCostLabel.textAlignment = UITextAlignmentCenter;
		lineCostLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		lineCostLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:lineCostLabel];
		
		deleteCheckButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		deleteCheckButton.frame = CGRectZero;
		deleteCheckButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		deleteCheckButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[deleteCheckButton addTarget:self action:@selector(checkDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
		deleteCheckButton.backgroundColor = self.backgroundColor;
		// Hide until we are in edit mode.
		deleteCheckButton.hidden = YES;
		[self.contentView addSubview:deleteCheckButton];
		
		closeCheckButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		closeCheckButton.frame = CGRectZero;
		closeCheckButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		closeCheckButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[closeCheckButton addTarget:self action:@selector(checkCloseAction:) forControlEvents:UIControlEventTouchUpInside];
		closeCheckButton.backgroundColor = self.backgroundColor;
		closeCheckButton.hidden = YES;
		[self.contentView addSubview:closeCheckButton];

	}
	return self;
}

- (void) dealloc
{
	//[self setOrderItem:nil];
	[deleteCheckButton release];
	[closeCheckButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (OrderItem *) orderItem {
	return orderItem;
}

- (void) setOrderItem:(OrderItem *)ordItem {
	/*
	if (orderItem != ordItem) {
		[orderItem release];
		orderItem = [ordItem retain];
	}
	*/
	
	orderItem = ordItem;
	
	NSString *descText = [NSString stringWithFormat:@"%@  %@  %@ / %@",
						  [orderItem.item.sku stringValue],
						  orderItem.item.description,
						  [NSString formatDecimalNumberAsMoney: orderItem.sellingPrice],
						  orderItem.item.primaryUnitOfMeasure];
	descriptionLabel.text = descText;
	
	NSString *quantityText = [NSString stringWithFormat:@"%@ %@", orderItem.quantity, orderItem.item.primaryUnitOfMeasure];
	quantityLabel.text = quantityText;
	
	lineCostLabel.text = [NSString formatDecimalNumberAsMoney: [orderItem.sellingPrice decimalNumberByMultiplyingBy:orderItem.quantity]];
	
	self.deleteChecked = orderItem.shouldDelete;
	self.closeChecked = orderItem.shouldClose;
	
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
	
	// Set up the hidden buttons, they will overlap initially but the rest of the cell
	// will be re-arranged when we enter edit mode.
	
	UIImage *deleteCheckedImage = [UIImage imageNamed:@"IsSelectedRed.png"];
	frame = CGRectMake(START_X, cy, deleteCheckedImage.size.width, deleteCheckedImage.size.height);
	deleteCheckButton.frame = frame;
	UIImage *imageForDelete = (self.deleteChecked) ? deleteCheckedImage : [UIImage imageNamed:@"NotSelected.png"];
	[deleteCheckButton setImage:imageForDelete forState:UIControlStateNormal];
	
	UIImage *closeCheckedImage = [UIImage imageNamed:@"IsSelectedRed.png"];
	frame = CGRectMake((START_X * 2.0f) + deleteCheckedImage.size.width, cy, closeCheckedImage.size.width, closeCheckedImage.size.height);
	closeCheckButton.frame = frame;
	UIImage *imageForClose = (self.closeChecked) ? closeCheckedImage : [UIImage imageNamed:@"NotSelected.png"];
	[closeCheckButton setImage:imageForClose forState:UIControlStateNormal];
	
	if (self.multiEditing == NO) {
		[UIView animateWithDuration:0.1 
						 animations:^{
							 closeCheckButton.hidden = YES;
							 deleteCheckButton.hidden = YES;
						 }
						 completion:^(BOOL finished) {
							 [UIView animateWithDuration:0.2
											  animations:^{
												  CGRect rect;
												  CGFloat myY = cy;
												  // Now set up the normal layout.
												  rect = CGRectMake(START_X, myY, cellWidth - (START_X * 2.0f), LABEL_HEIGHT);
												  descriptionLabel.frame = rect;
												  
												  myY += LABEL_HEIGHT;
												  CGFloat quantityLabelWidth = floorf((cellWidth - START_X * 2.0f) * (QUANTITY_LABEL_PERCENT_WIDTH / 100.0f));
												  rect = CGRectMake(START_X, myY, quantityLabelWidth, LABEL_HEIGHT);
												  quantityLabel.frame = rect;
												  
												  CGFloat lineCostLabelWidth = (cellWidth - START_X * 2.0f) - quantityLabelWidth;
												  rect = CGRectMake(quantityLabelWidth, myY, lineCostLabelWidth, LABEL_HEIGHT);
												  lineCostLabel.frame = rect;
											  }
											  completion:^(BOOL finished) {
												  ;
											  }];
						 }];
	} else {
		[UIView animateWithDuration:0.2 
						 animations:^{
							 CGFloat offsetX = deleteCheckButton.frame.size.width + START_X + closeCheckButton.frame.size.width + START_X;
							 
							 CGRect rect;
							 rect = descriptionLabel.frame;
							 descriptionLabel.frame = CGRectMake(rect.origin.x + offsetX, rect.origin.y, rect.size.width - offsetX, rect.size.height);
							 
							 rect = quantityLabel.frame;
							 quantityLabel.frame = CGRectMake(rect.origin.x + offsetX, rect.origin.y, rect.size.width - offsetX, rect.size.height);
						 }
						 completion:^(BOOL finished) {
							 [UIView animateWithDuration:0.1 
											  animations:^{
												  deleteCheckButton.hidden = NO;
												  closeCheckButton.hidden = NO;
											  }
											  completion:^(BOOL finished) {
											  }];
						 }];
	}
	
	
}

- (void)checkDeleteAction:(id)sender
{
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	self.deleteChecked = !self.deleteChecked;
    [self updateDeleteButtonState];
	if (self.deleteChecked && self.closeChecked) {
		self.closeChecked = !self.closeChecked;
		[self updateCloseButtonState];
	}
}

- (void) updateDeleteButtonState {
	orderItem.shouldDelete = self.deleteChecked;
	UIImage *checkImage = (self.deleteChecked) ? [UIImage imageNamed:@"IsSelectedRed.png"] : [UIImage imageNamed:@"NotSelected.png"];
	[deleteCheckButton setImage:checkImage forState:UIControlStateNormal];
	if (self.cellDelegate != nil && [self.cellDelegate respondsToSelector:@selector(cartItemCell:markForDelete:)]) {
		[self.cellDelegate cartItemCell:self markForDelete:self.deleteChecked];
	}
}

- (void)checkCloseAction:(id)sender
{
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	self.closeChecked = !self.closeChecked;
	[self updateCloseButtonState];
	if (self.closeChecked && self.deleteChecked) {
		self.deleteChecked = !self.deleteChecked;
		[self updateDeleteButtonState];
	}
}

- (void) updateCloseButtonState {
	orderItem.shouldClose = self.closeChecked;
	UIImage *checkImage = (self.closeChecked) ? [UIImage imageNamed:@"IsSelectedRed.png"] : [UIImage imageNamed:@"NotSelected.png"];
	[closeCheckButton setImage:checkImage forState:UIControlStateNormal];
	if (self.cellDelegate != nil && [self.cellDelegate respondsToSelector:@selector(cartItemCell:markForClose:)]) {
		[self.cellDelegate cartItemCell:self markForClose:self.closeChecked];
	}
}

@end
