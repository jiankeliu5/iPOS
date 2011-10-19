//
//  Refund.h
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RefundItem.h"

@interface Refund : AbstractModel   
{
    NSNumber *orderId;
    NSNumber *customerId;
    NSNumber *storeId;
    NSNumber *salesPersonId;
    NSString *refundDate;
    
    NSMutableArray *refundItems;
    
    PaymentSignature *signature;
}

@property (nonatomic, retain) NSArray *refundItems;

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *customerId;
@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) NSNumber *salesPersonId;
@property (nonatomic, retain) NSString *refundDate;
@property (nonatomic, retain) PaymentSignature *signature;

- (void) addRefundItem:(RefundItem *)item;
- (NSArray *) getRefundItems;
- (NSString *) toXml;
@end
