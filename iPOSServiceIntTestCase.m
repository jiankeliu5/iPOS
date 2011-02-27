//
//  iPOSServiceIntTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSServiceIntTestCase.h"
#import "SessionInfo.h"
#import "iPOSFacade.h"
#import "iPosServiceImpl.h"
#import "InventoryServiceImpl.h"
#import "ProductItem.h"

@implementation iPOSServiceIntTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testPosFacadeLogin {
    
    // Ensure on the facade the mock iPOSService is set
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    facade.posService = [[[iPOSServiceImpl alloc] init] autorelease];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"test"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
}

- (void) testPosFacadeLogout {
    
    // Ensure on the facade the mock iPOSService is set
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    facade.posService = [[[iPOSServiceImpl alloc] init] autorelease];
    
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];

    
    BOOL loginResult = [facade login:@"123" password:@"test"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    // Test the logout
    STAssertTrue([facade logout], @"I expected the logout result to be true :-(");
    
}

- (void) testPosFacadeLookupProductItem {
    // Ensure on the facade the mock iPOSService is set
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    facade.posService = [[[iPOSServiceImpl alloc] init] retain];
    facade.inventoryService = [[[InventoryServiceImpl alloc] init] retain];
    
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((InventoryServiceImpl *) facade.inventoryService) setToDemoMode];
    
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    ProductItem *productItem = [facade lookupProductItem:@"440915"];
    
    STAssertNotNil(productItem, @"Should not be nil");
    STAssertEquals([productItem.itemId intValue], 283186, @"I expected this to be equal to 283186");
    STAssertEquals([productItem.storeId intValue], 1200, @"I expected this to be equal to 1200");
    STAssertTrue([productItem.description isEqualToString:@"Driftwood Hon. Martel"], @"I expected this to be equal to Driftwood Hon. Martel");
    
    STAssertTrue([productItem.distributionCenterList count] == 3, @"Expected count to be 3");
    
    
}

#endif // all code under test must be linked into the Integration Test bundle


@end
