//
//  Order.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Store.h"
#import "Customer.h"
#import "OrderItem.h"

@interface Order : NSObject {
    NSNumber *orderId;
    NSNumber *orderTypeId;
    NSNumber *salesPersonEmployeeId;
    
    Store *store;
    Customer *customer;
    
    NSArray *errorList;
    
    @private NSMutableArray *orderItemList;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *orderTypeId;
@property (nonatomic, retain) NSNumber *salesPersonEmployeeId;
@property (nonatomic, retain) Store *store;
@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) NSArray *errorList;

- (NSArray *) getOrderItems;
-(void) addItemToOrder: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
-(void) removeItemFromOrder: (ProductItem *) item;
-(void) removeAll;
@end
