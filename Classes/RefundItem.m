//
//  RefundItem.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RefundItem.h"

@implementation RefundItem

@synthesize creditCard, amount, orderPaymentTypeID, isSignatureRequired;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(BOOL) isCreditCard{
    
    int id = [self.orderPaymentTypeID intValue];
    
    return (id == 3 || id == 4 | id == 5 || id == 6);
    
    
}

- (PaymentType) getPaymentType {
    return [orderPaymentTypeID intValue];
}

@end
