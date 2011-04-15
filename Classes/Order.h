//
//  Order.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractModel.h"
#import "Store.h"
#import "Customer.h"
#import "OrderItem.h"

@interface Order : AbstractModel {
    NSNumber *orderId;
    NSNumber *orderTypeId;
    NSNumber *salesPersonEmployeeId;
    
    Store *store;
    Customer *customer;
        
    @private NSMutableArray *orderItemList;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *orderTypeId;
@property (nonatomic, retain) NSNumber *salesPersonEmployeeId;
@property (nonatomic, retain) Store *store;
@property (nonatomic, retain) Customer *customer;

- (NSArray *) getOrderItems;
- (void) addItemToOrder: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
- (void) removeItemFromOrder: (OrderItem *) item;
- (void) removeAll;

#pragma mark -
#pragma mark Order Type methods
- (void) setAsQuote;

- (NSNumber *) getOrderTypeId;
- (BOOL) isClosed;

- (void) mergeWith: (Order *) mergeOrder;

#pragma mark -
#pragma mark Validation methods
- (BOOL) validateAsNew;
- (BOOL) validateAsNewQuote;
- (BOOL) validateAsNewOrder;
 
#pragma mark -
#pragma mark Marshalling methods
+ (Order *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;

@end
