//
//  ProductItem.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProductItem : NSObject {
    NSString *itemId;
    NSString *sku;
    
    NSString *name;
    NSString *unitOfMeasure; // Is this its own type ??
    
    NSString *lotNumber;
    NSString *location;
    
    NSDecimal *taxRate;
    
    // Do we need something for an array of sales codes ??
    
}

@end
