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

#import "PaymentHistory.h"

@implementation OrderHistoryTestCase

- (void)testOrderSummary {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.orderHistoryService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    NSArray *result = [facade lookupOrderByPhoneNumber:@"6127461580"];
    
    STAssertTrue([result count ] == 3, @"Incorrect number of previous orders");
    
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
    
    PaymentHistory *paymentHistory = [facade getPaymentHistoryForOrderid:[NSNumber numberWithInt:308422]];
    
    STAssertNotNil(paymentHistory, @"Didn't get any payment history");
}

-(void) testOrderHistoryByOrderID {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.orderHistoryService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    Order *result = [facade lookupOrderByOrderId:[NSNumber numberWithInt:308422]];
    
    STAssertNotNil(result, @"Didn't get any payment history");
    
    STAssertTrue([result.orderId compare: [NSNumber numberWithInt: 3834770]] == NSOrderedSame,@"Wrong order id");
    
    STAssertNotNil(result.customer, @"Customer should not be empty");
}


@end
