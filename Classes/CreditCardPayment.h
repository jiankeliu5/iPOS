//
//  CreditCardPayment.h
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Payment.h"
#import "PaymentSignature.h"

@interface CreditCardPayment : Payment {
    NSString *expireDate;
    NSString *cardNumber;
    NSString *nameOnCard;
    NSString *lpToken;
    NSString *tRouteD;
    
    
    PaymentSignature *signature;
}

@property (nonatomic, retain) NSString *expireDate;
@property (nonatomic, retain) NSString *cardNumber;
@property (nonatomic, retain) NSString *nameOnCard;
@property (nonatomic, retain) NSString *lpToken;
@property (nonatomic, retain) NSString *tRouteD;
@property (nonatomic, retain) PaymentSignature *signature;

- (void) setExpireDateMonthYear: (NSString *) month year: (NSString *) year;

- (BOOL) validate;

- (void) attachSignature: (NSString *) signatureAsBase64;

#pragma mark -
#pragma mark Marshalling methods
+ (CreditCardPayment *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;

#pragma mark -
#pragma mark Helper Methods
- (void) mergeWith: (CreditCardPayment *) mergePayment;

@end
