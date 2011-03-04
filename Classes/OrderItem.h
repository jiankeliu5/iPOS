//
//  OrderItem.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductItem.h"

@interface OrderItem : NSObject {
    NSDecimalNumber *quantity;
    ProductItem *item;
}

@property (nonatomic, retain) NSDecimalNumber *quantity;
@property (nonatomic, retain) ProductItem *item;

-(id) initWithItem: (ProductItem *) productItem AndQuantity: (NSDecimalNumber *) productQuantity;

@end
