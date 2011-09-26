//
//  AccountPayment.h
//  iPOS
//
//  Created by Dan C on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Payment.h"
#import "PaymentSignature.h"

@interface AccountPayment : Payment
{
    PaymentSignature *signature;
}

@property (nonatomic, retain) PaymentSignature *signature;

#pragma mark -
#pragma mark Marshalling methods
+ (AccountPayment *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;
- (void) attachSignature:(NSString *)signatureAsBase64;

- (void) mergeWith: (AccountPayment *) mergePayment;
@end
