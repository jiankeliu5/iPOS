//
//  OrderSummary.h
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderSummary : NSObject
{
    NSString *orderDate;
    NSNumber *orderId;
    NSDecimalNumber *orderTotal;
    NSString *orderType;
}

@property (nonatomic, retain) NSString *orderDate;
@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSDecimalNumber *orderTotal;
@property (nonatomic, retain) NSString *orderType;

@end
