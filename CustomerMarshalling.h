//
//  CustomerMarshalling.h
//  iPOS
//
//  Created by Torey Lomenda on 3/15/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Customer.h"

@interface CustomerMarshalling : NSObject {
}

+ (NSString *) toXml: (Customer *) customer;
+ (Customer *) toObject: (NSString *) xmlString;

@end
