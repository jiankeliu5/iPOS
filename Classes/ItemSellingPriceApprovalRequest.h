//
//  ItemSellingPriceApprovalRequest.h
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderItem.h"
#import "ManagerInfo.h"

@interface ItemSellingPriceApprovalRequest : NSObject {
    NSNumber *itemId;
    NSNumber *priceGroupId;
    
    NSDecimalNumber *retailPrice;
    NSDecimalNumber *sellingPrice;
    
    ManagerInfo *managerInfo;
}

@property (nonatomic, retain) NSNumber *itemId;
@property (nonatomic, retain) NSNumber *priceGroupId;
@property (nonatomic, retain) NSDecimalNumber *retailPrice;
@property (nonatomic, retain) NSDecimalNumber *sellingPrice;
@property (nonatomic, retain) ManagerInfo *managerInfo;

-(id) initWithOrderItem: (OrderItem *) orderItem managerInfo: (ManagerInfo *) theManagerInfo;
#pragma mark -
#pragma mark Marshalling Code
- (NSString *) toXml;

@end
