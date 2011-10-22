//
//  CartItemTableCell.m
//  iPOS
//
//  Created by Steven McCoole on 3/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemTableCell.h"
#import "NSString+StringFormatters.h"
#import "AlertUtils.h"

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f

#define MARGIN_SIDE 10.0f
#define MARGIN_TOP 4.0f

#define STATUS_LABEL_PERCENT_WIDTH 33.0f
#define QUANTITY_LABEL_PERCENT_WIDTH 33.0f
#define LINE_COST_LABEL_PERCENT_WIDTH 34.0f

#pragma mark -
#pragma mark Private Interface
@interface CartItemTableCell ()

- (void) layoutLabelsDefault;
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
		descriptionLabel.textAlignment = UITextAlignmentCenter;
		descriptionLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		descriptionLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:descriptionLabel];

        itemStatusLabel = [[[UILabel alloc] init] autorelease];
		itemStatusLabel.backgroundColor = [UIColor clearColor];
		itemStatusLabel.textColor = [UIColor blackColor];
		itemStatusLabel.textAlignment = UITextAlignmentCenter;
		itemStatusLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		itemStatusLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:itemStatusLabel];
        
		quantityLabel = [[[UILabel alloc] init] autorelease];
		quantityLabel.backgroundColor = [UIColor clearColor];
		quantityLabel.textColor = [UIColor blackColor];
		quantityLabel.textAlignment = UITextAlignmentCenter;
		quantityLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		quantityLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:quantityLabel];
		
		lineCostLabel = [[[UILabel alloc] init] autorelease];
		lineCostLabel.backgroundColor = [UIColor clearColor];
		lineCostLabel.textColor = [UIColor blackColor];
		lineCostLabel.textAlignment = UITextAlignmentRight;
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
	
	orderItem = ordItem;
	
	NSString *descText = [NSString stringWithFormat:@"%@  %@  %@ / %@",
						  orderItem.item.sku,
						  orderItem.item.description,
						  [orderItem getSellingPriceForDisplay],
						  [orderItem getUOMForDisplay]];
	descriptionLabel.text = descText;
	
    itemStatusLabel.text = [orderItem openItemStatus];
    
	NSString *quantityText = [NSString stringWithFormat:@"%@ %@", [orderItem getQuantityForDisplay], [orderItem getUOMForDisplay]];
	quantityLabel.text = quantityText;
	
	lineCostLabel.text = [NSString formatDecimalNumberAsMoney: [orderItem calcLineSubTotal]];
	
	self.deleteChecked = orderItem.shouldDelete;
	self.closeChecked = orderItem.shouldClose || [orderItem isClosed];
	
}

- (BOOL) disabledLook {
    return disabledLook;
}

- (void) setDisabledLook:(BOOL)lookDisabled {
    disabledLook = lookDisabled;
    self.contentView.backgroundColor = (disabledLook) ? [UIColor colorWithWhite:0.90f alpha:1.0f] : [UIColor colorWithWhite:1.0f alpha:1.0f];
}

#pragma mark -
#pragma mark Methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) layoutSubviews {
    [super layoutSubviews];
	
    CGRect frame;
	
	// Set up the hidden buttons, they will overlap initially but the rest of the cell
	// will be re-arranged when we enter edit mode.
	
	UIImage *deleteCheckedImage = [UIImage imageNamed:@"DeleteSelected.png"];
	frame = CGRectMake(MARGIN_SIDE, MARGIN_TOP, deleteCheckedImage.size.width, deleteCheckedImage.size.height);
	deleteCheckButton.frame = frame;
	UIImage *imageForDelete = (self.deleteChecked) ? deleteCheckedImage : [UIImage imageNamed:@"NotSelected.png"];
	[deleteCheckButton setImage:imageForDelete forState:UIControlStateNormal];
	
	UIImage *closeCheckedImage = [UIImage imageNamed:@"CloseSelected.png"];
	frame = CGRectMake((MARGIN_SIDE * 2.0f) + deleteCheckedImage.size.width, MARGIN_TOP, closeCheckedImage.size.width, closeCheckedImage.size.height);
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
												  [self layoutLabelsDefault];
											  }
											  completion:^(BOOL finished) {
												  ;
											  }];
						 }];
	} else {
        [self layoutLabelsDefault];
		[UIView animateWithDuration:0.2 
						 animations:^{
							 CGFloat offsetX = deleteCheckButton.frame.size.width + MARGIN_SIDE + closeCheckButton.frame.size.width + MARGIN_SIDE;
							 
							 CGRect rect;
							 rect = descriptionLabel.frame;
							 descriptionLabel.frame = CGRectMake(rect.origin.x + offsetX, rect.origin.y, rect.size.width - offsetX, rect.size.height);
                             
                             CGFloat labelAdjust = floorf(offsetX / 3.0f);
                             
                             rect = itemStatusLabel.frame;
                             itemStatusLabel.frame = CGRectMake(rect.origin.x + offsetX, rect.origin.y, rect.size.width - labelAdjust, rect.size.height);
                             
							 rect = quantityLabel.frame;
							 quantityLabel.frame = CGRectMake(rect.origin.x + offsetX - labelAdjust, rect.origin.y, rect.size.width - labelAdjust, rect.size.height);
                             
                             rect = lineCostLabel.frame;
							 lineCostLabel.frame = CGRectMake(rect.origin.x + offsetX - (labelAdjust * 2.0f), rect.origin.y, rect.size.width - labelAdjust, rect.size.height);
                             
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

- (void) layoutLabelsDefault {
    CGRect cellRect = self.contentView.bounds;
	CGFloat cellWidth = cellRect.size.width;
	CGFloat cy = MARGIN_TOP;
    
    CGRect rect;
    CGFloat myY = cy;
    // Now set up the normal layout.
    rect = CGRectMake(MARGIN_SIDE, myY, cellWidth - (MARGIN_SIDE * 2.0f), LABEL_HEIGHT);
    descriptionLabel.frame = rect;
    
    myY += LABEL_HEIGHT;
    CGFloat statusLabelWidth = floorf((cellWidth - MARGIN_SIDE * 2.0f) * (STATUS_LABEL_PERCENT_WIDTH / 100.0f));
    rect = rect = CGRectMake(MARGIN_SIDE, myY, statusLabelWidth, LABEL_HEIGHT);
    itemStatusLabel.frame = rect;
    
    CGFloat quantityLabelWidth = floorf((cellWidth - MARGIN_SIDE * 2.0f) * (QUANTITY_LABEL_PERCENT_WIDTH / 100.0f));
    rect = CGRectMake(statusLabelWidth, myY, quantityLabelWidth, LABEL_HEIGHT);
    quantityLabel.frame = rect;
    
    CGFloat lineCostLabelWidth = (cellWidth - MARGIN_SIDE * 2.0f) - quantityLabelWidth - statusLabelWidth;
    rect = CGRectMake(quantityLabelWidth + statusLabelWidth, myY, lineCostLabelWidth, LABEL_HEIGHT);
    lineCostLabel.frame = rect;
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
	UIImage *checkImage = (self.deleteChecked) ? [UIImage imageNamed:@"DeleteSelected.png"] : [UIImage imageNamed:@"NotSelected.png"];
	[deleteCheckButton setImage:checkImage forState:UIControlStateNormal];
	if (self.cellDelegate != nil && [self.cellDelegate respondsToSelector:@selector(cartItemCell:markForDelete:)]) {
		[self.cellDelegate cartItemCell:self markForDelete:self.deleteChecked];
	}
}

- (void)checkCloseAction:(id)sender
{
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	if (self.closeChecked == NO && [self.orderItem allowClose] == NO) {
		[AlertUtils showModalAlertMessage:@"Cannot close line.  Stock not available."];
	} else {
		self.closeChecked = !self.closeChecked;
		[self updateCloseButtonState];
		if (self.closeChecked && self.deleteChecked) {
			self.deleteChecked = !self.deleteChecked;
			[self updateDeleteButtonState];
		}
	}
}

- (void) updateCloseButtonState {
	orderItem.shouldClose = self.closeChecked;
	UIImage *checkImage = (self.closeChecked) ? [UIImage imageNamed:@"CloseSelected.png"] : [UIImage imageNamed:@"NotSelected.png"];
	[closeCheckButton setImage:checkImage forState:UIControlStateNormal];
	if (self.cellDelegate != nil && [self.cellDelegate respondsToSelector:@selector(cartItemCell:markForClose:)]) {
		[self.cellDelegate cartItemCell:self markForClose:self.closeChecked];
	}
}

@end
