//
//  RefundOxmTestCase.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RefundOxmTestCase.h"

#import "Refund.h"
#import "RefundItem.h"
#import "CreditCardPayment.h"
#import "AccountPayment.h"
#import "RefundXmlMarshaller.h"

@implementation RefundOxmTestCase

- (void) testRefundXMLConversionWithCreditCard{
    
    Refund *refund = [[Refund alloc] init];
    refund.orderId = [NSNumber numberWithInt:345];
    refund.customerId = [NSNumber numberWithInt:1234];
    refund.storeId = [NSNumber numberWithInt:1200];
    refund.salesPersonId = [NSNumber numberWithInt:1924];
    refund.refundDate = @"date";
    
    RefundItem *item = [[RefundItem alloc] init];
    
    item.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    item.orderPaymentTypeID = [NSNumber numberWithInt:3];
    
    CreditCardPayment *payment = [[CreditCardPayment alloc] init];
    payment.cardNumber = @"444";
    payment.paymentRefId = @"troutd1";
    payment.lpToken = @"lpToken1";
    payment.nameOnCard = @"D C";
    
    NSString *signature = @"signature";
    
    [refund addRefundItem:item];
    refund.signature = signature;
    
    NSString *expected = @"<RefundRequest><CustomerID>1234</CustomerID><OrderID>345</OrderID><StoreID>1200</StoreID><SalesPersonID>1924</SalesPersonID><RefundDate>date</RefundDate><ListOfRefunds><Refund><Amount>20</Amount><OrderPaymentTypeID>3</OrderPaymentTypeID></Refund></ListOfRefunds><PaymentSignature><SignatureAsBase64>signature</SignatureAsBase64></PaymentSignature></RefundRequest>";
    
    
    RefundXmlMarshaller *xmlResult = [[RefundXmlMarshaller alloc] init];
    
    NSString *result = [xmlResult toXml:refund];
    
    STAssertTrue([expected isEqualToString: result], @"Result was %@", result);
}

- (void) testRefundXMLConversionWithCash{
    
    Refund *refund = [[Refund alloc] init];
    refund.orderId = [NSNumber numberWithInt:345];
    refund.customerId = [NSNumber numberWithInt:1234];
    refund.storeId = [NSNumber numberWithInt:1200];
    refund.salesPersonId = [NSNumber numberWithInt:1924];
    refund.refundDate = @"date";
    
    RefundItem *item = [[RefundItem alloc] init];
    
    item.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    item.orderPaymentTypeID = [NSNumber numberWithInt:1];
        
    [refund addRefundItem:item];
    
    NSString *expected = @"<RefundRequest><CustomerID>1234</CustomerID><OrderID>345</OrderID><StoreID>1200</StoreID><SalesPersonID>1924</SalesPersonID><RefundDate>date</RefundDate><ListOfRefunds><Refund><Amount>20</Amount><OrderPaymentTypeID>1</OrderPaymentTypeID></Refund></ListOfRefunds><PaymentSignature><SignatureAsBase64></SignatureAsBase64></PaymentSignature></RefundRequest>";
    
    
    RefundXmlMarshaller *xmlResult = [[RefundXmlMarshaller alloc] init];
    
    NSString *result = [xmlResult toXml:refund];
    
    STAssertTrue([expected isEqualToString: result], @"Result was %@", result);
}

- (void) testRefundXMLConversionWithAccount{
    
    Refund *refund = [[Refund alloc] init];
    refund.orderId = [NSNumber numberWithInt:345];
    refund.customerId = [NSNumber numberWithInt:1234];
    refund.storeId = [NSNumber numberWithInt:1200];
    refund.salesPersonId = [NSNumber numberWithInt:1924];
    refund.refundDate = @"date";
    
    RefundItem *item = [[RefundItem alloc] init];
    
    item.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    item.orderPaymentTypeID = [NSNumber numberWithInt:7];
    
   // AccountPayment *payment = [[AccountPayment alloc] init];
        
    NSString *signature = @"signature";
    
    [refund addRefundItem:item];
    refund.signature = signature;
    
    NSString *expected = @"<RefundRequest><CustomerID>1234</CustomerID><OrderID>345</OrderID><StoreID>1200</StoreID><SalesPersonID>1924</SalesPersonID><RefundDate>date</RefundDate><ListOfRefunds><Refund><Amount>20</Amount><OrderPaymentTypeID>7</OrderPaymentTypeID></Refund></ListOfRefunds><PaymentSignature><SignatureAsBase64>signature</SignatureAsBase64></PaymentSignature></RefundRequest>";
    
    
    RefundXmlMarshaller *xmlResult = [[RefundXmlMarshaller alloc] init];
    
    NSString *result = [xmlResult toXml:refund];
    
    STAssertTrue([expected isEqualToString: result], @"The result was %@", result);
}

-(void) testRefundXMLConversionMultipleTypes{
    
    Refund *refund = [[Refund alloc] init];
    refund.orderId = [NSNumber numberWithInt:345];
    refund.customerId = [NSNumber numberWithInt:1234];
    refund.storeId = [NSNumber numberWithInt:1200];
    refund.salesPersonId = [NSNumber numberWithInt:1924];
    refund.refundDate = @"date";
    
    RefundItem *item = [[RefundItem alloc] init];
    
    item.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    item.orderPaymentTypeID = [NSNumber numberWithInt:7];
    
    RefundItem *itemTwo = [[RefundItem alloc] init];
    
    itemTwo.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    itemTwo.orderPaymentTypeID = [NSNumber numberWithInt:7];
    
    NSString *signature = @"signature";
    
    [refund addRefundItem:item];
    [refund addRefundItem:itemTwo];
    refund.signature = signature;
    
    RefundXmlMarshaller *xmlResult = [[RefundXmlMarshaller alloc] init];

    NSString *result = [xmlResult toXml:refund];
    
    NSString *expected = @"<RefundRequest><CustomerID>1234</CustomerID><OrderID>345</OrderID><StoreID>1200</StoreID><SalesPersonID>1924</SalesPersonID><RefundDate>date</RefundDate><ListOfRefunds><Refund><Amount>20</Amount><OrderPaymentTypeID>7</OrderPaymentTypeID></Refund><Refund><Amount>20</Amount><OrderPaymentTypeID>7</OrderPaymentTypeID></Refund></ListOfRefunds><PaymentSignature><SignatureAsBase64>signature</SignatureAsBase64></PaymentSignature></RefundRequest>";

    
    STAssertTrue([expected isEqualToString: result], @"Result was %@", result);
    
    
}

@end
