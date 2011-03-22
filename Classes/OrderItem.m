//
//  OrderItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderItem.h"


@implementation OrderItem

@synthesize lineNumber, statusId, sellingPrice, quantity, item;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(id) initWithItem:(ProductItem *) productItem AndQuantity:(NSDecimalNumber *) productQuantity {
    self = [self init];
    
    if (self == nil) {
        return nil;
    }
    
    [self setItem:productItem];
    [self setQuantity:productQuantity];
    
    return self;
}

-(void) dealloc {
    [lineNumber release];
    [statusId release];
    [sellingPrice release];
    [item release];
    [quantity release];
    
    [super dealloc];
}

@end
