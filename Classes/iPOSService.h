//
//  POSService.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SessionInfo.h"
#import "Order.h"
#import "Customer.h"
#import "ManagerInfo.h"

@protocol iPOSService <NSObject>

#pragma mark iPOS Session Management
@required 
-(SessionInfo *) login: (NSString *) employeeNumber withPassword: (NSString *) password;
-(BOOL) verifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password;
-(BOOL) logout: (SessionInfo *) sessionInfo;

#pragma mark iPOS Customer Management
@required
-(Customer *) lookupCustomerByPhone: (NSString *) phoneNumber withSession: (SessionInfo *) sessionInfo;
-(void) newCustomer: (Customer *) customer withSession: (SessionInfo *) sessionInfo;
-(void) updateCustomer: (Customer *) customer withSession: (SessionInfo *) sessionInfo;

#pragma mark iPOS Order Management
@required
-(void) newQuote: (Order *) order withSession: (SessionInfo *) sessionInfo;
-(void) newOrder: (Order *) order withSession: (SessionInfo *) sessionInfo;

#pragma mark iPOS Report Management
- (BOOL) emailReceipt: (Order *) order withSession: (SessionInfo *) sessionInfo;

#pragma mark -
#pragma mark Payment Processing

@end
