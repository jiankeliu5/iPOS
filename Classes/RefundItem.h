//
//  RefundItem.h
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreditCardPayment.h"

@interface RefundItem : NSObject{
    NSDecimalNumber *amount;
    NSNumber *orderPaymentTypeID;
    CreditCardPayment *creditCard;
    
    BOOL isSignatureRequired;
    BOOL isSignatureCaptured;
    BOOL isSwipeRequired;
    BOOL isSwipeCaptured;
    
    BOOL toCCT;
    BOOL toPOS;
    
}

@property (nonatomic, retain) NSDecimalNumber *amount;
@property (nonatomic, retain) NSNumber *orderPaymentTypeID;
@property (nonatomic, retain) CreditCardPayment *creditCard;
@property (nonatomic, assign, getter=isSignatureRequired) BOOL isSignatureRequired;
@property (nonatomic, assign, getter=isSignatureCaptured) BOOL isSignatureCaptured;
@property (nonatomic, assign, getter=isSwipeRequired) BOOL isSwipeRequired;
@property (nonatomic, assign, getter=isSwipeCaptured) BOOL isSwipeCaptured;
@property (nonatomic, assign, getter=isToCCT) BOOL toCCT;
@property (nonatomic, assign, getter=isToPOS) BOOL toPOS;

-(BOOL) isCreditCard;
- (PaymentType) getPaymentType;

- (NSString *) getRefundDescription;
@end
