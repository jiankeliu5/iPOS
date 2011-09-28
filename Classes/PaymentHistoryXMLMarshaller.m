//
//  PaymentHistoryXMLMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentHistoryXMLMarshaller.h"
#import "PaymentHistory.h"
#import "CreditCardPaymentHistoryItem.h"
#import "AccountPaymentHistoryItem.h"


@implementation PaymentHistoryXMLMarshaller

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) toObject:(NSString *) xmlString {
    
    PaymentHistory *history = [[[PaymentHistory alloc] init] autorelease];
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    for (CXMLElement *node in [root elementsForName:@"OrderPaymentStruct"]) {
        
        NSNumber *paymentTypeID = [node elementNumberValue:@"PaymentTypeID"]; 
        int paymentTypeIDIntVal = [paymentTypeID intValue];
        
        if (paymentTypeIDIntVal == 3 || paymentTypeIDIntVal == 4 || paymentTypeIDIntVal == 5 || paymentTypeIDIntVal == 6)
        {
            CreditCardPaymentHistoryItem *ccItem = [[[CreditCardPaymentHistoryItem alloc] init] autorelease];
            ccItem.amount = [node elementDecimalValue:@"Amount"];
            ccItem.customerID = [node elementNumberValue:@"CustomerID"];
            ccItem.orderId = [node elementNumberValue:@"OrderID"];
            ccItem.orderPaymentId = [node elementNumberValue:@"OrderPaymentID"];
            ccItem.paymentDate = [node elementStringValue:@"PaymentDate"];
            ccItem.paymentTypeId = [node elementNumberValue:@"PaymentTypeID"];
            ccItem.storeId = [node elementNumberValue:@"StoreID"];
            ccItem.cardNumber = [node elementStringValue:@"CardNum"];
            ccItem.lpToken = [node elementStringValue:@"LPToken"];
            ccItem.tRouteD = [node elementStringValue:@"TrouteD"];
            
            history.creditCardPayment = ccItem;
        }
        else if (paymentTypeIDIntVal == 7)
        {
            AccountPaymentHistoryItem *accountItem = [[AccountPaymentHistoryItem alloc] init];
            accountItem.amount = [node elementDecimalValue:@"Amount"];
            accountItem.customerID = [node elementNumberValue:@"CustomerID"];
            accountItem.orderId = [node elementNumberValue:@"OrderID"];
            accountItem.orderPaymentId = [node elementNumberValue:@"OrderPaymentID"];
            accountItem.paymentDate = [node elementStringValue:@"PaymentDate"];
            accountItem.paymentTypeId = [node elementNumberValue:@"PaymentTypeID"];
            accountItem.storeId = [node elementNumberValue:@"StoreID"];
            
            history.accountPayment = accountItem; 
        }
    }
    
    return history;
}

- (NSString *) toXml: (id) marshalObj
{
    return nil;
}

@end
