//
//  CreditCardPayment.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CreditCardPayment.h"

#import "Order.h"
#import "CCPaymentXmlMarshaller.h"

@implementation CreditCardPayment

@synthesize expireDate, cardNumber, nameOnCard, signature;


#pragma mark -
#pragma mark Constructor/Deconstructor
-(id) initWithOrder: (Order *) order {
    self = [super initWithOrder:order];
    return self;
}

- (void) dealloc {
    [expireDate release];
    [cardNumber release];
    [nameOnCard release];
    [signature release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void) setExpireDateMonthYear:(NSString *) month year: (NSString *) year {
    if (month != nil && year != nil) {
        self.expireDate = [NSString stringWithFormat:@"%@%@", month, [year substringFromIndex:[year length] - 2]];
    }
}

#pragma mark -
#pragma mark Method implementations

- (BOOL) validate {
    // A credit card payment is valid if all the fields are entered, and the date is in the right format
    if (self.expireDate == nil) {
        Error *error = [[[Error alloc] init] autorelease];
        error.errorId = @"PMT_CC_MISSING_DATE";
        error.message = @"Missing expiration date for credit card payment";
        [self addError:error];
    }
    if (self.cardNumber == nil) {
        Error *error = [[[Error alloc] init] autorelease];
        error.errorId = @"PMT_CC_MISSING_NUMBER";
        error.message = @"Missing card number for credit card payment";
        [self addError:error];
    }
    if (self.nameOnCard == nil) {
        Error *error = [[[Error alloc] init] autorelease];
        error.errorId = @"PMT_CC_MISSING_NAMEONCARD";
        error.message = @"Missing name on card for credit card payment";
        [self addError:error];
    }
    
    // TODO: Validate formats.  Also, put error ids as constants
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

- (void) attachSignature:(NSString *)signatureAsBase64 {
    // Create the payment signature and assign it
    PaymentSignature *paySignature = [[[PaymentSignature alloc] initWithPayment:self] autorelease];
    
    paySignature.signatureAsBase64 = signatureAsBase64;
    self.signature = paySignature;
}

#pragma mark -
#pragma mark Marshalling methods
+ (CreditCardPayment *) fromXml: (NSString *) xmlString {
    CCPaymentXmlMarshaller *marshaller = [[[CCPaymentXmlMarshaller alloc] init] autorelease];
    return (CreditCardPayment *) [marshaller toObject:xmlString];
}

- (NSString *) toXml {
    CCPaymentXmlMarshaller *marshaller = [[[CCPaymentXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

#pragma mark -
#pragma mark Helper Methods
- (void) mergeWith: (CreditCardPayment *) mergePayment {
    // If there are errors just merge the errors, otherwise merge everything else
    if (mergePayment.errorList && [mergePayment.errorList count] > 0) {
        self.errorList = [NSArray arrayWithArray: mergePayment.errorList];
        return;
    }
    
    // Merge other properties for the payment (the reference id)
    if (mergePayment.paymentRefId && ![mergePayment.paymentRefId isEqualToString:@"0"]) {
        self.paymentRefId = mergePayment.paymentRefId;
    }
}


@end
