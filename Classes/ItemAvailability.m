//
//  ItemAvailability.m
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemAvailability.h"
#import "ProductItem.h"

@implementation ItemAvailability

@synthesize availablePrimary, availableSecondary, onHandPrimary,  onHandSecondary, etaDateAsString, item;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(void) dealloc {
    [availablePrimary release];
    [availableSecondary release];
    [onHandPrimary release];
    [onHandSecondary release];
    [etaDateAsString release];
    
    // no need to release item as it is not retained it is just assigned.
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
- (NSDecimalNumber *) getSelectedAvailability {
    if (item && item.selectedUOM == UOMSecondary) {
        return availableSecondary;
    }
    
    return availablePrimary;
}


- (NSDecimalNumber *) getSelectedOnHand {
    if (item && item.selectedUOM == UOMSecondary) {
       return onHandSecondary;
    }
    
    return onHandPrimary;
}
@end
