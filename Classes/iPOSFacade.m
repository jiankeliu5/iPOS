//
//  iPOSFacade.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSFacade.h"


@implementation iPOSFacade

static iPOSFacade *facade = nil;

@synthesize posService, inventoryService, sessionInfo;

#pragma mark Singleton Initializer
+ (iPOSFacade *) sharedInstance {
    if (facade == NULL) {
        facade = [[super allocWithZone:NULL] init];
    } 
    
    return facade;
    
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];}

#pragma mark Constructor/Destructor
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.posService = [[[iPOSServiceImpl alloc] init] autorelease];
    self.inventoryService = [[[InventoryServiceImpl alloc] init] autorelease];    
    
    return self;
}

-(void) dealloc {
    [posService release];
    [inventoryService release];
    [sessionInfo release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark iPOS Session Mgmt
- (BOOL) login: (NSString *) username password: (NSString *) password {
    sessionInfo = [[posService login:username withPassword:password] retain];
    
    if (sessionInfo != nil) {
        return TRUE;
    }
    
	return FALSE;
}

-(BOOL) verifySession:(NSString *)passwordToVerify {
    return [posService verifySession:sessionInfo withPassword:passwordToVerify];
}

-(BOOL) logout {
	BOOL logoutStatus = [posService logout:sessionInfo];
	[self.sessionInfo release];
	self.sessionInfo = nil;
    return logoutStatus;
}

- (void) setCurrentCustomer:(Customer *)customer {
	if (sessionInfo != nil) {
		[sessionInfo setCurrentCustomer:customer];
	}
}

- (Customer *)currentCustomer {
	if (sessionInfo == nil) {
		return nil;
	}
	return [sessionInfo currentCustomer];
}

- (void) setCurrentOrder:(Order *)order {
	if (sessionInfo != nil) {
		[sessionInfo setCurrentOrder:order];
	}
}

- (Order *)currentOrder {
	if (sessionInfo == nil) {
		return nil;
	}
	return [sessionInfo currentOrder];
}

#pragma mark -
#pragma mark Customer Management
-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber {
    return [posService lookupCustomerByPhone:phoneNumber withSession:sessionInfo];
}

-(void) newCustomer:(Customer *)customer {
    [posService newCustomer:customer withSession:self.sessionInfo];
}

-(void) updateCustomer:(Customer *)customer {
    [posService updateCustomer:customer withSession:self.sessionInfo];
}

#pragma mark -
#pragma mark Order Management
-(void) newOrder:(Order *)order {
    // Ensure to use the current customer
    if (order) {
        order.customer = [self currentCustomer];
    }
    
    [posService newOrder:order withSession:sessionInfo];
}

#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku {
    return [inventoryService lookupProductItem:itemSku withSession:sessionInfo];
}

-(BOOL) isProductItemAvailable: (NSString *) itemId forQuantity: (NSDecimal *) quantity {
    return YES;
}

@end
