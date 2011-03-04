//
//  DistributionCenter.h
//  iPOS
//
//  Created by Torey Lomenda on 2/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemAvailability.h"

@interface DistributionCenter : NSObject {
    NSNumber *dcId;
    ItemAvailability *availability;
    
    BOOL isPrimary;
}

@property (nonatomic, retain) NSNumber *dcId;
@property (nonatomic, retain) ItemAvailability *availability;

@property                     BOOL isPrimary;



@end
