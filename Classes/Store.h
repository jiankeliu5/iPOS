//
//  Store.h
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemAvailability.h"

@interface Store : NSObject {
    NSNumber *storeId;
    
    ItemAvailability *availability;
}

@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) ItemAvailability *availability;

@end
