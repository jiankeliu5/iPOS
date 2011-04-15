//
//  CustomerOxmTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "Customer.h"

@interface CustomerOxmTestCase : SenTestCase

-(void) testCustomerFromXml;
-(void) testXmlFromCustomer;
-(void) testXmlFromCustomerWithId;

@end

@implementation CustomerOxmTestCase

-(void) testCustomerFromXml {
    NSString *xmlString = @""
    "<CustomerClass><Address><CustomerAddress><Address1></Address1><Address2></Address2><City></City><State></State><Zip>55044</Zip></CustomerAddress></Address>"
    "<CustomerID>14</CustomerID><CustomerTypeID>1</CustomerTypeID><PriceLevelID>1</PriceLevelID>"
    "<CustomerName>Lomenda, Torey</CustomerName><Email>email@email.com</Email><Phone1>9524444444</Phone1><StoreID>1200</StoreID></CustomerClass>";
    
    Customer *customer = [Customer fromXml:xmlString];
    
    STAssertNotNil(customer, @"Expected customer to not be nil");
    STAssertTrue([customer.lastName isEqualToString:@"Lomenda"], @"Last name should be Lomenda");
    STAssertTrue([customer.firstName isEqualToString:@"Torey"], @"First name should be Lomenda");
    STAssertTrue([customer.customerId isEqualToNumber:[NSNumber numberWithInt:14]], @"ID should be 14");
    STAssertTrue([customer.customerTypeId isEqualToNumber:[NSNumber numberWithInt:1]], @"ID should be 1");
    STAssertTrue([customer.priceLevelId isEqualToNumber:[NSNumber numberWithInt:1]], @"ID should be 1");
    STAssertTrue([customer.store.storeId isEqualToNumber:[NSNumber numberWithInt:1200]], @"Store ID should be 1200");
    STAssertTrue([customer.phoneNumber isEqualToString:@"9524444444"], @"Phone should be 9524444444");
}

-(void) testXmlFromCustomer {
    Customer *customer = [[[Customer alloc] init] autorelease];
    customer.firstName = @"Torey";
    customer.lastName = @"Lomenda";
    customer.emailAddress = @"email@email.com";
    customer.phoneNumber = @"9524444444";
    customer.address = [[[Address alloc] init] autorelease];
    customer.address.zipPostalCode = @"55044";
    customer.store = [[[Store alloc] init] autorelease];
    customer.store.storeId = [NSNumber numberWithInt:1200];
    
    NSString *customerXml = [customer toXml];
    
    STAssertTrue([customerXml isEqualToString:@""
                  "<CustomerClass><Address><CustomerAddress><Address1></Address1><Address2></Address2><City></City><State></State><Zip>55044</Zip></CustomerAddress></Address>"
                  "<CustomerName>Lomenda, Torey</CustomerName><Email>email@email.com</Email><Phone1>9524444444</Phone1><StoreID>1200</StoreID></CustomerClass>"], customerXml);
    
}

-(void) testXmlFromCustomerWithId {
    Customer *customer = [[[Customer alloc] init] autorelease];
    customer.customerId = [NSNumber numberWithInt:4444];
    customer.firstName = @"Torey";
    customer.lastName = @"Lomenda";
    customer.emailAddress = @"email@email.com";
    customer.phoneNumber = @"9524444444";
    customer.address = [[[Address alloc] init] autorelease];
    customer.address.zipPostalCode = @"55044";
    customer.store = [[[Store alloc] init] autorelease];
    customer.store.storeId = [NSNumber numberWithInt:1200];
    
    NSString *customerXml = [customer toXml];
    
    STAssertTrue([customerXml isEqualToString:@""
                  "<CustomerClass><Address><CustomerAddress><Address1></Address1><Address2></Address2><City></City><State></State><Zip>55044</Zip></CustomerAddress></Address>"
                  "<CustomerID>4444</CustomerID><CustomerName>Lomenda, Torey</CustomerName><Email>email@email.com</Email></CustomerClass>"], customerXml);
    
}


@end
