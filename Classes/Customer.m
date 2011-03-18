//
//  Customer.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Customer.h"


@implementation Customer

@synthesize customerId, customerType, customerTypeId, firstName, lastName, phoneNumber, emailAddress, store, address, errorList, taxExempt;

#pragma mark Initializer and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        
        return nil;
    }
    
    return self;
}

-(void) dealloc {
    [customerType release];
    [customerTypeId release];
    [firstName release];
    [lastName release];
    [phoneNumber release];
    [emailAddress release];
    
    [store release];
    [address release];
    
    if (errorList != nil) {
        [errorList release];
    }
    
    if (customerId != nil) {
        [customerId release];
    }
    [super dealloc];
}

@end
