//
//  OrderMarhsalling.h
//  iPOS
//
//  Created by Torey Lomenda on 3/21/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface OrderMarshalling : NSObject {
}

+ (NSString *) toXml: (Order *) order;
+ (Order *) toObjectFromOrderReturn: (NSString *) orderReturnXml;

@end
