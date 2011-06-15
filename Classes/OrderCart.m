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
    [orderInCart release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods
-(void) clearCart {
    if (orderInCart != nil) {
        [orderInCart release];
    }
    
    // Create a new blank order
    orderInCart = [[Order alloc] init];
}
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
    if (customer) {
        Customer *previousCustomer = nil;
        Order *order = [self getOrder];

        if (order.customer) {
            previousCustomer = [order.customer retain];
        }
        
        // Set new customer for the order
        order.customer = customer;
        
        // Do we need to do selling price adjustment based on customer?
        // 1.  If previous customer and customer type is different and:
        //      a.  previous customer was not a Retail customer OR
        //      b.  new customer is a contractor type
        // OR
        //
        // 2.  No Previous Customer and Customer is not a Retail Customer
        BOOL doAdjustSellingPrice = NO;
        
        if ((previousCustomer 
            && ![previousCustomer.customerTypeId isEqualToNumber:customer.customerTypeId]
            && (![previousCustomer isRetailCustomer] || ![customer isRetailCustomer]))
            || (previousCustomer == nil && ![customer isRetailCustomer])) {
            doAdjustSellingPrice = YES;
        }
        
        if (doAdjustSellingPrice) {
            NSArray *orderItemList = [order getOrderItems];
            
            for (OrderItem *orderItem in orderItemList) {
                if (![facade adjustSellingPriceFor:orderItem withCustomer:order.customer]) {
                    // Attach error to customer
                    Error *error = [[[Error alloc] init] autorelease];
                    error.errorId = @"SRV_ERR_ADJ_PRICE";
                    error.message = [NSString stringWithFormat: @"Could not set selling price for item in cart with sku '%@'.  Possible server error.", orderItem.item.sku];
                    
                    [customer addError:error];
                    break;
                };
            }
        }
        
        // Release the previous customer
        if (previousCustomer) {
            [previousCustomer release];
        }
    }
}

- (void) addItem:  (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity {
    Order *order = [self getOrder];
    
    [order addItemToOrder:item withQuantity:quantity];
    
    // We may need to adjust the selling price of the item based on the customer
    if (order.customer) {
        OrderItem *orderItem = [[order getOrderItems] lastObject];
        if (![facade adjustSellingPriceFor:orderItem withCustomer:order.customer]) {
            //attach error to order
            Error *error = [[[Error alloc] init] autorelease];
            error.errorId = @"SRV_ERR_ADJ_PRICE";
            error.message = [NSString stringWithFormat: @"Could not set selling price for item with sku '%@'.  Possible server error.", orderItem.item.sku];
            
            [order addError:error];
            
            // Remove the order item since we could not set its selling price
            [order removeItemFromOrder:orderItem];
            return;
        };
    }
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
    
    BOOL isAvailableForClose = [facade isProductItemAvailable: orderItem.item.itemId forQuantity:orderItem.quantityPrimary];
    
    if (isAvailableForClose) {
        [orderItem setStatusToClosed];
    }
    
    return isAvailableForClose;
}

@end
