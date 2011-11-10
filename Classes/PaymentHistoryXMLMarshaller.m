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
#import "CashPayment.h"
#import "CheckPayment.h"


@interface PaymentHistoryXMLMarshaller()
- (void) appendPaymentInfo:(Payment *)paymentObj withXML:(CXMLElement *)element;
@end

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

    
    NSMutableArray *paymentList = [NSMutableArray arrayWithCapacity:0];
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    for (CXMLElement *node in [root elementsForName:@"OrderPaymentStruct"]) {
              
        NSNumber *paymentTypeID = [node elementNumberValue:@"PaymentTypeID"]; 
        int paymentTypeIDIntVal = [paymentTypeID intValue];
        
        if (paymentTypeIDIntVal == 3 || paymentTypeIDIntVal == 4 || paymentTypeIDIntVal == 5 || paymentTypeIDIntVal == 6)
        {
            CreditCardPayment *history = [[CreditCardPayment alloc] init ];
            history.cardNumber = [node elementStringValue:@"CardNum"];
            history.lpToken = [node elementStringValue:@"LPToken"];
            history.paymentRefId = [node elementStringValue:@"TroutD"];
            
            [self appendPaymentInfo:history withXML: node];
            [paymentList addObject:history];
            [history release];
            history = nil;
    
        }
        else if (paymentTypeIDIntVal == 7)
        {
           AccountPayment *history = [[AccountPayment alloc] init];
            [self appendPaymentInfo:history withXML: node];
            [paymentList addObject:history];
            [history release];
            history = nil;
        }
        else if (paymentTypeIDIntVal == 1)
        {
            CashPayment *history = [[CashPayment alloc] init];
            [self appendPaymentInfo:history withXML: node];
            [paymentList addObject:history];
            [history release];
            history = nil;

        }
        else if (paymentTypeIDIntVal == 2)
        {
            CheckPayment *history = [[CheckPayment alloc] init];
            [paymentList addObject:history];
            [history release];
            history = nil;
        }
    }
    
    return paymentList;
}

- (void) appendPaymentInfo:(Payment *)paymentObj withXML:(CXMLElement *)element {
    
    paymentObj.paymentAmount = [element elementDecimalValue:@"Amount"];
    paymentObj.customerId = [element elementNumberValue:@"CustomerID"];
    paymentObj.orderId = [element elementNumberValue:@"OrderID"];
    paymentObj.paymentRefId = [element elementStringValue:@"OrderPaymentID"];
    paymentObj.paymentDate = [element elementStringValue:@"PaymentDate"];
    paymentObj.paymentTypeId = [element elementNumberValue:@"PaymentTypeID"];
    paymentObj.storeId = [element elementNumberValue:@"StoreID"];
    
    paymentObj.orderPaymentId = [element elementNumberValue:@"OrderPaymentID"];
    paymentObj.paymentTypeId = [element elementNumberValue:@"PaymentTypeID"];
}

- (NSString *) toXml: (id) marshalObj
{
    return nil;
}

@end
