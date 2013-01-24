//
//  Refund.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Refund.h"

#import "RefundXmlMarshaller.h"

@implementation Refund

@synthesize orderId;
@synthesize customerId;
@synthesize storeId;
@synthesize salesPersonId;
@synthesize refundDate;
@synthesize refundItems;
@synthesize signature;

- (id)init {
    self = [super init];
    if (self) {
        refundItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc {
    [orderId release];
    orderId = nil;
    [customerId release];
    customerId = nil;
    [storeId release];
    storeId = nil;
    [salesPersonId release];
    salesPersonId = nil;
    [refundDate release];
    refundDate = nil;
    [refundItems release];
    refundItems = nil;
    [signature release];
    signature = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setSignature:
//=========================================================== 
- (void)setSignature:(NSString *)aSignature {
    if (signature != aSignature) {
        [aSignature retain];
        [signature release];
        signature = aSignature;
        
        // set all refund items that require signature to signature captured
        if (aSignature && refundItems && [refundItems count] > 0) {
            for (RefundItem *item in refundItems) {
                if (item.isSignatureRequired) {
                    item.isSignatureCaptured = YES;
                }
            }
        }
    }
}

- (NSDecimalNumber *) getTotalRefundAmount {
    NSDecimalNumber *totalRefund = [NSDecimalNumber zero];
    
    if (refundItems && [refundItems count] > 0) {
        for (RefundItem *item in refundItems) {
            totalRefund = [totalRefund decimalNumberByAdding:item.amount];
        }
    }
    
    return totalRefund;
}

- (void) addRefundItem:(RefundItem *)item {
    
    [refundItems addObject:item];
}

- (NSArray *) getRefundItems{
    return refundItems;
}

- (BOOL) isSignatureRequired {
    if (refundItems && [refundItems count] > 0) {
        for (RefundItem *item in refundItems) {
            if (item.isSignatureRequired && !item.isSignatureCaptured) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL) isCardSwipeRequired {
    if (refundItems && [refundItems count] > 0) {
        for (RefundItem *item in refundItems) {
            if (item.isSwipeRequired && !item.isSwipeCaptured) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (RefundItem *) getCurrentRefundItemForSwipe {
    if (refundItems && [refundItems count] > 0) {
        for (RefundItem *item in refundItems) {
            if (item.isSwipeRequired && !item.isSwipeCaptured) {
                return item;
            }
        }
    }
    
    return nil;
}

- (void) setCardData:(NSDictionary *)cardData {
    if ([cardData valueForKey:@"accountNumber"]) {
        // Find the card with the matching last 4 numbers (would the same customer have 2 cards with the same 4 numbers used as payment??)
        NSString *swipedNumber = (NSString *)[cardData valueForKey:@"accountNumber"];
        NSString *paymentCardNumber;
        
        if (swipedNumber.length > 4) {
            swipedNumber = [swipedNumber substringFromIndex:swipedNumber.length-4];
        }
        
        if (refundItems && [refundItems count] > 0) {
            for (RefundItem *item in refundItems) {
                if (item.isSwipeRequired && !item.isSwipeCaptured && item.creditCard) {
                    paymentCardNumber = item.creditCard.cardNumber;
                    if (paymentCardNumber.length > 4) {
                        paymentCardNumber = [paymentCardNumber substringFromIndex:paymentCardNumber.length-4];
                    }

                    // Assumed to be the match
                    if ([paymentCardNumber isEqualToString:swipedNumber]) {
                        item.creditCard.cardNumber = [[(NSString *)[cardData valueForKey:@"accountNumber"] copy] autorelease];
                        item.creditCard.nameOnCard = [[(NSString *)[cardData valueForKey:@"cardholderName"] copy] autorelease];
                        [item.creditCard setExpireDateMonthYear:[[(NSString *)[cardData valueForKey:@"expirationMonth"] copy] autorelease]
                                                           year:[[(NSString *)[cardData valueForKey:@"expirationYear"] copy] autorelease]];
                        item.isSwipeCaptured = YES;
                    }
                    
                }
            }
        }
    }
}

#pragma mark -
#pragma mark OXM Marshalling
- (NSString *) toXml {
    RefundXmlMarshaller *xmlMarshaller = [[[RefundXmlMarshaller alloc] init ] autorelease];
    
    return [xmlMarshaller toXml:self];
}

@end
