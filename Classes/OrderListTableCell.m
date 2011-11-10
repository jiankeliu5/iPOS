//
//  OrderListTableCell.m
//  iPOS
//
//  Created by Steven McCoole on 10/8/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "OrderListTableCell.h"
#import "NSString+StringFormatters.h"

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f

@implementation OrderListTableCell

@synthesize previousOrder, disabledLook;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        dateLabel = [[[UILabel alloc] init] autorelease];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textColor = [UIColor blackColor];
		dateLabel.textAlignment = UITextAlignmentLeft;
		dateLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		dateLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:dateLabel];
        
        totalLabel = [[[UILabel alloc] init] autorelease];
		totalLabel.backgroundColor = [UIColor clearColor];
		totalLabel.textColor = [UIColor blackColor];
		totalLabel.textAlignment = UITextAlignmentRight;
		totalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		totalLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:totalLabel];
        
        orderIdLabel = [[[UILabel alloc] init] autorelease];
		orderIdLabel.backgroundColor = [UIColor clearColor];
		orderIdLabel.textColor = [UIColor blackColor];
		orderIdLabel.textAlignment = UITextAlignmentLeft;
		orderIdLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		orderIdLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:orderIdLabel];
        
        statusLabel = [[[UILabel alloc] init] autorelease];
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textColor = [UIColor blackColor];
		statusLabel.textAlignment = UITextAlignmentRight;
		statusLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		statusLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:statusLabel];
        
        disabledLook = false;
    }
    return self;
}

#pragma mark -
#pragma mark Accessors
- (BOOL) disabledLook {
    return disabledLook;
}

- (void) setDisabledLook:(BOOL)lookDisabled {
    disabledLook = lookDisabled;
    self.contentView.backgroundColor = (disabledLook) ? [UIColor colorWithWhite:0.90f alpha:1.0f] : [UIColor colorWithWhite:1.0f alpha:1.0f];
}

- (void) setPreviousOrder:(PreviousOrder *)pOrder {
    previousOrder = pOrder;
    
    dateLabel.text = [previousOrder.orderDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    totalLabel.text = [NSString formatDecimalNumberAsMoney:previousOrder.orderTotal];
    orderIdLabel.text = [NSString formatNumber:previousOrder.orderId toScale:0];
    statusLabel.text = previousOrder.orderType;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.contentView.bounds;
    CGFloat h = r.size.height;
    CGFloat w = r.size.width;
    
    CGRect rowOneRect = CGRectZero;
    CGRect dateFrame = CGRectZero;
    CGRect totalFrame = CGRectZero;
    
    CGRect rowTwoRect = CGRectZero;
    CGRect orderIdFrame = CGRectZero;
    CGRect statusFrame = CGRectZero;
    
    // Row one in the cell region
    CGRectDivide(r, &rowOneRect, &r, h * 0.50f, CGRectMinYEdge);
    // Don't want the row frames going to the edge of the cell.
    rowOneRect = CGRectInset(rowOneRect, 10.0f, 0.0f);
    CGRectDivide(rowOneRect, &dateFrame, &rowOneRect, w * 0.50f, CGRectMinXEdge);
    CGRectDivide(rowOneRect, &totalFrame, &rowOneRect, w * 0.50f, CGRectMinXEdge);
    
    // Row two in the cell region
    CGRectDivide(r, &rowTwoRect, &r, h * 0.50f, CGRectMinYEdge);
    // Don't want the row frames going to the edge of the cell;
    rowTwoRect = CGRectInset(rowTwoRect, 10.0f, 0.0f);
    CGRectDivide(rowTwoRect, &orderIdFrame, &rowTwoRect, w * 0.50f, CGRectMinXEdge);
    CGRectDivide(rowTwoRect, &statusFrame, &rowTwoRect, w * 0.50f, CGRectMinXEdge);
    
    // Use CGRectInset(rect, width, height) if you want to shrink any of the component sizes in the frames.
    
    // When setting the frames use CGRectIntegral(rect) to make sure they are on pixel boundaries
    [dateLabel setFrame:dateFrame];
    [totalLabel setFrame:totalFrame];
    [orderIdLabel setFrame:orderIdFrame];
    [statusLabel setFrame:statusFrame];
    
}

@end
