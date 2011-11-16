//
//  PaymentHistoryXMLMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentHistoryXMLMarshaller.h"
#import "PaymentService.h"


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
    Payment *previousPayment = nil;
    
    for (CXMLElement *node in [root elementsForName:@"OrderPaymentStruct"]) {
              
        NSNumber *paymentTypeID = [node elementNumberValue:@"PaymentTypeID"]; 
        int paymentTypeIDIntVal = [paymentTypeID intValue];
        
        switch (paymentTypeIDIntVal) {
            case ONACCT: {
                previousPayment = [[AccountPayment alloc] initWithOrder:nil];
                break;
            }
            case CREDITCARD_VISA: 
            case CREDITCARD_MC: 
            case CREDITCARD_AX: 
            case CREDITCARD_DISCOVER: {
                previousPayment = [[CreditCardPayment alloc] initWithOrder:nil];
            
                ((CreditCardPayment *) previousPayment).cardNumber = [node elementStringValue:@"CardNum"];
                ((CreditCardPayment *) previousPayment).lpToken = [node elementStringValue:@"LPToken"];
                ((CreditCardPayment *) previousPayment).paymentRefId = [node elementStringValue:@"TroutD"];
                
                break;
            }
            case CASH: {
                previousPayment = [[CashPayment alloc] initWithOrder:nil];
                break;
            }
            case CHECK: {
                previousPayment = [[CheckPayment alloc] initWithOrder:nil];
                break;
            }
            case INSTORE_CREDIT: {
                previousPayment = [[InStoreCreditPayment alloc] initWithOrder:nil];
                break;
            }
            case GIFT_CARD: {
                previousPayment = [[GiftCardPayment alloc] initWithOrder:nil];
                break;
            }
            case GOOGLE: {
                previousPayment = [[GooglePayment alloc] initWithOrder:nil];
                break;
            }
            case HOMEDESIGN: {
                previousPayment = [[HomeDesignPayment alloc] initWithOrder:nil];
                break;
            }
            case PAYPAL: {
                previousPayment = [[PayPalPayment alloc] initWithOrder:nil];
                break;
            }
            default: {
                previousPayment = [[Payment alloc] initWithOrder:nil];
                break;
            }
        }

        if (previousPayment) {
            [self appendPaymentInfo:previousPayment withXML: node];
            [paymentList addObject:previousPayment];
            [previousPayment release];
            previousPayment = nil;
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
