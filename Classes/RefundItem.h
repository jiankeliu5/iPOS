//
//  RefundItem.h
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreditCardPayment.h"

@interface RefundItem : NSObject
{
    
    NSDecimalNumber *amount;
    NSNumber *orderPaymentTypeID;
    CreditCardPayment *creditCard;
}

@property (nonatomic, retain) NSDecimalNumber *amount;
@property (nonatomic, retain) NSNumber *orderPaymentTypeID;
@property (nonatomic, retain) CreditCardPayment *creditCard;

@end
