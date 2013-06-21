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

    NSDecimalNumber *availablePrimary;
    NSDecimalNumber *availableSecondary;
    
    NSDecimalNumber *onHandPrimary;
    NSDecimalNumber *onHandSecondary;
    
    NSString *etaDateAsString;
    
    ProductItem *item;
}

@property (nonatomic, retain) NSDecimalNumber *availablePrimary;
@property (nonatomic, retain) NSDecimalNumber *availableSecondary;

@property (nonatomic, retain) NSDecimalNumber *onHandPrimary;
@property (nonatomic, retain) NSDecimalNumber *onHandSecondary;

@property (nonatomic, retain) NSString *etaDateAsString;

@property (nonatomic,assign) ProductItem *item;

- (NSDecimalNumber *) getSelectedAvailability;
- (NSDecimalNumber *) getSelectedOnHand;

@end
