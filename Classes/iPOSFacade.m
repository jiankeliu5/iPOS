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
    
    #if TARGET_IPHONE_SIMULATOR
    self.posService = [[[iPOSServiceMock alloc] init] retain];
    self.inventoryService = [[[InventoryServiceMock alloc] init] retain];
    #else
    self.posService = [[[iPOSServiceImpl alloc] init] retain];
    self.inventoryService = [[[InventoryServiceImpl alloc] init] retain];    
    #endif
    
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

-(BOOL) logout {
    return [self.posService logout:self.sessionInfo];
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
