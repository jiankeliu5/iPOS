//
//  Order.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Order.h"


@implementation Order

@synthesize customer, errorList;

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

    [customer release];
    [orderItemList release];
    
    if (errorList != nil) {
        [errorList release];
    }
    [super dealloc];
}

#pragma mark -
-(void) addItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity {
    
    if (orderItemList != nil) {
        BOOL itemAlreadyInOrder = NO;
        
        for (OrderItem *orderItem in orderItemList) {
            if (orderItem.item == item) {
                itemAlreadyInOrder = YES;
                break;
            }
        }
        
        if (!itemAlreadyInOrder) {
            [orderItemList addObject:[[[OrderItem alloc] initWithItem:item AndQuantity:quantity] autorelease]];
        }
    }
}

-(void) removeItemFromOrder:(ProductItem *)item {
    if (orderItemList != nil) {
        
        for (OrderItem *orderItem in orderItemList) {
            if (orderItem.item == item) {
                [orderItemList removeObject:orderItem];
                break;
            }
        }    
    }
    
}

-(void) removeAll {
    if (orderItemList != nil) {
        [orderItemList removeAllObjects];
    }
}

@end
