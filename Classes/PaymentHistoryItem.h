//
//  PreviousPayment.h
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Payment.h"

@interface PaymentHistoryItem : NSObject
{
    NSDecimalNumber *amount;
    NSNumber *customerID;
    NSNumber *orderId;
    NSNumber *orderPaymentId;
    NSString *paymentDate;
    NSNumber *paymentTypeId;
    NSNumber *storeId;
}

@property (nonatomic, retain) NSDecimalNumber *amount;
@property (nonatomic, retain) NSNumber *customerID;
@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *orderPaymentId;
@property (nonatomic, retain) NSString *paymentDate;
@property (nonatomic, retain) NSNumber *paymentTypeId;
@property (nonatomic, retain) NSNumber *storeId;

@end
