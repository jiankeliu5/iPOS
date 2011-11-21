//
//  OrderCart.m
//  iPOS
//
//  Created by Torey Lomenda on 4/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//
#import "OrderCart.h"
#import"PreviousOrder.h"

#import "AlertUtils.h"

@interface OrderCart() 

- (NSArray *) sortByTypeAndDate: (NSArray *) unSortedArray;

@end

@implementation OrderCart

@synthesize previousOrderList;
@synthesize previousOrder;
@synthesize newOrder;

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
    
    // Default to working with the new order
    newOrder = YES;
    
    return self;
}

-(void) dealloc {
    [orderInCart release];
    orderInCart = nil;
    [self setPreviousOrderList:nil];
    [self setPreviousOrder:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setPreviousOrderList:
//=========================================================== 
- (void)setPreviousOrderList:(NSArray *)aPreviousOrderList {
    if (previousOrderList != aPreviousOrderList) {
        [aPreviousOrderList retain];
        [previousOrderList release];
        
        // Make sure the list is sorted
        previousOrderList = [[self sortByTypeAndDate: aPreviousOrderList] retain];
    }
}


-(void) clearCart {
    if (orderInCart != nil) {
        [orderInCart release];
    }
    
    // Create a new blank order
    orderInCart = [[Order alloc] init];

}

- (void) clearPreviousCart {
    
    [self clearPreviousOrder];
    
    if (previousOrderList != nil) {
        [previousOrderList release];
        previousOrderList = nil;
    }
}

- (void) clearPreviousOrder {
    
    // Notify the user of lost changes to a modified order
    if (previousOrder && [previousOrder isModified]) {
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Changes to order %@ were not saved.", previousOrder.orderId] withTitle:@"iPOS"];
    }
    
    // Since the previous order and previous order list can
    // change we will let their unset state be nil instead of
    // an unfilled instance like orderInCart.
    if (previousOrder != nil) {
        [previousOrder release];
        previousOrder = nil;
    }
}

- (void) clearAllCart {
    [self clearCart];
    
    [self clearPreviousCart];
    
    // reset to pointing to the new order
    newOrder = YES;
}

-(Order *) getOrder {
    if (newOrder) {
        if (orderInCart == nil) {
            orderInCart = [[Order alloc] init];
        }
        return orderInCart;
    } else {
        return previousOrder;
    }
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
                    [customer removeAllErrors];
                    
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
            [order removeAllErrors];
            
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
    BOOL itemClosed = NO;
    
    if (orderItem == nil || [orderItem.statusId intValue] != LINE_ORDERSTATUS_OPEN) {
        return itemClosed;
    }
    
    if (orderItem.isNew) {
        // Don't use [orderItem allowClose] here because we want to check the store availability right now
        // rather than using the previous value we found when we looked up the item.
        itemClosed = [facade isProductItemAvailable: orderItem.item.itemId forQuantity:orderItem.quantityPrimary];
    } else {
        // For an existing line item, we can ask the order item if we can close it.
        itemClosed = [orderItem allowClose];
    }
    
    if (itemClosed) {
        [orderItem setStatusToClosed];
    }
    
    return itemClosed;
}

- (BOOL) saveOrder {
    Order *cartOrder = [self getOrder];
    
    // if this is not a new order and it is an order quote, switch it to a new order
    if (!cartOrder.isNewOrder && [cartOrder isQuote]) {
        [cartOrder setAsNewOrder];
    } if (cartOrder.isNewOrder) {
        [cartOrder setAsNewOrder];
    }
    
    // Save the order
    [facade saveOrder:cartOrder];
    
    if ([cartOrder.errorList count] == 0 && cartOrder.orderId != nil) {
        return YES;
    }
    
    [AlertUtils showModalAlertForErrors:cartOrder.errorList withTitle:@"iPOS"];
    return NO;    
}


#pragma mark -
#pragma mark Private Methods
- (NSArray *) sortByTypeAndDate:(NSArray *)unSortedArray {
    
    if (unSortedArray) {
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        // The T literal needs to be escaped as 'T' or the match will not work.
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        // Sort the list of orders by order type and then date newest first.
        NSArray *sortedOrderList = [unSortedArray sortedArrayUsingComparator:^(id a, id b) {
                                        NSComparisonResult statusSort = [((PreviousOrder *)a).orderTypeId compare:((PreviousOrder *)b).orderTypeId];
                                        if (statusSort == NSOrderedSame) {
                                            NSDate *dateA = [dateFormatter dateFromString:((PreviousOrder *)a).orderDate];
                                            NSDate *dateB = [dateFormatter dateFromString:((PreviousOrder *)b).orderDate];
                                            return [dateB compare:dateA];
                                        } 
                                        return statusSort;
                                    }];
        
        [dateFormatter release];
        return sortedOrderList;
    }
    
    return unSortedArray;

}

@end
