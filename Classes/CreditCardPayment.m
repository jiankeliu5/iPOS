//
//  CreditCardPayment.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CreditCardPayment.h"
#import "NSString+StringFormatters.h"

#import "Order.h"
#import "CCPaymentXmlMarshaller.h"

@implementation CreditCardPayment

@synthesize expireDate;
@synthesize cardNumber;
@synthesize nameOnCard;
@synthesize lpToken;
@synthesize signature;

#pragma mark -
#pragma mark Constructor/Deconstructor
-(id) initWithOrder: (Order *) order {
    self = [super initWithOrder:order];
    
    return self;
}

- (void) dealloc {
    [expireDate release];
    expireDate = nil;
    [cardNumber release];
    cardNumber = nil;
    [nameOnCard release];
    nameOnCard = nil;
    [lpToken release];
    lpToken = nil;
    [signature release];
    signature = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void) setExpireDateMonthYear:(NSString *) month year: (NSString *) year {
    if (month != nil && year != nil) {
        int MAX_LENGTH = 2;
        NSString *padMonth = month;
        NSString *padYear = year;
        
        if ([padMonth length] != MAX_LENGTH) {
            if ([padMonth length] < MAX_LENGTH) {
                padMonth = [padMonth padLeft:@"0" withMaxSize:MAX_LENGTH];
            } else {
                padMonth = [padMonth substringFromIndex:[padMonth length]-MAX_LENGTH];
            }
        }
        
        if ([padYear length] != 2) {
            if ([padYear length] < MAX_LENGTH) {
                padYear = [padYear padLeft:@"0" withMaxSize:MAX_LENGTH];
            } else {
                padYear = [padYear substringFromIndex:[padYear length]-MAX_LENGTH];
            }
        }
        
        
        
        self.expireDate = [NSString stringWithFormat:@"%@%@", padMonth, padYear];
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
