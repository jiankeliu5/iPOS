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

@protocol OrderHistoryServiceProtocol <NSObject>
-(Order *) lookupOrderByOrderId:(NSString *) orderId withSessionInfo: (SessionInfo *) sessionInfo;
-(NSArray *) lookupOrderByPhoneNumber: (NSString *)phoneNumber withSessionInfo:(SessionInfo *) sessionInfo;
-(NSArray *) getPaymentHistoryForOrderid: (NSString *)orderId withSessionInfo:(SessionInfo *) sessionInfo;

@end


@interface OrderHistoryService : NSObject <OrderHistoryServiceProtocol>
{
    NSString *baseUrl;
    NSString *orderHistoryUri;
}

@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic,retain) NSString *orderHistoryUri;

@end
