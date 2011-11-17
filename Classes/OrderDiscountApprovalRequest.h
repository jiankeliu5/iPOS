//
//  OrderDiscountApprovalRequest.h
//  iPOS
//
//  Created by Torey Lomenda on 11/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Order.h"
#import "ManagerInfo.h"

#import "ItemSellingPriceApprovalRequest.h"

@interface OrderDiscountApprovalRequest : NSObject {
    NSNumber *itemId;
    NSNumber *priceGroupId;
    
    NSDecimalNumber *discountAmount;
    
    ManagerInfo *managerInfo;
    
    NSArray *itemSellingApprovalList;
}

@property (nonatomic, retain) NSNumber *itemId;
@property (nonatomic, retain) NSNumber *priceGroupId;
@property (nonatomic, retain) NSDecimalNumber *discountAmount;
@property (nonatomic, retain) ManagerInfo *managerInfo;
@property (nonatomic, retain) NSArray *itemSellingApprovalList;

-(id) initWithOrder: (Order *) order managerInfo: (ManagerInfo *) theManagerInfo withOrderDiscount: (NSDecimalNumber *) discount;

- (NSDecimalNumber *) getDiscountPerItem;

#pragma mark -
#pragma mark Marshalling Code
- (NSString *) toXml;


@end
