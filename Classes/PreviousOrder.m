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
@synthesize orderDate, orderId, orderType, orderTotal;

- (id)init
{
    self = [super init];
    if (self) {
        facade = [iPOSFacade sharedInstance];
        paymentHistory = nil;
        // Initialization code here.
    }
    
    return self;
}

-(void) dealloc{
    if (paymentHistory)
    {
        [paymentHistory release];    
    }
}

//Needs to call out to the server every time the method is invoked
-(void) getItemsForOrder
{
    
}

- (PaymentHistory *) getPaymentHistory {
    
    if (paymentHistory){
        return paymentHistory;
    }
        
    else
    {
        // call out to the server and get payment history
        paymentHistory = [facade getPaymentHistoryForOrderid:self.orderId];
        return paymentHistory;
    }
}

@end