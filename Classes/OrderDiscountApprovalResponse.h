//
//  OrderDiscountApprovalResponse.h
//  iPOS
//
//  Created by Torey Lomenda on 11/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemSellingPriceApprovalResponse.h"

@interface OrderDiscountApprovalResponse : NSObject {
    NSArray *itemSellingPriceApprovalList;
}

@property (nonatomic, retain) NSArray *itemSellingPriceApprovalList;

- (BOOL) isApproved;

#pragma mark -
#pragma mark Marshalling methods
+ (OrderDiscountApprovalResponse *) fromXml: (NSString *) xmlString;
@end
