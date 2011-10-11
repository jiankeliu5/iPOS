//
//  PaymentHistoryXMLMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentHistoryXMLMarshaller.h"
#import "CreditCardPayment.h"
#import "AccountPayment.h"


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
    
    Payment *history;
    
    NSMutableArray *paymentList = [NSMutableArray arrayWithCapacity:0];
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    for (CXMLElement *node in [root elementsForName:@"OrderPaymentStruct"]) {
        history = [[[Payment alloc] init] autorelease];
        
        NSNumber *paymentTypeID = [node elementNumberValue:@"PaymentTypeID"]; 
        int paymentTypeIDIntVal = [paymentTypeID intValue];
        
        if (paymentTypeIDIntVal == 3 || paymentTypeIDIntVal == 4 || paymentTypeIDIntVal == 5 || paymentTypeIDIntVal == 6)
        {
            history = [[CreditCardPayment alloc] init ];
            history.cardNumber = [node elementStringValue:@"CardNum"];
        }
        else if (paymentTypeIDIntVal == 7)
        {
            history = [[AccountPayment alloc] init]; 
        }
        
        history.paymentAmount = [node elementDecimalValue:@"Amount"];
        history.customerId = [node elementNumberValue:@"CustomerID"];
        history.orderId = [node elementNumberValue:@"OrderID"];
        history.paymentRefId = [node elementStringValue:@"OrderPaymentID"];
        history.paymentDate = [node elementStringValue:@"PaymentDate"];
        history.paymentTypeId = [node elementNumberValue:@"PaymentTypeID"];
        history.storeId = [node elementNumberValue:@"StoreID"];
        history.lpToken = [node elementStringValue:@"LPToken"];
        history.tRouteD = [node elementStringValue:@"TrouteD"];
        history.orderPaymentId = [node elementNumberValue:@"OrderPaymentID"];
        history.paymentTypeId = [node elementNumberValue:@"PaymentTypeID"];
        
        [paymentList addObject:history];
        
        [history release];
        history = nil;
    }
    
    return paymentList;
}

- (NSString *) toXml: (id) marshalObj
{
    return nil;
}

@end
