//
//  PaymentSignature.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "PaymentSignature.h"
#import "PaymentSignatureXmlMarshaller.h"

@implementation PaymentSignature

@synthesize signatureAsBase64, paymentRefId;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id) initWithPayment:(Payment *)payment {
    if (payment == nil) {
        return nil;
    }
    
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    paymentRefId = [payment.paymentRefId retain];
    
    return self;
}

- (void) dealloc {
    [signatureAsBase64 release];
    [paymentRefId release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Method implementations
- (NSArray *) validate {
    NSMutableArray *errorList = [NSMutableArray arrayWithCapacity:0];
    
    if (signatureAsBase64 == nil) {
        Error *error = [[[Error alloc] init] autorelease];
        error.errorId = @"PMT_MISSING_SIGNATURE";
        error.message = @"Missing signature for payment";
        [errorList addObject:error];
    }
    if (paymentRefId == nil) {
        Error *error = [[[Error alloc] init] autorelease];
        error.errorId = @"PMT_MISSING_REFID";
        error.message = @"Missing reference id for payment";
        [errorList addObject:error];
    }    
    
    return errorList;
}

#pragma mark -
#pragma mark Marshalling methods
- (NSString *) toXml {
    PaymentSignatureXmlMarshaller *marshaller = [[[PaymentSignatureXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

@end
