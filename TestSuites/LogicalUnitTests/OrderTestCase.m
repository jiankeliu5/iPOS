//
//  OrderTestCase.m
//  iPOS
//
//  Created by Dan C on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderTestCase.h"
#import "OrderItem.h"
#import "Order.h"
#import "PaymentService.h"
#import "iPOSFacade.h"

@implementation OrderTestCase

- (void)testProfitMarginCalculation{
    
    Order *order = [[Order alloc] init];
    
    ProductItem *item = [[ProductItem alloc] init];
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = @"440915";
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"8.99"];
    item.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.90"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"2.0"]];
    
    
    ProductItem *itemTwo = [[ProductItem alloc] init];
    itemTwo.itemId = [NSNumber numberWithInt:283186];
    itemTwo.sku = @"440915";
    itemTwo.description = @"Driftwood Hon. Martel";
    itemTwo.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    itemTwo.statusCode = @"S";
    itemTwo.type = @"Travertine";
    itemTwo.typeId = [NSNumber numberWithInt: 26];
    itemTwo.binLocation = @"TR0520";
    itemTwo.stockingCode = @"S";
    itemTwo.defaultToBox = NO;
    itemTwo.primaryUnitOfMeasure = @"EA";
    itemTwo.secondaryUnitOfMeasure = @"EA";
    itemTwo.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    itemTwo.priceGroupId = [NSNumber numberWithInt:123];
    itemTwo.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    itemTwo.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"12.99"]; 
    itemTwo.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.80"];
    itemTwo.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    itemTwo.taxExempt = NO;
    [order addItemToOrder:itemTwo withQuantity:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"76.95"];
    
    NSDecimalNumber *result = [order calculateProfitMargin];
    
    STAssertTrue([result compare:expected] == NSOrderedSame, @"Calculation is incorrect");
}

-(void) testPreviousOrderCalcBalanceDueNoChange 
{
   Order *order = [[Order alloc] init];
    order.orderId = [NSNumber numberWithInt:1];
    ProductItem *item = [[ProductItem alloc] init];
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = @"440915";
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"8.99"];
    item.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.90"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"2.0"]];
    
    
    ProductItem *itemTwo = [[ProductItem alloc] init];
    itemTwo.itemId = [NSNumber numberWithInt:283186];
    itemTwo.sku = @"440915";
    itemTwo.description = @"Driftwood Hon. Martel";
    itemTwo.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    itemTwo.statusCode = @"S";
    itemTwo.type = @"Travertine";
    itemTwo.typeId = [NSNumber numberWithInt: 26];
    itemTwo.binLocation = @"TR0520";
    itemTwo.stockingCode = @"S";
    itemTwo.defaultToBox = NO;
    itemTwo.primaryUnitOfMeasure = @"EA";
    itemTwo.secondaryUnitOfMeasure = @"EA";
    itemTwo.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    itemTwo.priceGroupId = [NSNumber numberWithInt:123];
    itemTwo.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    itemTwo.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"12.99"]; 
    itemTwo.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.80"];
    itemTwo.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    itemTwo.taxExempt = NO;
    
    [order addItemToOrder:itemTwo withQuantity:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    NSArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    [orderItem setStatusToClosed];
    
    OrderItem *orderItemTwo = [orderItems objectAtIndex:1];
    [orderItemTwo setStatusToClosed ];
    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"49.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.paymentRefId = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    TenderDecision decision = [order isRefundEligble];
    
    STAssertTrue(decision == NOCHANGE, @"No change to payment was expected");
}

-(void) testPreviousOrderCalcBalanceDueRefund   
{
    Order *order = [[Order alloc] init];
    order.orderId = [NSNumber numberWithInt:1];
    ProductItem *item = [[ProductItem alloc] init];
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = @"440915";
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"8.99"];
    item.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.90"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"2.0"]];
    
    
    ProductItem *itemTwo = [[ProductItem alloc] init];
    itemTwo.itemId = [NSNumber numberWithInt:283186];
    itemTwo.sku = @"440915";
    itemTwo.description = @"Driftwood Hon. Martel";
    itemTwo.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    itemTwo.statusCode = @"S";
    itemTwo.type = @"Travertine";
    itemTwo.typeId = [NSNumber numberWithInt: 26];
    itemTwo.binLocation = @"TR0520";
    itemTwo.stockingCode = @"S";
    itemTwo.defaultToBox = NO;
    itemTwo.primaryUnitOfMeasure = @"EA";
    itemTwo.secondaryUnitOfMeasure = @"EA";
    itemTwo.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    itemTwo.priceGroupId = [NSNumber numberWithInt:123];
    itemTwo.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    itemTwo.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"12.99"]; 
    itemTwo.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.80"];
    itemTwo.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    itemTwo.taxExempt = NO;
    
    [order addItemToOrder:itemTwo withQuantity:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    NSArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    [orderItem setStatusToClosed];
    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"49.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.paymentRefId = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    // Remove one of the order items to trigger a refund
    [order removeItemFromOrder:orderItem];
    
    TenderDecision decision = [order isRefundEligble];
    
    STAssertTrue(decision == REFUND, @"A refund was expected");
}

-(void) testPreviousOrderCalcBalanceDuePayMore   
{
    Order *order = [[Order alloc] init];
    order.orderId = [NSNumber numberWithInt:1];
    ProductItem *item = [[ProductItem alloc] init];
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = @"440915";
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"8.99"];
    item.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.90"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"2.0"]];
    
    
    ProductItem *itemTwo = [[ProductItem alloc] init];
    itemTwo.itemId = [NSNumber numberWithInt:283186];
    itemTwo.sku = @"440915";
    itemTwo.description = @"Driftwood Hon. Martel";
    itemTwo.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    itemTwo.statusCode = @"S";
    itemTwo.type = @"Travertine";
    itemTwo.typeId = [NSNumber numberWithInt: 26];
    itemTwo.binLocation = @"TR0520";
    itemTwo.stockingCode = @"S";
    itemTwo.defaultToBox = NO;
    itemTwo.primaryUnitOfMeasure = @"EA";
    itemTwo.secondaryUnitOfMeasure = @"EA";
    itemTwo.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    itemTwo.priceGroupId = [NSNumber numberWithInt:123];
    itemTwo.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    itemTwo.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"12.99"]; 
    itemTwo.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.80"];
    itemTwo.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    itemTwo.taxExempt = NO;
    
    [order addItemToOrder:itemTwo withQuantity:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    NSArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    [orderItem setStatusToClosed];
    
    OrderItem *orderItemTwo = [orderItems objectAtIndex:1];
    [orderItemTwo setStatusToClosed ];

    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"38.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.paymentRefId = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    TenderDecision decision = [order isRefundEligble];
    
    STAssertTrue(decision == TENDER, @"Payment was expected");
}

-(void) testcalculateBalanceDueWithoutPreviousPayments{
    
    Order *order = [[Order alloc] init];
    //order.orderId = [NSNumber numberWithInt:1];
    ProductItem *item = [[ProductItem alloc] init];
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = @"440915";
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"8.99"];
    item.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.90"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"2.0"]];
    
    
    ProductItem *itemTwo = [[ProductItem alloc] init];
    itemTwo.itemId = [NSNumber numberWithInt:283186];
    itemTwo.sku = @"440915";
    itemTwo.description = @"Driftwood Hon. Martel";
    itemTwo.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    itemTwo.statusCode = @"S";
    itemTwo.type = @"Travertine";
    itemTwo.typeId = [NSNumber numberWithInt: 26];
    itemTwo.binLocation = @"TR0520";
    itemTwo.stockingCode = @"S";
    itemTwo.defaultToBox = NO;
    itemTwo.primaryUnitOfMeasure = @"EA";
    itemTwo.secondaryUnitOfMeasure = @"EA";
    itemTwo.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    itemTwo.priceGroupId = [NSNumber numberWithInt:123];
    itemTwo.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    itemTwo.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"12.99"]; 
    itemTwo.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.80"];
    itemTwo.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    itemTwo.taxExempt = NO;
    
    [order addItemToOrder:itemTwo withQuantity:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    NSArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    [orderItem setStatusToClosed];
    
    OrderItem *orderItemTwo = [orderItems objectAtIndex:1];
    [orderItemTwo setStatusToClosed ];
    
    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    NSDecimalNumber *balance = [order calcBalanceDue];

    STAssertNotNil(balance, @"balance should not be nil");
    STAssertTrue([balance compare: [NSDecimalNumber decimalNumberWithString: @"49.249"]] == NSOrderedSame, @"Balance due should be the same");
    
}

-(void) testcalculateBalanceDueWithPreviousPayments{
    
    Order *order = [[Order alloc] init];
    order.orderId = [NSNumber numberWithInt:1];
    ProductItem *item = [[ProductItem alloc] init];
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = @"440915";
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"8.99"];
    item.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.90"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"2.0"]];
    
    
    ProductItem *itemTwo = [[ProductItem alloc] init];
    itemTwo.itemId = [NSNumber numberWithInt:283186];
    itemTwo.sku = @"440915";
    itemTwo.description = @"Driftwood Hon. Martel";
    itemTwo.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    itemTwo.statusCode = @"S";
    itemTwo.type = @"Travertine";
    itemTwo.typeId = [NSNumber numberWithInt: 26];
    itemTwo.binLocation = @"TR0520";
    itemTwo.stockingCode = @"S";
    itemTwo.defaultToBox = NO;
    itemTwo.primaryUnitOfMeasure = @"EA";
    itemTwo.secondaryUnitOfMeasure = @"EA";
    itemTwo.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    itemTwo.priceGroupId = [NSNumber numberWithInt:123];
    itemTwo.retailPricePrimary = [NSDecimalNumber decimalNumberWithString:@"10.99"];
    itemTwo.retailPriceSecondary = [NSDecimalNumber decimalNumberWithString:@"12.99"]; 
    itemTwo.standardCost = [NSDecimalNumber decimalNumberWithString:@"1.80"];
    itemTwo.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    itemTwo.taxExempt = NO;
    
    [order addItemToOrder:itemTwo withQuantity:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    NSArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    [orderItem setStatusToClosed];
    
    OrderItem *orderItemTwo = [orderItems objectAtIndex:1];
    [orderItemTwo setStatusToClosed ];
    
    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"38.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.paymentRefId = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    
    NSDecimalNumber *balanceDue = [order calcBalanceDue];
    
    
    STAssertTrue([balanceDue compare: [NSDecimalNumber zero]] == NSOrderedDescending, @"Balance Due should be greater than zero");
}

- (void) testRefundInfoForOrder {
    // Setup facade
    SessionInfo *session = [[[SessionInfo alloc] init] autorelease];
    session.storeId = [NSNumber numberWithInt:1200];
    
    [iPOSFacade sharedInstance].sessionInfo = session;
    
    // Add a number of payments to an order and fetch refund info
    Order *order = [[[Order alloc] init] autorelease];
    Store *store = [[[Store alloc] init] autorelease];
    
    store.storeId = [NSNumber numberWithInt:1200];
    order.store = store;
    
    // Add payments to the order (1 on acct, 2 same store cc, 2 diff store cc, 1 same store no ref, 1 diff store no token, 2 cash, 1 check, 1 paypal)
    AccountPayment *acctPayment1 = [[[AccountPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *sameStoreCC1 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *sameStoreCC2 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *sameStoreCC3 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *diffStoreCC1 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *diffStoreCC2 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *toCCT1 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CreditCardPayment *toCCT2 = [[[CreditCardPayment alloc] initWithOrder:order] autorelease];
    CashPayment *toPOS1 = [[[CashPayment alloc] initWithOrder:order] autorelease];
    CashPayment *toPOS2 = [[[CashPayment alloc] initWithOrder:order] autorelease];
    CheckPayment *toPOS3 = [[[CheckPayment alloc] initWithOrder:order] autorelease];
    PayPalPayment *toPOS4 = [[[PayPalPayment alloc] initWithOrder:order] autorelease];
    
    acctPayment1.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    
    sameStoreCC1.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    sameStoreCC1.storeId = store.storeId;
    sameStoreCC1.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    sameStoreCC1.paymentRefId = @"3";
    sameStoreCC1.lpToken = @"1111";
    sameStoreCC1.cardNumber = @"1111";
    
    sameStoreCC2.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    sameStoreCC2.storeId = store.storeId;
    sameStoreCC2.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    sameStoreCC2.paymentRefId = @"4";
    sameStoreCC2.lpToken = @"1111";
    sameStoreCC2.cardNumber = @"1111"; 
    
    sameStoreCC3.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    sameStoreCC3.storeId = store.storeId;
    sameStoreCC3.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    sameStoreCC3.paymentRefId = @"5";
    sameStoreCC3.lpToken = @"";
    sameStoreCC3.cardNumber = @""; 
    
    diffStoreCC1.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    diffStoreCC1.storeId = [NSNumber numberWithInt:1201];
    diffStoreCC1.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    diffStoreCC1.lpToken = @"2222";
    diffStoreCC1.cardNumber = @"2222"; 
    
    diffStoreCC2.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    diffStoreCC2.storeId = [NSNumber numberWithInt:1201];
    diffStoreCC2.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    diffStoreCC2.lpToken = @"2222";
    diffStoreCC2.cardNumber = @"2222";
    
    toCCT1.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    toCCT1.storeId = [NSNumber numberWithInt:1201];
    toCCT1.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    
    toCCT2.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    toCCT1.storeId = store.storeId;
    toCCT1.paymentTypeId = [NSNumber numberWithInt:CREDITCARD_VISA];
    
    toPOS1.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    toPOS2.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    toPOS3.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    toPOS4.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"2.00"];
    
    // Add to the order
    [order.previousPayments addObject:acctPayment1];
    [order.previousPayments addObject:sameStoreCC1];
    [order.previousPayments addObject:sameStoreCC2];
    [order.previousPayments addObject:sameStoreCC3];
    [order.previousPayments addObject:diffStoreCC1];
    [order.previousPayments addObject:diffStoreCC2];
    [order.previousPayments addObject:toCCT1];
    [order.previousPayments addObject:toCCT2];
    [order.previousPayments addObject:toPOS1];
    [order.previousPayments addObject:toPOS2];
    [order.previousPayments addObject:toPOS3];
    [order.previousPayments addObject:toPOS4];
                                      
    // Check the Refund Info
    Refund *refundInfo = [order getRefundInfo];
    
    // Should have 9 refund items:
    // One on acct
    // same store CC with same token, 
    // diff store CC with same token, 
    // same store CC with ref no token
    // diff store no token
    // same store no token
    // 1 of cash, check, paypal
    
    STAssertTrue([[refundInfo getRefundItems] count] == 9, @"Expected 8 refund items");
}

@end
