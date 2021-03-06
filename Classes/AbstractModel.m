//
//  AbstractModel.m
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "AbstractModel.h"


@implementation AbstractModel

@synthesize errorList;

-(id) init {
    self = [super init];
    
    if ([self isMemberOfClass:[AbstractModel class]]) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    return self;
}

-(void) dealloc {
    if (errorList != nil) {
        [errorList release];
    }
    [super dealloc];
}

#pragma mark -
-(void) addError:(Error *)error {
    if (self.errorList == nil) {
       self.errorList = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.errorList addObject:error];
}

-(void) removeAllErrors {
    if (self.errorList != nil) {
        [self.errorList removeAllObjects];
    }
}
@end
