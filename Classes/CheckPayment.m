//
//  CheckPayment.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckPayment.h"

@implementation CheckPayment

- (id) initWithOrder:(Order *)order {
    self = [super initWithOrder:order];
    if (self) {
        // Initialization code here.
        self.paymentTypeId = [NSNumber numberWithInt:CHECK];
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end
