//
//  ItemAvailability.m
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemAvailability.h"


@implementation ItemAvailability

@synthesize available, onHand, etaDateAsString, item;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(void) dealloc {
    [available release];
    [onHand release];
    [etaDateAsString release];
    
    // no need to release item as it is not retained it is just assigned.
    [super dealloc];
}
@end
