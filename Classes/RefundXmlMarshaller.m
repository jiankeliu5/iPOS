//
//  RefundXmlMarshaller.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RefundXmlMarshaller.h"


static NSString *REFUND_XML = @""
"<RefundRequest>"   
    "<CustomerID>%@</CustomerID>"
    "<OrderID>%@</OrderID>"
    "<StoreID>%@</StoreID>"
    "<SalesPersonID>%@</SalesPersonID>"
    "<RefundDate>%@</RefundDate>"
    "<ListOfRefunds>"
        "<Refund>"
            "<Amount>%@</Amount>"
            "<OrderPaymentTypeID>%@</OrderPaymentTypeID>"
        "${creditCard}"
        "</Refund>"
    "</ListOfRefunds>"
    "<PaymentSignature>"
        "<SignatureAsBase64>%@</SignatureAsBase64>"
    "</PaymentSignature>"
"</RefundRequest>";

static NSString *CREDIT_CARD_XML = @""
"<CreditCard>" //Optional
    "<LPToken>%@</LPToken>"
    "<TroutD>%@</TRoutD>"
    //Optional Fields
    "<CardExpiration>%@</CardExpiration>"
    "<CardNum>%@</CardNum>"
    "<NameOnCard>%@</NameOnCard>"
"</CreditCard>";


@implementation RefundXmlMarshaller

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (id) toObject:(NSString *) xmlString{
    
    return nil;
    
}


- (NSString *) toXml: (id) marshalObj{
    return nil;
}

@end
