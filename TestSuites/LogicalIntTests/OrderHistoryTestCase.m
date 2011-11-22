//
//  OrderHistoryTestCase.m
//  iPOS
//
//  Created by Dan C on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderHistoryTestCase.h"
#import "iPOSFacade.h"
#import "PreviousOrder.h"


@implementation OrderHistoryTestCase

- (void)testOrderSummary {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.orderHistoryService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    NSArray *result = [facade lookupOrderByPhoneNumber:@"6127461580"];
    
    STAssertTrue([[NSNumber numberWithInt: [result count]] compare: [NSNumber numberWithInt: 5]] == NSOrderedSame, @"Incorrect number of previous orders");
    
    PreviousOrder *prevOrder = [result objectAtIndex:0];
    
    STAssertNotNil(prevOrder, @"Order doesn't exist");
    
    PreviousOrder *prevOrderTwo = [result objectAtIndex:1];
    
    STAssertNotNil(prevOrderTwo, @"Order doesn't exist");
    
}

-(void) testOrderPaymentHistory
{
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.orderHistoryService) setToDemoMode];
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    NSArray *paymentHistory = [facade getPaymentHistoryForOrderid:[NSNumber numberWithInt:3084229]];
    
    STAssertNotNil(paymentHistory, @"Didn't get any payment history");
    
    STAssertTrue([[NSNumber numberWithUnsignedInt:[paymentHistory count]] compare: [NSNumber numberWithInt: 11 ]]  == NSOrderedSame, @"Size of array is %u", [paymentHistory count]);
    
    STAssertTrue([[paymentHistory objectAtIndex:0] isKindOfClass:[CreditCardPayment class]], @"Expected Payment of Type Credit Card");
    
    CreditCardPayment *cc = [paymentHistory objectAtIndex:0];
    
    STAssertNotNil(cc.paymentRefId, @"tRouteD should not be nil");
   
}

-(void) testOrderPaymentHistoryMutiplePayments
{
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.orderHistoryService) setToDemoMode];
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    NSArray *paymentHistory = [facade getPaymentHistoryForOrderid:[NSNumber numberWithInt:3074226]];
    
    STAssertNotNil(paymentHistory, @"Didn't get any payment history");
    
    STAssertTrue([[NSNumber numberWithUnsignedInt:[paymentHistory count]] compare: [NSNumber numberWithInt: 2 ]]  == NSOrderedSame, @"Expected two payments");
}

-(void) testOrderHistoryByOrderID {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.orderHistoryService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    Order *result = [facade lookupOrderByOrderId:[NSNumber numberWithInt:3084226]];
    
    STAssertNotNil(result, @"Didn't get an order");
    
    STAssertTrue([result.orderId compare: [NSNumber numberWithInt: 3084226]] == NSOrderedSame,@"Wrong order id");
    
    Customer *customer = result.customer;
    
    STAssertNotNil(customer, @"Customer should not be empty");
    
    STAssertFalse(result.isNewOrder, @"The order should not be new");
    
    
    STAssertNotNil(customer.address.zipPostalCode, @"Zip code required");
}


@end
