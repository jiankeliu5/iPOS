//
//  CustomerListTableCell.m
//  iPOS
//
//  Created by Torey Lomenda on 10/31/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "CustomerListTableCell.h"

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f

@interface CustomerListTableCell()

- (void) updateDisplayValues;

@end

@implementation CustomerListTableCell
@synthesize customer;
@synthesize customerNameLabel;
@synthesize customerPhoneLabel;
@synthesize customerTypeLabel;
@synthesize customerEmailLabel;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        customerNameLabel = [[UILabel alloc] init];
		customerNameLabel.backgroundColor = [UIColor clearColor];
		customerNameLabel.textColor = [UIColor blackColor];
		customerNameLabel.textAlignment = NSTextAlignmentLeft;
		customerNameLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		customerNameLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:customerNameLabel];
        
        customerPhoneLabel = [[UILabel alloc] init];
		customerPhoneLabel.backgroundColor = [UIColor clearColor];
		customerPhoneLabel.textColor = [UIColor blackColor];
		customerPhoneLabel.textAlignment = NSTextAlignmentRight;
		customerPhoneLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		customerPhoneLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:customerPhoneLabel];
        
        customerTypeLabel = [[UILabel alloc] init];
		customerTypeLabel.backgroundColor = [UIColor clearColor];
        customerTypeLabel.text = @"Signature Required";
		customerTypeLabel.textAlignment = NSTextAlignmentLeft;
		customerTypeLabel.font = [UIFont systemFontOfSize:12];
		customerTypeLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:customerTypeLabel];
        
        customerEmailLabel = [[UILabel alloc] init];
		customerEmailLabel.backgroundColor = [UIColor clearColor];
		customerEmailLabel.textColor = [UIColor blackColor];
		customerEmailLabel.textAlignment = NSTextAlignmentRight;
		customerEmailLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
		customerEmailLabel.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:customerEmailLabel];
        
    }
    return self;
}

- (void) dealloc {
    [customerNameLabel release];
    customerNameLabel = nil;
    [customerPhoneLabel release];
    customerPhoneLabel = nil;
    [customerTypeLabel release];
    customerTypeLabel = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setCustomer:
//=========================================================== 
- (void)setCustomer:(Customer *)aCustomer {
    if (customer != aCustomer) {
        customer = aCustomer;
        
        [self updateDisplayValues];
    }
}

#pragma mark -
#pragma mark Layout Subviews
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    // 2 rows
    CGRect row1 = CGRectZero;
    CGRect customerNameRect = CGRectZero;
    CGRect phoneNumRect = CGRectZero;
    
    CGRect row2 = CGRectZero;
    CGRect customerTypeRect = CGRectZero;
    CGRect customerEmailRect = CGRectZero;
    
    CGRectDivide(bounds, &row1, &row2, bounds.size.height * 0.50f, CGRectMinYEdge);
    row1 = CGRectInset(row1, 10.0f, 0.0f);
    row2 = CGRectInset(row2, 10.0f, 0.0f);
    
    CGRectDivide(row1, &customerNameRect, &phoneNumRect, row1.size.width * 0.50f, CGRectMinXEdge);
    
    customerNameLabel.frame = customerNameRect;
    customerPhoneLabel.frame = phoneNumRect;
    
    CGRectDivide(row2, &customerTypeRect, &customerEmailRect, row2.size.width * 0.30f, CGRectMinXEdge);
    
    customerTypeLabel.frame = customerTypeRect;
    customerEmailLabel.frame = customerEmailRect;
    
}

#pragma mark -
#pragma mark Private Methods
- (void) updateDisplayValues {
    if (customer) {
        if (customer.lastName && customer.firstName) {
            customerNameLabel.text = [NSString stringWithFormat:@"%@ %@", customer.lastName, customer.firstName];
        } else if (customer.lastName) {
            customerNameLabel.text = customer.lastName;
        } else {
            customerNameLabel.text = customer.firstName;
        }
        
        customerPhoneLabel.text = customer.phoneNumber;
        customerTypeLabel.text = customer.customerType;
        customerEmailLabel.text = customer.emailAddress;
    } else {
        customerNameLabel.text = @"";
        customerPhoneLabel.text = @"";
        customerTypeLabel.text = @"";
        customerEmailLabel.text = @"";
    }
}

@end
