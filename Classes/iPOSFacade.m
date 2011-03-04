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
    self.sessionInfo = [[self.posService login:username withPassword:password] retain];
    
    if (self.sessionInfo != nil) {
        return TRUE;
    }
    
	return FALSE;
}

-(BOOL) verifySession:(NSString *)passwordToVerify {
    return [self.posService verifySession:self.sessionInfo withPassword:passwordToVerify];
}

-(BOOL) logout {
	BOOL logoutStatus = [self.posService logout:self.sessionInfo];
	[self.sessionInfo release];
	self.sessionInfo = nil;
    return logoutStatus;
}

#pragma mark -
#pragma mark Customer Management
-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber {
    return [self.posService lookupCustomerByPhone:phoneNumber withSession:self.sessionInfo];
}

-(void) newCustomer:(Customer *)customer {
    [self.posService newCustomer:customer withSession:self.sessionInfo];
}

-(void) updateCustomer:(Customer *)customer {
    [self.posService updateCustomer:customer withSession:self.sessionInfo];
}

#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku {
    return [self.inventoryService lookupProductItem:itemSku withSession:self.sessionInfo];
}

-(BOOL) isProductItemAvailable: (NSString *) itemId forQuantity: (NSDecimal *) quantity {
    return YES;
}

@end
