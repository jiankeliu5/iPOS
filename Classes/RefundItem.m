//
//  RefundItem.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RefundItem.h"

@implementation RefundItem

@synthesize amount;
@synthesize orderPaymentTypeID;
@synthesize creditCard;
@synthesize isSignatureRequired;
@synthesize isSignatureCaptured;
@synthesize isSwipeRequired;
@synthesize isSwipeCaptured;
@synthesize toCCT;
@synthesize toPOS;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        isSwipeRequired = NO;
        isSwipeCaptured = NO;
        isSignatureRequired = NO;
        isSignatureCaptured = NO;
        toCCT = NO;
        toPOS = NO;
    }
    
    return self;
}

- (void) dealloc {
    [amount release];
    amount = nil;
    [orderPaymentTypeID release];
    orderPaymentTypeID = nil;
    [creditCard release];
    creditCard = nil;
    
    [super dealloc];
}


-(BOOL) isCreditCard{
    
    int id = [self.orderPaymentTypeID intValue];
    
    return (id == CREDITCARD_VISA || id == CREDITCARD_MC | id == CREDITCARD_DISCOVER || id == CREDITCARD_AX);
}

- (PaymentType) getPaymentType {
    return [orderPaymentTypeID intValue];
}

- (NSString *) getRefundDescription {
    NSString *description = @"Unknown";
    
    switch ([orderPaymentTypeID intValue]) {
        case ONACCT: {
            description = @"On Account";
            break;
        }
        case CREDITCARD_VISA: {
            description = @"Visa";
            break;
        }
        case CREDITCARD_MC: {
            description = @"Master Card";
            break;
        }
        case CREDITCARD_AX: {
            description = @"AMEX";
            break;
        }
        case CREDITCARD_DISCOVER: {
            description = @"Discover";
            break;
        }
        case CASH: {
            description = @"Cash";
            break;
        }
        case CHECK: {
            description = @"Check";
            break;
        }
        case INSTORE_CREDIT: {
            description = @"In Store Credit";
            break;
        }
        case GIFT_CARD: {
            description = @"Gift Card";
            break;
        }
        case GOOGLE: {
            description = @"Google";
            break;
        }
        case HOMEDESIGN: {
            description = @"Home Design";
            break;
        }
        case PAYPAL: {
            description = @"Pay Pal";
            break;
        }
        default: {
            break;
        }
    }
    
    if ([self isCreditCard] && creditCard) {
        if (creditCard.cardNumber && creditCard.paymentRefId) {
            NSString *cardNumber = creditCard.cardNumber;
            
            if ([cardNumber length] > 4) {
                cardNumber = [cardNumber substringFromIndex:cardNumber.length - 4];
            }
            description = [description stringByAppendingFormat:@" xxxxxxxx%@", cardNumber];
        } else if (creditCard.paymentRefId) {
            description = [description stringByAppendingFormat:@" xxxxxxxxxxxx"];
        }
    }
    
    return description;
}

@end
