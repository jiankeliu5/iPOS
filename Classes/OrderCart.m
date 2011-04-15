//
//  OrderCart.m
//  iPOS
//
//  Created by Torey Lomenda on 4/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderCart.h"


@implementation OrderCart

static OrderCart *cart = nil;

#pragma mark Singleton Initializer
+ (OrderCart *) sharedInstance {
    if (cart == nil) {
        cart = [[super allocWithZone:nil] init];
    } 
    
    return cart;
    
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}
 
#pragma mark -
#pragma mark Constructort/Deconstructor
- (id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Set the facade
    facade = [iPOSFacade sharedInstance];
    
    // Create the order instance.  The Order Cart will manage access to the order cart and its items
    orderInCart = [[Order alloc] init];
    
    return self;
}

-(void) dealloc {
    if (orderInCart != nil) {
        [orderInCart release];
    }
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods
-(Order *) getOrder {
    if (orderInCart == nil) {
        orderInCart = [[Order alloc] init];
    }
    return orderInCart;
}

- (Customer *) getCustomerForOrder {
    return [self getOrder].customer;
}


#pragma mark -
#pragma mark Order Cart Functionality
- (void) bindCustomerToOrder:(Customer *)customer {
    Order *order = [self getOrder];
    
    order.customer = customer;
}

- (void) addItem:  (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity {
    Order *order = [self getOrder];
    
    [order addItemToOrder:item withQuantity:quantity];
}

- (void) removeItem:(OrderItem *)orderItem {
    Order *order = [self getOrder];
    
    [order removeItemFromOrder:orderItem];
}

- (void) openItem: (OrderItem *) orderItem {
    if (orderItem != nil) {
        [orderItem setStatusToOpen];
    }
}

- (BOOL) closeItem:(OrderItem *)orderItem {
    if (orderItem == nil) {
        return NO;
    }
    
    BOOL isAvailableForClose = [facade isProductItemAvailable: orderItem.item.itemId forQuantity:orderItem.quantity];
    
    if (isAvailableForClose) {
        [orderItem setStatusToClosed];
    }
    
    return isAvailableForClose;
}

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscount: (NSDecimalNumber *) discountAmt withManagerApproval: (ManagerInfo *) managerApprover {
    BOOL isAllowed = YES;
    
    // TODO:  adjust price service returning boolean
    
    return isAllowed;
}

@end
