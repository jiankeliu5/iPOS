//
//  PreviousOrder.m
//  iPOS
//
//  Created by Dan C on 9/28/11.
//  Copyright 2011 OPI. All rights reserved.
//

/*
 Container class that holds information about a previous order
 
 */

#import "PreviousOrder.h"

@implementation PreviousOrder
@synthesize orderDate;
@synthesize orderId;
@synthesize orderTotal;
@synthesize orderType;
@synthesize orderTypeId;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) dealloc{
    
    [orderDate release];
    orderDate = nil;
    [orderId release];
    orderId = nil;
    [orderTotal release];
    orderTotal = nil;
    [orderType release];
    orderType = nil;
    [orderTypeId release];
    orderTypeId = nil;
    
    [super dealloc];
}

- (BOOL) canViewDetails {
    return ([self.orderTypeId intValue] != ORDER_TYPE_CANCELLED);
}

@end
