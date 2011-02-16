//
//  iPOSFacade.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSServiceImpl.h"
#import "iPOSServiceMock.h"
#import "InventoryServiceImpl.h"
#import "InventoryServiceMock.h"

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
- (BOOL) verifySession;
- (BOOL) logout;

#pragma mark iPOS Customer Management
-(Customer *) lookupCustomerByEmail: (NSString *) emailAddress;
-(Customer *) lookupCustomerByPhone: (NSString *) phoneNumber;
-(Customer *) newCustomer: (Customer *) customer;
-(void) updateCustomer: (Customer *) customer;

#pragma mark iPOS Order Management
-(Order *) newOrder;
-(void) updateOrder: (Order *) order;
-(BOOL) allowDiscountedPrice: (NSDecimal *) discountPrice forQuantity: (NSDecimal *) quantity;
-(BOOL) allowDiscountedPrice: (NSDecimal *) discountPrice forQuantity: (NSDecimal *) quantity managerApproval: (ManagerApprovalInfo *) managerApproval;


#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku;
-(BOOL) isProductItemAvailable: (NSString *) itemId forQuantity: (NSDecimal *) quantity;

@end
