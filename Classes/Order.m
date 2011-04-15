//
//  Order.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Order.h"
#import "OrderXmlMarshaller.h"

static int const ORDER_TYPE_QUOTE = 1;
static int const ORDER_TYPE_OPEN = 2;
static int const ORDER_TYPE_CLOSED = 3;

@implementation Order

@synthesize orderId, orderTypeId, salesPersonEmployeeId, store, customer;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return self;
    }
    
    orderItemList = [[NSMutableArray arrayWithCapacity:0] retain];
    return self;
}

-(void) dealloc {
    [orderId release];
    [orderTypeId release];
    [salesPersonEmployeeId release];
    
    [store release];
    [customer release];
    
    [orderItemList release];
    
    [super dealloc];
}

#pragma mark -
#pragma Accessor Methods
- (void) setAsQuote {
    orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_QUOTE];
}

- (NSNumber *) getOrderTypeId {
    // Determine if all items are closed or some are open.  Do this check for safety.
    if ([self isClosed]) {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_CLOSED]; 
    } else {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_OPEN];
    }
    
    return self.orderTypeId;
}

- (BOOL) isClosed {
    // Determine if all items are closed or some are open
    for (OrderItem *orderItem in orderItemList) {
        if (![orderItem isClosed]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark Marshalling
+ (Order *) fromXml:(NSString *)xmlString {
    OrderXmlMarshaller *marshaller = [[[OrderXmlMarshaller alloc] init] autorelease];
    return (Order *) [marshaller toObject:xmlString];
}

- (NSString *) toXml {
    OrderXmlMarshaller *marshaller = [[[OrderXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

#pragma mark -
#pragma mark Validation methods
- (BOOL) validateAsNew {
    if (self.orderId != nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = [NSString stringWithFormat:@"Order is seems to have been alread created with id '%@'.", self.orderId];
        error.reference = self;
        
        [self addError:error];
        return NO;
    } 
    
    return YES;        
}

- (BOOL) validateAsNewQuote {
    [self validateAsNew];
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL) validateAsNewOrder {
    [self validateAsNew];
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
-(NSArray *) getOrderItems {
    return orderItemList;
}

-(void) addItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity {
    
    if (orderItemList != nil) {
        // We can add multiple items of the same type to an order
        OrderItem *orderItem = [[[OrderItem alloc] initWithItem:item AndQuantity:quantity] autorelease];
        
        [orderItemList addObject:orderItem];

        // Set the line number based on the index the item was added in
        orderItem.lineNumber = [NSNumber numberWithInt: [orderItemList count]];
        
        // Set the selling price to the retail price
        // Default the status to 1
        // TODO: This method will change to add to order with quantity and price.  
        // TODO: Do we still default the status
        orderItem.statusId = [NSNumber numberWithInt:1];
        orderItem.sellingPrice = [item.retailPrice copy];    
        
    }
}

-(void) removeItemFromOrder:(OrderItem *)item {
    if (orderItemList != nil) {
        
        // Remove the instance of order item
        for (OrderItem *orderItem in orderItemList) {
            if (orderItem == item) {
                [orderItemList removeObject:orderItem];
                break;
            }
        }   
        
        // Adjust the line number for the remaining order items (Start at 1)
        int index = 1;
        for (OrderItem *orderItem in orderItemList) {
            orderItem.lineNumber = [NSNumber numberWithInt:index++];
        }
    }
    
}

-(void) removeAll {
    if (orderItemList != nil) {
        [orderItemList removeAllObjects];
    }
}

- (void) mergeWith:(Order *) mergeOrder {
    // If there are errors just merge the errors, otherwise merge everything else
    if (mergeOrder.errorList && [mergeOrder.errorList count] > 0) {
        self.errorList = [NSArray arrayWithArray: mergeOrder.errorList];
        return;
    }

    if (mergeOrder.orderId && ![mergeOrder.orderId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        self.orderId = mergeOrder.orderId;
    }
}

@end
