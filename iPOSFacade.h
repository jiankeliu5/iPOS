//
//  iPOSFacade.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSService.h"
#import "iPOSServiceImpl.h"
#import "iPOSServiceMock.h"
#import "InventoryService.h"
#import "InventoryServiceImpl.h"
#import "InventoryServiceMock.h"

@interface iPOSFacade : NSObject {
    id<iPOSService> posService;
    id<InventoryService> inventoryService;
}

@property (nonatomic, retain) id<iPOSService> posService;
@property (nonatomic, retain) id<InventoryService> inventoryService;

#pragma mark Shared Instance
+ (iPOSFacade *) sharedInstance;

#pragma mark iPOS Session Mgmt
- (void) login;
- (void) verifySession;
- (void) logout;

#pragma mark iPOS Customer Management
-(void) lookupCustomer;
-(void) newCustomer;
-(void) updateCustomer;

#pragma mark iPOS Order Management
-(void) newOrder;
-(void) discountItemPrice;
-(void) processPayment;

#pragma mark Inventory Services
-(void) lookupProductItem;
-(BOOL) isProductItemAvailable;

@end
