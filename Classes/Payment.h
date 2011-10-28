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
    UNKNOWN,
    CASH,
    CHECK,
    CREDITCARD_VISA,
    CREDITCARD_MC,
    CREDITCARD_DISCOVER,
    CREDITCARD_AX,
    ONACCT
} PaymentType;

@interface Payment : AbstractModel {
    NSNumber *orderId;
    NSNumber *customerId;
    NSNumber *storeId;
    NSNumber *salesPersonId;
    
    NSDecimalNumber *paymentAmount;
    
    NSString *paymentRefId;

    //NSString *lpToken;
    //NSString *tRouteD;
    
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

@property (nonatomic, retain) NSString *cardNumber;


@property (nonatomic, retain) NSNumber *orderPaymentId;
@property (nonatomic, retain) NSString *paymentDate;
@property (nonatomic, retain) NSNumber *paymentTypeId;

-(id) initWithOrder: (Order *) order;

@end
