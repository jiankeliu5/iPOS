//
//  HomeDesignPayment.m
//  iPOS
//
//  Created by Torey Lomenda on 11/14/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "HomeDesignPayment.h"

@implementation HomeDesignPayment

- (id) initWithOrder:(Order *)order {
    self = [super initWithOrder:order];
    if (self) {
        // Initialization code here.
        self.paymentTypeId = [NSNumber numberWithInt:HOMEDESIGN];
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end
