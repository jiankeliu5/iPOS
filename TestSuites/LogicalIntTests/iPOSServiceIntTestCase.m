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
#import "Order.h"
#import "ProductItem.h"

@interface iPOSServiceIntTestCase()
    -(Order *) orderForTest;
@end


@implementation iPOSServiceIntTestCase

- (void) testPosFacadeLogin {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
}

- (void) testPosFacadeLogout {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];

    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    
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
    [facade login:@"123" password:@"456"];
    
    ProductItem *productItem = [facade lookupProductItem:@"440915"];
    
    STAssertNotNil(productItem, @"Should not be nil");
    STAssertEquals([productItem.itemId intValue], 283186, @"I expected this to be equal to 283186");
    STAssertEquals([productItem.store.storeId intValue], 1200, @"I expected this to be equal to 1200");
    STAssertTrue([productItem.description isEqualToString:@"Driftwood Hon. Martel"], @"I expected this to be equal to Driftwood Hon. Martel");
    
    STAssertTrue([productItem.distributionCenterList count] == 3, @"Expected count to be 3");
}

- (void) testPosFacadeLookupProductItemByName {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((InventoryServiceImpl *) facade.inventoryService) setToDemoMode];
    
    [facade login:@"123" password:@"456"];
    
    NSArray *itemList = [facade lookupProductItemByName: @"match"];
    
    STAssertNotNil(itemList, @"Expected Item List to not be nil");
    STAssertTrue([itemList count] == 2, @"Expected items matched to be 2.");
    
    STAssertTrue([((ProductItem *) [itemList objectAtIndex:0]).sku isEqualToString: @"689751"], @"Expected sku to be equal");
    STAssertTrue([((ProductItem *) [itemList objectAtIndex:1]).sku isEqualToString: @"440915"], @"Expected sku to be equal");
}

#pragma mark -
#pragma mark Customer Mgmt Tests
- (void) testPosFacadeLookupCustomer {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    // We have to login first
    [facade login:@"123" password:@"456"];
    
    // We know that phone number 6127461580 - The OPI Office will be found
    Customer *customer = [facade lookupCustomerByPhone:@"6127461580"];
    
    STAssertNotNil(customer, @"Customer should be found");
    STAssertNotNil(customer.address, @"Address should not be nil");
    STAssertNil(customer.errorList, @"There should be no errors returned.");
    
    STAssertTrue([customer.customerId isEqualToNumber: [NSNumber numberWithInt:1234]], @"Expected Customer ID to be 1234");
    STAssertTrue([customer.customerType isEqualToString:@"Retail"], @"Expected Customer Type to be Retail");
    STAssertTrue([customer.customerTypeId isEqualToNumber: [NSNumber numberWithInt:1]], @"Expected Customer Type ID to be 1");
    
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
    [facade login:@"123" password:@"456"];
    
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
    [facade login:@"123" password:@"456"];
    
    [facade newCustomer:newCustomer];
    
    // Verify that it now has a customer ID
    STAssertTrue([newCustomer.errorList count] == 0, @"Expected no error");
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
    [facade login:@"123" password:@"456"];
    
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
    updateCustomer.firstName = @"Joe";
    updateCustomer.lastName = @"Lomenda";
    updateCustomer.phoneNumber = @"6127461580";
    updateCustomer.emailAddress = @"testThis@email.com";
    updateCustomer.address = [[[Address alloc] init] autorelease];
    updateCustomer.address.city = @"Lakeville";
    updateCustomer.address.zipPostalCode = @"55044";
    
    // We have to login first
    [facade login:@"123" password:@"456"];
    
    [facade updateCustomer:updateCustomer];
    
    // Verify that it now has a customer ID
     Error *error = (Error *) [updateCustomer.errorList lastObject];
    STAssertTrue([updateCustomer.errorList count] == 0, error.message);
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
    [facade login:@"123" password:@"456"];
    
    [facade updateCustomer:updateCustomer];
    
    // Verify an error for no customer id
    STAssertTrue([updateCustomer.errorList count] == 4, @"Expected an error");
    Error *error = (Error *) [updateCustomer.errorList objectAtIndex:0];
    STAssertTrue([error.message isEqualToString:@"Invalid Customer id."], @"Expected an error");
}

#pragma mark -
#pragma mark Order Mgmt Tests
- (void) testPosFacadeNewQuote {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    Order *newOrder = [self orderForTest];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    [facade login:@"123" password:@"456"];
    
     STAssertNil(newOrder.orderId, @"Expected the order id to be nil");
     
    [facade newQuote:newOrder];
    
    // Verify that it now has a customer ID
    STAssertNil(newOrder.errorList, @"Expected no errors");
    STAssertEquals([newOrder.orderId intValue], 1234, @"Expected value of 1234");
    
}

- (void) testPosFacadeNewOrder {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    Order *newOrder = [self orderForTest];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    
    [facade login:@"123" password:@"456"];
    
    // Set the order type to an invalid order type (for testing)
    newOrder.orderTypeId = [NSNumber numberWithInt:10];
    
    STAssertNil(newOrder.orderId, @"Expected the order id to be nil");
    
    newOrder.orderTypeId = [NSNumber numberWithInt:5];
    [facade newOrder:newOrder];
    
    // Verify that it now has a customer ID
    STAssertTrue([newOrder.errorList count] == 0, @"Expected an error");
}

-(Order *) orderForTest {
    Order *order = [[[Order alloc] init] autorelease];
    Customer *customer = [[[Customer alloc] init] autorelease];
    Store *store = [[[Store alloc] init] autorelease];
    ProductItem *item= [[[ProductItem alloc] init] autorelease];
    
    // Build the store
    store.storeId = [NSNumber numberWithInt:1234];
    
    // Build the item
    item.store = store;
    item.itemId = [NSNumber numberWithInt:1414];
    item.sku = @"232323";
    item.description = @"Some product";
    item.defaultToBox = YES;
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    item.statusCode = @"S";
    item.typeId = [NSNumber numberWithInt:1];
    item.piecesPerBox = [NSNumber numberWithInt: 12];
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.retailPrice = [NSDecimalNumber decimalNumberWithString:@"3.75"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"2.70"]; 
    item.stockingCode = @"S";
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    
    
    // Build the customer
    customer.customerId = [NSNumber numberWithInt:1414];
    customer.taxExempt = NO;
    customer.customerTypeId = [NSNumber numberWithInt:1];
    customer.address = [[[Address alloc] init] autorelease];
    customer.address.zipPostalCode = @"55044";
    
    // Build the order
    order.salesPersonEmployeeId = [NSNumber numberWithInt:1111];
    order.store = store;
    order.customer = customer;
    order.orderTypeId = [NSNumber numberWithInt:1];
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"24.5"]];
    
    return order;
}

@end
