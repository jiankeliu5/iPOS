//
//  AccountPaymentXmlMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountPaymentXmlMarshaller.h"
#import "AccountPayment.h"
#import "POSOxmUtils.h"
#import "NSString+StringFormatters.h"

static NSString * const PAYMENT_STATUS_ROOT = @"<PaymentStatus";

static NSString * const PAYMENT_XML = @""
                                    "<PaymentClass>"
                                        "<CustomerID>%@</CustomerID>"
                                        "<OrderID>%@</OrderID>"
                                        "<SalesPersonID>%@</SalesPersonID>"
                                        "<StoreID>%@</StoreID>"
                                        "<PaymentAmount>%@</PaymentAmount>"
                                        "<PaymentType>"
                                            "<OnAccount>true</OnAccount>"
                                        "</PaymentType>"
                                    "</PaymentClass>";

@interface AccountPaymentXmlMarshaller()

- (AccountPayment *) toAccountPaymentFromPaymentStatus: (NSString *) xmlString;

@end

@implementation AccountPaymentXmlMarshaller

- (NSString *) toXml:(id)marshalObj {
    NSString *paymentXml = @"<PaymentClass />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[AccountPayment class]]) {
        AccountPayment *accountPayment = (AccountPayment *) marshalObj;
        NSString *orderId = @"";
        NSString *customerId = @"";
        NSString *salesPersonId = @"";
        NSString *storeId = @"";
        NSString *paymentAmount = @"0.00";
        
        if (accountPayment.orderId) {
            orderId = [NSString stringWithFormat:@"%@", accountPayment.orderId];
        }
        if (accountPayment.customerId) {
            customerId = [NSString stringWithFormat:@"%@", accountPayment.customerId];
        }
        if (accountPayment.salesPersonId) {
            salesPersonId = [NSString stringWithFormat:@"%@", accountPayment.salesPersonId];
        }
        if (accountPayment.storeId) {
            storeId = [NSString stringWithFormat:@"%@", accountPayment.storeId];
        }
        if (accountPayment.paymentAmount) {
            paymentAmount = [NSString formatDecimalNumber:accountPayment.paymentAmount toScale:2];
                            
        }
                
        // Create the XML
        paymentXml = [NSString stringWithFormat: PAYMENT_XML, customerId, orderId, salesPersonId, storeId, paymentAmount];
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
        return [self toAccountPaymentFromPaymentStatus:xmlString];
    } 
    
    // Support for other elements not supported
    return nil;
    
}

#pragma mark -
#pragma mark Private interface
- (AccountPayment *) toAccountPaymentFromPaymentStatus: (NSString *) xmlString {
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    AccountPayment *accountPayment = [[[AccountPayment alloc] init] autorelease];
    
    accountPayment.orderId = [root elementNumberValue:@"OrderID"];
    accountPayment.paymentRefId = [root elementStringValue:@"TroutD"]; 
    
    // Parse any errors
    [POSOxmUtils attachErrors:[root firstElementNamed:@"ErrorList"] toModel:accountPayment];
    
    return accountPayment;
    
}


@end
