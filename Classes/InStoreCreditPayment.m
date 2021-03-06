//
//  InStoreCreditPayment.m
//  iPOS
//
//  Created by Torey Lomenda on 11/14/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "InStoreCreditPayment.h"

@implementation InStoreCreditPayment

- (id) initWithOrder:(Order *)order {
    self = [super initWithOrder:order];
    if (self) {
        // Initialization code here.
        self.paymentTypeId = [NSNumber numberWithInt:INSTORE_CREDIT];
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end
