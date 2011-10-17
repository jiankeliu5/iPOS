//
//  PreviousOrder.h
//  iPOS
//
//  Created by Dan C on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iPOSFacade.h"

@interface PreviousOrder : NSObject
{
    NSString *orderDate;
    NSNumber *orderId;
    NSDecimalNumber *orderTotal;
    NSString *orderType;
    NSArray *paymentHistory;
    NSNumber *orderTypeId;
    iPOSFacade *facade;
}

@property (nonatomic, retain) NSString *orderDate;
@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSDecimalNumber *orderTotal;
@property (nonatomic, retain) NSString *orderType;
@property (nonatomic, retain) NSNumber *orderTypeId;

- (Order *) getItemsForOrder;
- (BOOL) canViewDetails;

@end
