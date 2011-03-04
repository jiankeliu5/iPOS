//
//  ItemAvailability.h
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductItem;
@interface ItemAvailability : NSObject {

    NSDecimalNumber *available;
    NSDecimalNumber *onHand;
    NSString *etaDateAsString;
    
    ProductItem *item;
}

@property (nonatomic, retain) NSDecimalNumber *available;
@property (nonatomic, retain) NSDecimalNumber *onHand;
@property (nonatomic, retain) NSString *etaDateAsString;

@property (nonatomic, retain) ProductItem *item;

@end
