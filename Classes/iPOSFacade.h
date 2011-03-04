//
//  iPOSFacade.h
//  iPOS

//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSServiceImpl.h"
#import "InventoryServiceImpl.h"


@interface iPOSFacade : NSObject {
    id<iPOSService> posService;
    id<InventoryService> inventoryService;
    
    SessionInfo * sessionInfo;
}

@property (nonatomic, retain) id<iPOSService> posService;
@property (nonatomic, retain) id<InventoryService> inventoryService;
@property (assign) SessionInfo *sessionInfo;

#pragma mark Shared Instance
+ (iPOSFacade *) sharedInstance;

#pragma mark iPOS Session Mgmt
- (BOOL) login: (NSString *) username password: (NSString *) password;
- (BOOL) verifySession: (NSString *) passwordToVerify;
- (BOOL) logout;

#pragma mark iPOS Customer Management
-(Customer *) lookupCustomerByPhone: (NSString *) phoneNumber;
-(void) newCustomer: (Customer *) customer;
-(void) updateCustomer: (Customer *) customer;

#pragma mark iPOS Order Management
-(void) newOrder;
-(void) updateOrder: (Order *) order;
-(BOOL) allowDiscountedPrice: (NSDecimal *) discountPrice forQuantity: (NSDecimal *) quantity;
-(BOOL) allowDiscountedPrice: (NSDecimal *) discountPrice forQuantity: (NSDecimal *) quantity managerApproval: (ManagerApprovalInfo *) managerApproval;


#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku;
-(BOOL) isProductItemAvailable: (NSString *) itemId forQuantity: (NSDecimal *) quantity;

@end
