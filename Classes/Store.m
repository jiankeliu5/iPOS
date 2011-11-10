//
//  Store.m
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Store.h"


@implementation Store

@synthesize storeId, availability;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(void) dealloc {
    [storeId release];
    storeId = nil;
    [availability release];
    availability = nil;
    
    [super dealloc];
}
@end
