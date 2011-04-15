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

@interface Payment : AbstractModel {
    NSNumber *orderId;
    NSNumber *customerId;
    NSNumber *storeId;
    NSNumber *salesPersonId;
    
    NSDecimalNumber *paymentAmount;
    
    NSString *paymentRefId;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *customerId;
@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) NSNumber *salesPersonId;

@property (nonatomic, retain) NSDecimalNumber *paymentAmount;
@property (nonatomic, retain) NSString *paymentRefId;

-(id) initWithOrder: (Order *) order;

@end
