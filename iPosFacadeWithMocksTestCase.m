//
//  iPosFacadeWithMocksTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 2/15/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPosFacadeWithMocksTestCase.h"
#import "iPosFacade.h"
#import "iPOSServiceMock.h"
#import "InventoryServiceMock.h"

@implementation iPosFacadeWithMocksTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testPosFacadeLogin {

    // Ensure on the facade the mock iPOSService is set
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    facade.posService = [[[iPOSServiceMock alloc] init] retain];
    
    BOOL loginResult = [facade login:@"test" password:@"password"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
}

- (void) testPosFacadeLogout {
    
    // Ensure on the facade the mock iPOSService is set
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    facade.posService = [[[iPOSServiceMock alloc] init] retain];
    
    BOOL loginResult = [facade login:@"test" password:@"password"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    // Test the logout
    STAssertTrue([facade logout], @"I expected the logout result to be true :-(");
    
}

- (void) testPosFacadeLookupProductItem {
    // Ensure on the facade the mock iPOSService is set
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    facade.inventoryService = [[[InventoryServiceMock alloc] init] retain];
    
    ProductItem *productItem = [facade lookupProductItem:@"440915"];
    
    STAssertEquals([productItem.itemId intValue], 283186, @"I expected this to be equal to 283186");
    STAssertEquals([productItem.storeId intValue], 1200, @"I expected this to be equal to 283186");
    STAssertEquals(productItem.description, @"Driftwood Hon. Martel", @"I expected this to be equal to 283186");
}

#endif // all code under test must be linked into the Unit Test bundle


@end
