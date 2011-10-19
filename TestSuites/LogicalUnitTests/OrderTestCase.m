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
#import "CreditCardPayment.h"


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
    
    NSMutableArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    orderItem.setStatusToClosed;
    
    OrderItem *orderItemTwo = [orderItems objectAtIndex:1];
    orderItemTwo.setStatusToClosed;
    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    NSLog([[order calcBalanceDue] stringValue]);
    
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"49.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.tRouteD = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    TenderDecision decision = [order isRefundEligble];
    
    STAssertTrue(decision == NOCHANGE, @"No change to payment was expected");
}

-(void) testPreviousOrderCalcBalanceDueRefund   
{
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
    
    NSMutableArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    orderItem.setStatusToClosed;
    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    NSLog([[order calcBalanceDue] stringValue]);
    
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"49.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.tRouteD = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    TenderDecision decision = [order isRefundEligble];
    
    STAssertTrue(decision == REFUND, @"A refund was expected");
}

-(void) testPreviousOrderCalcBalanceDuePayMore   
{
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
    
    NSMutableArray *orderItems = [order getOrderItems];
    
    OrderItem *orderItem = [orderItems objectAtIndex:0];
    orderItem.setStatusToClosed;
    
    OrderItem *orderItemTwo = [orderItems objectAtIndex:1];
    orderItemTwo.setStatusToClosed;

    
    Customer *customer = [[Customer alloc] init];
    customer.customerTypeId = [NSNumber numberWithInt:2];
    
    order.customer = customer;
    
    NSLog([[order calcBalanceDue] stringValue]);
    
    
    CreditCardPayment *ccPayment = [[CreditCardPayment alloc] init];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"38.25"];
    ccPayment.cardNumber = @"1234567890000";
    ccPayment.lpToken = @"lpToken1";
    ccPayment.tRouteD = @"tRouteD1";
    
    NSMutableArray *previousPayments = [NSArray arrayWithObject:ccPayment];
    
    order.previousPayments = previousPayments;
    
    TenderDecision decision = [order isRefundEligble];
    
    STAssertTrue(decision == TENDER, @"Payment was expected");
}

@end
