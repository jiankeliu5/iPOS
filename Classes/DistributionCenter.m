//
//  DistributionCenter.m
//  iPOS
//
//  Created by Torey Lomenda on 2/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "DistributionCenter.h"


@implementation DistributionCenter

@synthesize dcId, availability, isPrimary;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(void) dealloc {
    [dcId release];
    dcId = nil;
    [availability release];
    availability = nil;
    
    [super dealloc];
}

@end
