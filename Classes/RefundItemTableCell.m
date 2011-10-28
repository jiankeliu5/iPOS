//
//  RefundItemTableCell.m
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "RefundItemTableCell.h"

#import "NSString+StringFormatters.h"

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f

@implementation RefundItemTableCell
@synthesize refundItem;
@synthesize refundInfoLabel;
@synthesize refundAmountLabel;
@synthesize signatureRequiredLabel;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        refundInfoLabel = [[UILabel alloc] init];
		refundInfoLabel.backgroundColor = [UIColor clearColor];
		refundInfoLabel.textColor = [UIColor blackColor];
		refundInfoLabel.textAlignment = UITextAlignmentLeft;
		refundInfoLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		refundInfoLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:refundInfoLabel];
        
        refundAmountLabel = [[UILabel alloc] init];
		refundAmountLabel.backgroundColor = [UIColor clearColor];
		refundAmountLabel.textColor = [UIColor blackColor];
		refundAmountLabel.textAlignment = UITextAlignmentRight;
		refundAmountLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		refundAmountLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:refundAmountLabel];
        
        signatureRequiredLabel = [[UILabel alloc] init];
		signatureRequiredLabel.backgroundColor = [UIColor clearColor];
        signatureRequiredLabel.text = @"Signature Required";
		signatureRequiredLabel.textColor = [UIColor redColor];
		signatureRequiredLabel.textAlignment = UITextAlignmentLeft;
		signatureRequiredLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
		signatureRequiredLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:signatureRequiredLabel];

        
    }
    return self;
}

- (void) dealloc {
    [refundInfoLabel release];
    refundInfoLabel = nil;
    [refundAmountLabel release];
    refundAmountLabel = nil;
    [signatureRequiredLabel release];
    signatureRequiredLabel = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setRefundItem:
//=========================================================== 
- (void)setRefundItem:(RefundItem *)aRefundItem {
    if (refundItem != aRefundItem) {
        refundItem = aRefundItem;
        
        // update the labels
        if (refundItem) {
            if (refundItem.creditCard) {
                if (refundItem.creditCard.paymentRefId) {
                    refundInfoLabel.text = [NSString stringWithFormat:@"xxxxxxxx%@", refundItem.creditCard.cardNumber];
                    refundAmountLabel.text = [NSString formatDecimalNumberAsMoney:refundItem.amount];
                } else {
                    refundInfoLabel.text = @"Credit Card";
                    refundAmountLabel.text = @"To CCT";
                }
                
            } else if ([refundItem getPaymentType] == CASH) {
                refundInfoLabel.text = @"Cash";
                refundAmountLabel.text = @"To POS";
            } else if ([refundItem getPaymentType] == CHECK) {
                refundInfoLabel.text = @"Check";
                refundAmountLabel.text = @"To POS";
            } else if ([refundItem getPaymentType] == ONACCT) {
                refundInfoLabel.text = @"On Account";
                refundAmountLabel.text = [NSString formatDecimalNumberAsMoney:refundItem.amount];
            }
            
            if (refundItem.isSignatureRequired) {
                signatureRequiredLabel.hidden = NO;
            } else {
                signatureRequiredLabel.hidden = YES;
            }
        } else {
            refundInfoLabel.text = @"";
            refundAmountLabel.text = @"";
            signatureRequiredLabel.hidden = YES;
        }
    }
}

#pragma mark -
#pragma mark Layout Subviews
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    // 2 rows
    CGRect row1 = CGRectZero;
    CGRect refundInfoRect = CGRectZero;
    CGRect refundAmtRect = CGRectZero;
    
    CGRect row2 = CGRectZero;
    
    CGRectDivide(bounds, &row1, &row2, bounds.size.height * 0.50f, CGRectMinYEdge);
    row1 = CGRectInset(row1, 10.0f, 0.0f);
    row2 = CGRectInset(row2, 10.0f, 0.0f);
    
    CGRectDivide(row1, &refundInfoRect, &refundAmtRect, row1.size.width * 0.50f, CGRectMinXEdge);
    
    refundInfoLabel.frame = refundInfoRect;
    refundAmountLabel.frame = refundAmtRect;
    
    signatureRequiredLabel.frame = row2;
}



@end
