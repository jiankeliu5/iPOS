//
//  SessionInfo.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Customer.h"
#import "Order.h"

@interface SessionInfo : NSObject {
    NSNumber *employeeId;
    NSNumber *storeId;
    NSString *deviceId;
    NSString *serverSessionId;
    
    NSString *loginUserName;
    NSString *passwordForVerification;
	
	Customer *currentCustomer;
	Order *currentOrder;
}

@property (nonatomic, retain) NSNumber *employeeId;
@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, retain) NSString *serverSessionId;

@property (nonatomic, retain) NSString *loginUserName;
@property (nonatomic, retain) NSString *passwordForVerification;

@property (nonatomic, retain) Customer *currentCustomer;
@property (nonatomic, retain) Order *currentOrder;


+ (SessionInfo *) fromXml: (NSString *) xmlString;
- (NSString *) toLoginRequestXml;

@end
