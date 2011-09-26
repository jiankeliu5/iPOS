//
//  AccountPayment.m
//  iPOS
//
//  Created by Dan C on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountPayment.h"
#import "AccountPaymentXmlMarshaller.h"

@implementation AccountPayment


@synthesize signature;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) attachSignature:(NSString *)signatureAsBase64 {
    // Create the payment signature and assign it
    PaymentSignature *paySignature = [[[PaymentSignature alloc] initWithPayment:self] autorelease];
    
    paySignature.signatureAsBase64 = signatureAsBase64;
    self.signature = paySignature;
}

#pragma mark -
#pragma mark Marshalling methods
+ (AccountPayment *) fromXml: (NSString *) xmlString {
    
    AccountPaymentXmlMarshaller *marshaller = [[[AccountPaymentXmlMarshaller alloc] init] autorelease];
    return (AccountPayment *) [marshaller toObject:xmlString];  
    
}
- (NSString *) toXml {
    AccountPaymentXmlMarshaller *marshaller = [[[AccountPaymentXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}



#pragma mark -
#pragma mark Helper Methods
- (void) mergeWith: (AccountPayment *) mergePayment {
    // If there are errors just merge the errors, otherwise merge everything else
    if (mergePayment.errorList && [mergePayment.errorList count] > 0) {
        NSArray *errors = [NSArray arrayWithArray:mergePayment.errorList];
        
        // Add an error at index 0
        Error *paymentError = [[[Error alloc] init] autorelease];
        paymentError.errorId = @"ERR_PAY";
        paymentError.message = [NSString stringWithFormat:@"Could not process payment for order '%@'.", self.orderId];
        [self addError:paymentError];
        
        for (Error *error in errors) {
            [self addError:error];
        }
        
        return;
    }
    
    // Merge other properties for the payment (the reference id)
    if (mergePayment.paymentRefId && ![mergePayment.paymentRefId isEqualToString:@"0"]) {
        self.paymentRefId = mergePayment.paymentRefId;
    }
}


@end
