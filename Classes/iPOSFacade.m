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

@synthesize posService, inventoryService;

#pragma mark Singleton Initializer
+ (iPOSFacade *) sharedInstance {
    if (facade == NULL) {
        facade = [[super allocWithZone:NULL] init];
#ifdef TARGET_IPHONE_SIMULATOR
        facade.posService = [[[iPOSServiceMock alloc] init] autorelease];
        facade.inventoryService = [[[InventoryServiceMock alloc] init] autorelease];
#else
        facade.posService = [[[iPOSServiceImpl alloc] init] autorelease];
        facade.inventoryService = [[[InventoryServiceImpl alloc] init] autorelease];    
#endif
    } 
    
    return facade;
    
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];}


@end
