//
//  SSOrderCart.h
//  iPOS
//
//  Created by Enning Tang on 8/6/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSFacade.h"
#import "Order.h"

@interface SSOrderCart : NSObject {
    iPOSFacade *facade;
    Order *orderInCart;
    NSArray *previousOrderList;
    Order *previousOrder;
    BOOL newOrder;
}

@property (nonatomic, retain) NSArray *previousOrderList;
@property (nonatomic, retain) Order *previousOrder;
@property (nonatomic, assign) BOOL newOrder;

+ (SSOrderCart *) sharedInstance;

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
- (void) removeItem: (OrderItem *) orderItem;

- (void) openItem: (OrderItem *) orderItem;
- (BOOL) closeItem: (OrderItem *) orderItem;

- (BOOL) saveOrder;
- (BOOL) saveOrderAsQuote;

@end
