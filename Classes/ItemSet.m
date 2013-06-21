//
//  ItemSet.m
//  iPOS
//
//  Created by Enning Tang on 8/2/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "ItemSet.h"

@implementation ItemSet
@synthesize items = _items;

-(id) init {
    if ((self = [super init])){
        self.items = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

-(void) dealloc{
    self.items = nil;
    [super dealloc];
}

@end
