//
//  OrderItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderItem.h"

static int const STATUS_OPEN = 1;
static int const STATUS_CLOSE = 2;

@implementation OrderItem

@synthesize lineNumber, statusId, sellingPrice, quantity, managerApprover, item, shouldDelete, shouldClose;

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
    
    // Default the status to open
    self.statusId = [NSNumber numberWithInt:STATUS_OPEN];
    
    [self setItem:productItem];
    [self setQuantity:productQuantity];
    
    return self;
}

-(void) dealloc {
    [lineNumber release];
    [statusId release];
    [sellingPrice release];
    
    if (managerApprover != nil) {
        [managerApprover release];
    }
    [item release];
    [quantity release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Method implementations
- (void) setStatusToOpen {
    statusId = [NSNumber numberWithInt:STATUS_OPEN];
}

- (void) setStatusToClosed {
    statusId = [NSNumber numberWithInt:STATUS_CLOSE];
}

- (BOOL) isClosed {
    return [statusId isEqualToNumber: [NSNumber numberWithInt:STATUS_CLOSE]];
}

@end
