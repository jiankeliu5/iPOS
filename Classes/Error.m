//
//  Error.m
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Error.h"


@implementation Error

@synthesize errorMsgString, reference;

-(id) init {
    self = [super init];
    return self;
}

-(void) dealloc {
    [errorMsgString release];
    
    [super dealloc];
}
@end
