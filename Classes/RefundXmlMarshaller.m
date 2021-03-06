//
//  RefundXmlMarshaller.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RefundXmlMarshaller.h"
#import "Refund.h"
#import "POSOxmUtils.h"


static NSString *REFUND_XML = @""
"<RefundRequest>"   
    "<CustomerID>%@</CustomerID>"
    "<OrderID>%@</OrderID>"
    "<StoreID>%@</StoreID>"
    "<SalesPersonID>%@</SalesPersonID>"
    "<RefundDate>%@</RefundDate>"
    "<ListOfRefunds>"
        "${refundItem}"
    "</ListOfRefunds>"
    "<PaymentSignature>"
        "<SignatureAsBase64>${signature}</SignatureAsBase64>"
    "</PaymentSignature>"
"</RefundRequest>";


static NSString *REFUND_ITEM_XML = @""
"<Refund>"
    "<Amount>%@</Amount>"
    "<OrderPaymentTypeID>%@</OrderPaymentTypeID>"
    "${creditCard}"
"</Refund>";

static NSString *CREDIT_CARD_XML = @""
"<CreditCard>" //Optional
    "<LPToken>%@</LPToken>"
    "<TroutD>%@</TroutD>"
    //Optional Fields For Swiping
    "<CardExpiration>%@</CardExpiration>"
    "<CardNum>%@</CardNum>"
    "<NameOnCard>%@</NameOnCard>"
"</CreditCard>";
    
@interface RefundXmlMarshaller() 

- (NSString *) createRefundItems:(Refund *)item;
- (NSString *) createCreditCardXML:(CreditCardPayment *) ccPayment;
@end

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
    
    Refund *refund = [[[Refund alloc] init] autorelease];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Attach any errors
    BOOL isSuccessful = [root elementBoolValue:@"Success"];
    
    if (!isSuccessful) {
        Error *error = [[Error alloc] init];
        error.message = @"Refund failed.";
        [refund addError:error];
        
        [error release];
    }
    
    [POSOxmUtils attachErrors: [root firstElementNamed:@"ErrorList"] toModel:refund];

    return refund;
    
}

- (NSString *) toXml: (id) marshalObj{
    
    NSString *xml = @"";
    
    if ([marshalObj isMemberOfClass:[Refund class]])
    {
        Refund *object = (Refund *)marshalObj;
        
        NSString *customerID = @"";
        NSString *orderID = @"";
        NSString *storeID = @"";
        NSString *salesPersonID = @"";
        NSString *refundDate = @"";

        
        if (object.customerId)
        {
            customerID = [object.customerId stringValue];
        }
        
        if (object.orderId)
        {
            orderID = [object.orderId stringValue];
        }
        
        if (object.storeId)
        {
            storeID = [object.storeId stringValue];
        }
        
        if (object.salesPersonId)
        {
            salesPersonID = [object.salesPersonId stringValue];
        }
        
        if (object.refundDate)
        {
            refundDate = object.refundDate;
        }
        
         xml = [NSString stringWithFormat:REFUND_XML, customerID, orderID, storeID, salesPersonID, refundDate];
        
        
        
        xml = [POSOxmUtils replaceInXmlTemplate:xml parameter:@"refundItem" withValue:[self createRefundItems: object]];
        
        if (object.signature)
        {
            xml = [POSOxmUtils replaceInXmlTemplate:xml parameter:@"signature" withValue:object.signature];    
        }
        else 
        {
         xml = [POSOxmUtils replaceInXmlTemplate:xml parameter:@"signature" withValue:@""];    
        }
    }
    
    return xml;
}

- (NSString *) createRefundItems:(Refund *)item{
    NSString *xml = @"";
    NSString *creditCardXml = nil;
    NSString *amount = @"";
    NSString *type = @"";
    
    NSArray *refundItems = item.refundItems;
    
    if ([refundItems count] > 0)
    {
        for (RefundItem *item in refundItems) {
            if (item.amount)
            {
                amount = [item.amount stringValue];
            }
            
            if (item.orderPaymentTypeID)
            {
                type = [item.orderPaymentTypeID stringValue];
            }
            
            if ([item isCreditCard])
            {
                if (item.creditCard)
                {
                    creditCardXml = [self createCreditCardXML: item.creditCard];                    
                }
            }
            
            xml = [xml stringByAppendingFormat: REFUND_ITEM_XML, amount, type];
            
            if (creditCardXml) {
                xml = [POSOxmUtils replaceInXmlTemplate:xml parameter:@"creditCard" withValue:creditCardXml];
            }
            else {
                xml = [POSOxmUtils replaceInXmlTemplate:xml parameter:@"creditCard" withValue:@""];
            }
            
            creditCardXml = nil;
        }
    }
    
    return xml;
    
}

- (NSString *) createCreditCardXML:(CreditCardPayment *) ccPayment{
    
    NSString *xml = @"";
    
    NSString *lpToken = @"";
    NSString *troutD = @"";
    NSString *cardExpirationDate = @"";
    NSString *cardNum = @"";
    NSString *nameOnCard = @"";
            
    if (ccPayment) {
        if (ccPayment.lpToken) {
            lpToken = ccPayment.lpToken;
        }
        
        if (ccPayment.paymentRefId) {
            troutD = ccPayment.paymentRefId;
        }
        
        if (ccPayment.cardNumber) {
            cardNum = ccPayment.cardNumber;
        }
        
        if(ccPayment.nameOnCard) {
            nameOnCard = ccPayment.nameOnCard;
        }
        
        if(ccPayment.expireDate) {
            cardExpirationDate = ccPayment.expireDate;
        }
    }
    
    xml = [NSString stringWithFormat:CREDIT_CARD_XML, lpToken, troutD,cardExpirationDate, cardNum, nameOnCard]; 

    return xml;
}

@end
