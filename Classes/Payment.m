//
//  Payment.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Payment.h"


@implementation Payment

@synthesize customerId, orderId, salesPersonId, storeId, paymentAmount, paymentRefId, cardNumber, lpToken, tRouteD;
@synthesize orderPaymentId, paymentDate, paymentTypeId;

#pragma mark -
#pragma mark Constructor/Deconstructor
-(id) initWithOrder: (Order *) order {
    if (order == nil || order.store == nil || order.customer == nil || order.salesPersonEmployeeId == nil) {
        return nil;
    }
    
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    orderId = [order.orderId retain];
    customerId = [order.customer.customerId retain];
    storeId = [order.store.storeId retain];
    salesPersonId = [order.salesPersonEmployeeId retain];
    
    return self;
}

- (void) dealloc {
    [orderId release];
    [customerId release];
    [salesPersonId release];
    [storeId release];
    
    [paymentAmount release];
    [paymentRefId release];

    
    [super dealloc];
}
@end
