//
//  PaymentSignatureXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "PaymentSignatureXmlMarshaller.h"
#import "PaymentSignature.h"

static NSString * const PAYMENT_SINGATURE_XML = @""
    "<PaymentSignature>"
        "<OnAccount>%@</OnAccount>"
        "<SignatureAsBase64>%@</SignatureAsBase64>"
        "<TroutD>%@</TroutD>"
    "</PaymentSignature>";

@implementation PaymentSignatureXmlMarshaller
- (id) toObject:(NSString *)xmlString {
    // Not supported/required at this time
    return nil;
}

- (NSString *) toXml:(id)marshalObj {
    NSString *paymentSignatureXml = @"<PaymentSignature />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[PaymentSignature class]]) {
        PaymentSignature *signature = (PaymentSignature *) marshalObj;
        
        NSString *payRefId = @"";
        NSString *signatureAsBase64 = @"0.00";
        NSString *isPayOnAccount = @"false";
        
        if (signature.paymentRefId) {
            payRefId = signature.paymentRefId;
        }
        if (signature.signatureAsBase64) {
            signatureAsBase64 = signature.signatureAsBase64;
        }
        if (signature.isPayOnAccount)
        {
            if(signature.isPayOnAccount == YES)
            {
                isPayOnAccount = @"true";
            }
            
        }
                
        // Create the XML
        paymentSignatureXml = [NSString stringWithFormat: PAYMENT_SINGATURE_XML, isPayOnAccount, signatureAsBase64, payRefId];
    }
    
    return paymentSignatureXml;
}



@end
