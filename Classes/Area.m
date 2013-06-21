//
//  Area.m
//  selSheet
//
//  Created by Joshua Walker on 2/10/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "Area.h"

@implementation Area

@synthesize  description, items, note;

- (id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.items = [[NSMutableArray alloc] init];
    
    return self;
}

@end