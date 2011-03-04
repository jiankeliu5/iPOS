//
//  Customer.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Customer.h"


@implementation Customer

@synthesize customerId, firstName, lastName, phoneNumber, emailAddress, address, errorList;

#pragma mark Initializer and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        
        return nil;
    }
    
    return self;
}

-(void) dealloc {
    [firstName release];
    [lastName release];
    [phoneNumber release];
    [emailAddress release];
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
