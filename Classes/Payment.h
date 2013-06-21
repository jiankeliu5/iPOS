//
//  Payment.h
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractModel.h"
#import "Order.h"

typedef enum {
    UNKNOWN = 0,
    CASH = 1,
    CHECK = 2,
    CREDITCARD_VISA = 3,
    CREDITCARD_MC = 4,
    CREDITCARD_DISCOVER = 5,
    CREDITCARD_AX = 6,
    ONACCT = 7,
    INSTORE_CREDIT = 8,
    GIFT_CARD = 12,
    GOOGLE = 13,
    HOMEDESIGN = 14,
    PAYPAL = 16
} PaymentType;

@interface Payment : AbstractModel {
    NSNumber *orderId;
    NSNumber *customerId;
    NSNumber *storeId;
    NSNumber *salesPersonId;
    
    NSDecimalNumber *paymentAmount;
    
    NSString *paymentRefId;
    
    NSNumber *orderPaymentId;
    NSString *paymentDate;
    NSNumber *paymentTypeId;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *customerId;
@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) NSNumber *salesPersonId;

@property (nonatomic, retain) NSDecimalNumber *paymentAmount;
@property (nonatomic, retain) NSString *paymentRefId;

@property (nonatomic, retain) NSNumber *orderPaymentId;
@property (nonatomic, retain) NSString *paymentDate;
@property (nonatomic, retain) NSNumber *paymentTypeId;

-(id) initWithOrder: (Order *) order;

@end
