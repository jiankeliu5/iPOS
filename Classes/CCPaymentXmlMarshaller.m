//
//  PaymentXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CCPaymentXmlMarshaller.h"
#import "POSOxmUtils.h"
#import "NSString+StringFormatters.h"

#import "CreditCardPayment.h"

static NSString * const PAYMENT_STATUS_ROOT = @"<PaymentStatus";

static NSString * const PAYMENT_XML = @""
    "<PaymentClass>"
        "<CustomerID>%@</CustomerID>"
        "<OrderID>%@</OrderID>"
        "<SalesPersonID>%@</SalesPersonID>"
        "<StoreID>%@</StoreID>"
        "<PaymentAmount>%@</PaymentAmount>"
        "<PaymentType>"
            "<CreditCard>"
                "<CardExpiration>%@</CardExpiration>"
                "<CardNumber>%@</CardNumber>"
                "<NameOnCard>%@</NameOnCard>"
            "</CreditCard>"
        "</PaymentType>"
    "</PaymentClass>";


@interface CCPaymentXmlMarshaller()

- (CreditCardPayment *) toCCPaymentFromPaymentStatus: (NSString *) xmlString;

@end


@implementation CCPaymentXmlMarshaller

#pragma mark -
- (NSString *) toXml:(id)marshalObj {
    NSString *paymentXml = @"<PaymentClass />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[CreditCardPayment class]]) {
        CreditCardPayment *ccPayment = (CreditCardPayment *) marshalObj;
        NSString *orderId = @"";
        NSString *customerId = @"";
        NSString *salesPersonId = @"";
        NSString *storeId = @"";
        NSString *paymentAmount = @"0.00";
        NSString *expireDate = @"";
        NSString *cardNumber = @"";
        NSString *nameOnCard = @"";

        if (ccPayment.orderId) {
            orderId = [NSString stringWithFormat:@"%@", ccPayment.orderId];
        }
        if (ccPayment.customerId) {
            customerId = [NSString stringWithFormat:@"%@", ccPayment.customerId];
        }
        if (ccPayment.salesPersonId) {
            salesPersonId = [NSString stringWithFormat:@"%@", ccPayment.salesPersonId];
        }
        if (ccPayment.storeId) {
            storeId = [NSString stringWithFormat:@"%@", ccPayment.storeId];
        }
        if (ccPayment.paymentAmount) {
            paymentAmount = [NSString formatDecimalNumber:ccPayment.paymentAmount toScale:2];
        }
        if (ccPayment.expireDate) {
            expireDate = ccPayment.expireDate;
        }
        if (ccPayment.cardNumber) {
            cardNumber = ccPayment.cardNumber;
        }
        if (ccPayment.nameOnCard) {
            nameOnCard = ccPayment.nameOnCard;
        }
        
        // Create the XML
        paymentXml = [NSString stringWithFormat: PAYMENT_XML, customerId, orderId, salesPersonId, storeId, paymentAmount, expireDate, cardNumber, nameOnCard];
    }
    
    return paymentXml;
}

- (id) toObject:(NSString *)xmlString {

    if (xmlString == nil) {
        return nil;
    }
    
    // Parse as a PaymentStatus result (contains orderid, reference id, errorlist, )
    NSRange textRange = [xmlString rangeOfString:PAYMENT_STATUS_ROOT];
    if (textRange.location != NSNotFound) {
        return [self toCCPaymentFromPaymentStatus:xmlString];
    } 
    
    // Support for other elements not supported
    return nil;
    
}

#pragma mark -
#pragma mark Private interface
- (CreditCardPayment *) toCCPaymentFromPaymentStatus: (NSString *) xmlString {
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    CreditCardPayment *ccPayment = [[[CreditCardPayment alloc] init] autorelease];
    
    ccPayment.orderId = [root elementNumberValue:@"OrderID"];
    ccPayment.paymentRefId = [root elementStringValue:@"TroutD"]; 
    
    // Parse any errors
    [POSOxmUtils attachErrors:[root firstElementNamed:@"ErrorList"] toModel:ccPayment];
    
    return ccPayment;
    
}
@end
