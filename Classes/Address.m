//
//  Address.m
//  iPOS
//
//  Created by Torey Lomenda on 2/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Address.h"


@implementation Address

@synthesize line1, line2, line3, city, state, zipCode, country;

#pragma mark Initializer and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    return self;
}

-(void) dealloc {
    [line1 release];
    [line2 release];
    [line3 release];
    [city release];
    [state release];
    [zipCode release];
    [country release];
    
    [super dealloc];
}
@end
