//
//  Refund.h
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RefundItem.h"
#import "LineaSDK.h"

@interface Refund : AbstractModel {
    NSNumber *orderId;
    NSNumber *customerId;
    NSNumber *storeId;
    NSNumber *salesPersonId;
    NSString *refundDate;
    
    NSString *signature;
    
    NSMutableArray *refundItems;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *customerId;
@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) NSNumber *salesPersonId;
@property (nonatomic, retain) NSString *refundDate;

@property (nonatomic, retain) NSString *signature;

@property (nonatomic, retain) NSArray *refundItems;

- (void) addRefundItem:(RefundItem *)item;

- (NSDecimalNumber *) getTotalRefundAmount;

- (NSString *) toXml;

- (BOOL) isCardSwipeRequired;
- (BOOL) isSignatureRequired;

- (RefundItem *) getCurrentRefundItemForSwipe;
- (void) setCardData: (financialCard) cardData;
@end
