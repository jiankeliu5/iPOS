//
//  iPosFacadeWithMocksTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 2/15/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPosFacadeWithMocksTestCase.h"
#import "iPOSServiceMock.h"
#import "InventoryServiceMock.h"

@implementation iPosFacadeWithMocksTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application
#pragma mark Setup/TearDown
- (void) setUp {
    if (facade == nil) {
        facade = [iPOSFacade sharedInstance];
        facade.posService = [[[iPOSServiceMock alloc] init] autorelease];
        facade.inventoryService = [[[InventoryServiceMock alloc] init] autorelease];  
    }  
}

- (void) testPosFacadeLogin {

    // Ensure on the facade the mock iPOSService is set    
    BOOL loginResult = [facade login:@"test" password:@"password"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");    
}

- (void) testPosFacadeLogout {
    // Ensure on the facade the mock iPOSService is set
    BOOL loginResult = [facade login:@"test" password:@"password"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    // Test the logout
   // STAssertTrue([facade logout], @"I expected the logout result to be true :-(");
    
}

#pragma mark -
#pragma mark Customer Service Mock Tests
- (void) testLookupCustomerByName {
    NSArray *custList = [facade lookupCustomerByName:@"test"];
                         
    STAssertTrue([custList count] == 2, @"Expected the count list to be 2 but was %d", [custList count]);
}
                         
-(void) testLookupCustomerFound {
    Customer *customer = [facade lookupCustomerByPhone:@"612-807-6120"];
    
    STAssertNotNil(customer, @"Expected customer to be nil");
    STAssertEquals(customer.firstName, @"Torey", @"expected First Name to be Torey.");
    STAssertEquals(customer.lastName, @"Lomenda", @"expected Last Name to be Lomenda.");
    STAssertEquals(customer.phoneNumber, @"612-807-6120", @"expected phone number to be 612-807-6120.");
}

-(void) testLookupCustomerNotFound {
    Customer *customer = [facade lookupCustomerByPhone:@"555-555-5555"];
    STAssertNil(customer, @"Expected customer to be nil");

}

-(void) testNewCustomer {
    Customer *newCustomer = [[[Customer alloc] init] autorelease];
    
    newCustomer.firstName = @"Torey";
    newCustomer.lastName = @"Lomenda";
    newCustomer.phoneNumber = @"333-333-3333";
    newCustomer.address = [[[Address alloc] init] autorelease];
    newCustomer.address.zipPostalCode = @"55555";
    
    [facade newCustomer:newCustomer];
    
    STAssertNotNil(newCustomer.customerId, @"Expected customerId to have a value");}

-(void) testNewCustomerWithError {
    Customer *newCustomer = [[[Customer alloc] init] autorelease];
    
    newCustomer.customerId = [NSNumber numberWithInt:1414];
    
    [facade newCustomer:newCustomer];
    
    STAssertTrue ([newCustomer.errorList count] == 2, @"Expected 2 errors");
}

-(void) testUpdateCustomer {
    Customer *newCustomer = [[[Customer alloc] init] autorelease];
    
    newCustomer.customerId = [NSNumber numberWithInt:1414];
    newCustomer.emailAddress = @"test@email.com";
    
    [facade updateCustomer:newCustomer];
    
    STAssertTrue ([newCustomer.errorList count] == 0, @"Expected 0 errors");
}



#pragma mark -
#pragma mark Item Service Mock Tests
- (void) testPosFacadeLookupProductItem {
    
    ProductItem *productItem = [facade lookupProductItem:@"440915"];
    
    STAssertEquals([productItem.itemId intValue], 283186, @"I expected this to be equal to 283186");
    STAssertEquals([productItem.store.storeId intValue], 1200, @"I expected this to be equal to 1200");
    STAssertEquals(productItem.description, @"Driftwood Hon. Martel", @"I expected this to be equal");
    STAssertTrue([productItem.distributionCenterList count] == 2, @"Expected 2 Distribution Centers");
    STAssertEquals([((DistributionCenter *) [productItem.distributionCenterList objectAtIndex:0]).dcId intValue], 801, @"Expected DC Id to be 801");
    STAssertEquals([((DistributionCenter *) [productItem.distributionCenterList objectAtIndex:1]).dcId intValue], 806, @"Expected DC Id to be 806");
}

#endif // all code under test must be linked into the Unit Test bundle


@end
