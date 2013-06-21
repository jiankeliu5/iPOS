//
//  OrderCart.h
//  iPOS
//
//  Created by Torey Lomenda on 4/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSFacade.h"
#import "Order.h"

@interface OrderCart : NSObject {
    iPOSFacade *facade;
    Order *orderInCart;
    NSArray *previousOrderList;
    Order *previousOrder;
    BOOL newOrder;
}

@property (nonatomic, retain) NSArray *previousOrderList;
@property (nonatomic, retain) Order *previousOrder;
@property (nonatomic, assign) BOOL newOrder;

+ (OrderCart *) sharedInstance;

#pragma mark -
#pragma mark Accessors
- (void) clearCart;
- (void) clearPreviousCart;
- (void) clearPreviousOrder;
- (void) clearAllCart;

- (Order *) getOrder;
- (Customer *) getCustomerForOrder;

#pragma mark -
#pragma mark Cart methods
- (void) bindCustomerToOrder: (Customer * ) customer;

- (void) addItem: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
- (void) addReturnItem:  (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity SellingPricePrimary:(NSDecimalNumber *)SellingPricePrimary SellingPriceSecondary:(NSDecimalNumber *) SellingPriceSecondary;
- (void) removeItem: (OrderItem *) orderItem;

- (void) openItem: (OrderItem *) orderItem;
- (BOOL) closeItem: (OrderItem *) orderItem;

- (BOOL) saveOrder;
- (BOOL) saveOrderAsQuote;

- (void) setOrder: (Order *) order;

@end
