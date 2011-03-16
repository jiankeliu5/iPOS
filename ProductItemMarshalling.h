//
//  ProductItemMarshalling.h
//  iPOS
//
//  Created by Torey Lomenda on 3/16/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductItem.h"

@interface ProductItemMarshalling : NSObject {
}

+ (ProductItem *) toObject: (NSString *) xmlString;
+ (BOOL) isProductAvailable: (NSString *) xmlResponse;

@end
