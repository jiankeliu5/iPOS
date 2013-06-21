//
//  Payment.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Payment.h"


@implementation Payment

@synthesize orderId;
@synthesize customerId;
@synthesize storeId;
@synthesize salesPersonId;
@synthesize paymentAmount;
@synthesize paymentRefId;
@synthesize orderPaymentId;
@synthesize paymentDate;
@synthesize paymentTypeId;


#pragma mark -
#pragma mark Constructor/Deconstructor
-(id) initWithOrder: (Order *) order {
    
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    if (order) {
        orderId = [order.orderId retain];
        salesPersonId = [order.salesPersonEmployeeId retain];
        
        if (order.customer) {
           customerId = [order.customer.customerId retain];
        }
        
        if (order.store) {
            storeId = [order.store.storeId retain];
        }
    }
   
    
    
    return self;
}

- (void) dealloc {
    [orderId release];
    orderId = nil;
    [customerId release];
    customerId = nil;
    [storeId release];
    storeId = nil;
    [salesPersonId release];
    salesPersonId = nil;
    [paymentAmount release];
    paymentAmount = nil;
    [paymentRefId release];
    paymentRefId = nil;
    [orderPaymentId release];
    orderPaymentId = nil;
    [paymentDate release];
    paymentDate = nil;
    [paymentTypeId release];
    paymentTypeId = nil;
    
    [super dealloc];
}
@end
