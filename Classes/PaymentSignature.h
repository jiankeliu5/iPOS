//
//  PaymentSignature.h
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"

@interface PaymentSignature : NSObject {
    NSString *signatureAsBase64;
    NSString *paymentRefId;
}

@property (nonatomic, retain) NSString *signatureAsBase64;
@property (nonatomic, retain) NSString *paymentRefId;

- (id) initWithPayment: (Payment *) payment;

- (NSArray *) validate;

#pragma mark -
#pragma mark Marshalling methods
- (NSString *) toXml;

@end
