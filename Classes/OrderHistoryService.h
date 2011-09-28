//
//  OrderHistoryService.h
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "SessionInfo.h"
#import "PaymentHistory.h"

@protocol OrderHistoryServiceProtocol <NSObject>

-(NSArray *) lookupOrderByPhoneNumber: (NSString *)phoneNumber withSessionInfo:(SessionInfo *) sessionInfo;
-(PaymentHistory *) getPaymentHistoryForOrderid: (NSString *)orderId withSessionInfo:(SessionInfo *) sessionInfo;

@end


@interface OrderHistoryService : NSObject <OrderHistoryServiceProtocol>
{
    NSString *baseUrl;
    NSString *orderHistoryUri;
}

@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic,retain) NSString *orderHistoryUri;

@end