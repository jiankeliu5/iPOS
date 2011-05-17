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
}

+ (OrderCart *) sharedInstance;

#pragma mark -
#pragma mark Accessors
- (void) clearCart;
- (Order *) getOrder;
- (Customer *) getCustomerForOrder;


#pragma mark -
#pragma mark Cart methods
- (void) bindCustomerToOrder: (Customer * ) customer;

- (void) addItem: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
- (void) removeItem: (OrderItem *) orderItem;

- (void) openItem: (OrderItem *) orderItem;
- (BOOL) closeItem: (OrderItem *) orderItem;

@end
