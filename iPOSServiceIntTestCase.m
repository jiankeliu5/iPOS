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

#pragma mark -
#pragma mark Session Mgmt Tests
- (void) testPosFacadeLogin {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"test"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
}

- (void) testPosFacadeLogout {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];

    
    BOOL loginResult = [facade login:@"123" password:@"test"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    // Test the logout
    STAssertTrue([facade logout], @"I expected the logout result to be true :-(");
    
}

#pragma mark -
#pragma mark Item Mgmt Tests
- (void) testPosFacadeLookupProductItem {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((InventoryServiceImpl *) facade.inventoryService) setToDemoMode];
    
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    ProductItem *productItem = [facade lookupProductItem:@"440915"];
    
    STAssertNotNil(productItem, @"Should not be nil");
    STAssertEquals([productItem.itemId intValue], 283186, @"I expected this to be equal to 283186");
    STAssertEquals([productItem.store.storeId intValue], 1200, @"I expected this to be equal to 1200");
    STAssertTrue([productItem.description isEqualToString:@"Driftwood Hon. Martel"], @"I expected this to be equal to Driftwood Hon. Martel");
    
    STAssertTrue([productItem.distributionCenterList count] == 3, @"Expected count to be 3");
}

#pragma mark -
#pragma mark Customer Mgmt Tests
- (void) testPosFacadeLookupCustomer {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    // We know that phone number 6127461580 - The OPI Office will be found
    Customer *customer = [facade lookupCustomerByPhone:@"6127461580"];
    
    STAssertNotNil(customer, @"Customer should be found");
    STAssertNotNil(customer.address, @"Address should not be nil");
    STAssertNil(customer.errorList, @"There should be no errors returned.");
    
    STAssertTrue([customer.firstName isEqualToString:@"Jimmy"], @"Expected first name to be Jimmy");
    STAssertTrue([customer.lastName isEqualToString:@"Testing"], @"Expected last name to be Testing");
    STAssertTrue([customer.emailAddress isEqualToString:@"test@test.blackhole.com"], @"Expected email to be test@test.blackhole.com");
    STAssertTrue([customer.phoneNumber isEqualToString:@"6127461580"], @"Expected phone number to be 6127461580");
    
    STAssertTrue([customer.address.line1 isEqualToString:@"Butler Square Suite 302A"], @"Wrong address line 1");
    STAssertTrue([customer.address.line2 isEqualToString:@"100 N 6th Street"], @"Wrong address line 2");
    STAssertTrue([customer.address.city isEqualToString:@"Minneapolis"], @"Wrong city");
    STAssertTrue([customer.address.stateProv isEqualToString:@"MN"], @"Wrong state");
    STAssertTrue([customer.address.zipPostalCode isEqualToString:@"55403"], @"Wrong zip");
    
}

- (void) testPosFacadeLookupCustomerNotFound {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    // We know that phone number 1111111111 will not be found
    Customer *customer = [facade lookupCustomerByPhone:@"1111111111"];
    
    STAssertNil(customer, @"Should be nil when not found");
    
}

- (void) testPosFacadeNewCustomer {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];

    // Create a new customer (first, last, email, phone, zip)
    Customer *newCustomer = [[[Customer alloc] init] autorelease];
    newCustomer.firstName = @"Torey";
    newCustomer.lastName = @"Lomenda";
    newCustomer.emailAddress = @"email@email.com";
    newCustomer.phoneNumber = @"9524444444";
    newCustomer.address = [[[Address alloc] init] autorelease];
    newCustomer.address.zipPostalCode = @"55044";
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    [facade newCustomer:newCustomer];
    
    // Verify that it now has a customer ID
    STAssertNotNil(newCustomer.customerId, @"Expected a customerId");
    STAssertEquals([newCustomer.customerId intValue], 4444, @"Expected the Customer ID to be 4444");
    
    
    
}

- (void) testPosFacadeNewCustomerWithInvalidPhone {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    // Create a new customer (first, last, email, phone, zip)
    Customer *newCustomer = [[[Customer alloc] init] autorelease];
    newCustomer.firstName = @"Torey";
    newCustomer.lastName = @"Lomenda";
    newCustomer.emailAddress = @"email@email.com";
    newCustomer.phoneNumber = @"1111111111";
    newCustomer.address = [[[Address alloc] init] autorelease];
    newCustomer.address.zipPostalCode = @"55044";
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    [facade newCustomer:newCustomer];
    
    // Verify that it now has a customer ID
    STAssertTrue([newCustomer.errorList count] > 0, @"Expected an error");
    Error *error = (Error *) [newCustomer.errorList lastObject];
    STAssertTrue([error.message isEqualToString:@"Incorrect phone number"], @"Expected an error");
}

- (void) testPosFacadeUpdateCustomer {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    // Create a new customer (first, last, email, phone, zip)
    Customer *updateCustomer = [[[Customer alloc] init] autorelease];
    updateCustomer.customerId = [NSNumber numberWithInt:4444];
    updateCustomer.emailAddress = @"testThis@email.com";
    updateCustomer.address = [[[Address alloc] init] autorelease];
    updateCustomer.address.city = @"Lakeville";
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    [facade updateCustomer:updateCustomer];
    
    // Verify that it now has a customer ID
    STAssertTrue([updateCustomer.errorList count] == 0, @"Expected no error");
    STAssertTrue([updateCustomer.firstName isEqualToString:@"Joe"], @"Wrong first name");
    STAssertTrue([updateCustomer.lastName isEqualToString:@"Lomenda"], @"Wrong last name");
    STAssertTrue([updateCustomer.phoneNumber isEqualToString:@"6127461580"], @"Wrong phone");
    STAssertTrue([updateCustomer.emailAddress isEqualToString:@"testThis@email.com"], @"Wrong email address");
    
}
- (void) testPosFacadeUpdateCustomerNoCustomerID {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    // Create a new customer (first, last, email, phone, zip)
    Customer *updateCustomer = [[[Customer alloc] init] autorelease];
    
    updateCustomer.emailAddress = @"testThis@email.com";
    
    // We have to login first
    [facade login:@"123" password:@"test"];
    
    [facade updateCustomer:updateCustomer];
    
    // Verify that it now has a customer ID
    STAssertTrue([updateCustomer.errorList count] > 0, @"Expected an error");
    Error *error = (Error *) [updateCustomer.errorList lastObject];
    STAssertTrue([error.message isEqualToString:@"Invalid Customer ID"], @"Expected an error");
}


#endif // all code under test must be linked into the Integration Test bundle

@end
