//
//  CustomerXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CustomerXmlMarshaller.h"
#import "POSOxmUtils.h"

#import "Customer.h"

static NSString * const CUSTOMER_XML = @""
"<CustomerClass>"
"<Address>"
"<CustomerAddress>"
"<Address1>%@</Address1>"
"<Address2>%@</Address2>"
"<City>%@</City>"
"<State>%@</State>"
"<Zip>%@</Zip>"
"</CustomerAddress>"
"</Address>"
"${customerIdXml}"
"<CustomerName>%@</CustomerName>"
"<Email>%@</Email>"
"${phoneXml}"
"${storeXml}"
"</CustomerClass>";

@implementation CustomerXmlMarshaller

-(NSString *) toXml:(id) marshalObj {
    NSString *customerXml = @"<CustomerClass />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[Customer class]]) {
        Customer *customer = (Customer *) marshalObj;
        
        NSString *customerId = nil;
        NSString *storeId = @"0";
        
        NSString *addrLine1 = @"";
        NSString *addrLine2 = @"";
        NSString *addrCity = @"";
        NSString *addrState = @"";
        NSString *addrZip = @"";
        NSString *name = @"";
        NSString *email = @"";
        NSString *phone = @"";
        
        // Initialize the XML template fields
        if (customer.store && customer.store.storeId) {
            storeId = [NSString stringWithFormat:@"%@", customer.store.storeId];
        }
        if (customer.customerId) {
            customerId = [NSString stringWithFormat:@"%@", customer.customerId]; 
        }
        if (customer.address && customer.address.line1) {
            addrLine1 = customer.address.line1;
        }
        if (customer.address && customer.address.line2) {
            addrLine2 = customer.address.line2;
        }
        if (customer.address && customer.address.city) {
            addrCity = customer.address.city;
        }
        if (customer.address && customer.address.stateProv) {
            addrState = customer.address.stateProv;
        }
        if (customer.address && customer.address.zipPostalCode) {
            addrZip = customer.address.zipPostalCode;
        }
        if ((customer.firstName && customer.lastName) && ([customer.firstName length ] > 0 && [customer.lastName length] > 0)) {
            name = [NSString stringWithFormat:@"%@, %@", customer.lastName, customer.firstName];
        } else if (customer.lastName && [customer.lastName length] > 0) {
            name = customer.lastName;
        } else if (customer.firstName && [customer.firstName length] > 0) {
            name = customer.firstName;
        }
        if (customer.emailAddress) {
            email = customer.emailAddress;
        }
        if (customer.phoneNumber) {
            phone = customer.phoneNumber;
        }
        
        customerXml = [NSString stringWithFormat:CUSTOMER_XML, addrLine1, addrLine2, addrCity, addrState, addrZip, name, email];
        
        // Perform parameter replacement
        if (customerId) {
            customerXml = [POSOxmUtils replaceInXmlTemplate:customerXml parameter:@"customerIdXml" withValue:[POSOxmUtils genXmlElementWithName:@"CustomerID" value:customerId]];
            customerXml = [POSOxmUtils replaceInXmlTemplate:customerXml parameter:@"phoneXml" withValue:@""];
            customerXml = [POSOxmUtils replaceInXmlTemplate:customerXml parameter:@"storeXml" withValue:@""];
        } else {
            customerXml = [POSOxmUtils replaceInXmlTemplate:customerXml parameter:@"customerIdXml" withValue:@""];
            customerXml = [POSOxmUtils replaceInXmlTemplate:customerXml parameter:@"phoneXml" withValue:[POSOxmUtils genXmlElementWithName:@"Phone1" value:phone]];
            customerXml = [POSOxmUtils replaceInXmlTemplate:customerXml parameter:@"storeXml" withValue:[POSOxmUtils genXmlElementWithName:@"StoreID" value:storeId]];
        }
        
        
    }
    
    return customerXml;
}

-(id) toObject:(NSString *)xmlString {
    if (xmlString ==  nil) {
        return nil;
    }
    
    Customer *customer = [[[Customer alloc] init] autorelease];    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Attach any errors
    [POSOxmUtils attachErrors: [root firstElementNamed:@"ErrorList"] toModel:customer];
    
    
    // Map the customer if no errors are present
    if (customer.errorList == nil || [customer.errorList count] == 0) {
        // Return fully "mapped" customer If no error
        customer.customerId = [root elementNumberValue:@"CustomerID"];
        customer.customerType = [root elementStringValue:@"CustomerType"];
        customer.customerTypeId = [root elementNumberValue:@"CustomerTypeID"];
        customer.priceLevelId = [root elementNumberValue:@"PriceLevelID"];
        customer.phoneNumber = [root elementStringValue:@"Phone1"];
        customer.emailAddress = [root elementStringValue:@"Email"];
        customer.taxExempt = [root elementBoolValue:@"TaxExempt"];
        customer.holdStatus = [root elementNumberValue:@"HoldTypeID"];
        customer.holdStatusText = [root elementStringValue:@"HoldType"];
        customer.creditBalance = [root elementDecimalValue:@"CreditBalance"];
        customer.creditLimit = [root elementDecimalValue:@"CreditLimit"];
        customer.termsTypeId = [root elementNumberValue:@"TermsTypeID"];
        
        
        // Customer Name
        NSArray *names = [[root elementStringValue:@"CustomerName"] componentsSeparatedByString:@","];
        if ([names count] == 2) {
            customer.lastName = [(NSString *) [names objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            customer.firstName = [(NSString *) [names objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        } else {
            customer.firstName = [names objectAtIndex:0];
        }
        
        // Address
        CXMLElement *addressElement = [root firstElementNamed:@"Address"];
        customer.address = [POSOxmUtils toAddress:[addressElement firstElementNamed:@"CustomerAddress"]];
        
        // Store
        customer.store = [POSOxmUtils toStore:root];    
    }
    
    return customer;
}

- (void) addCustomerName:(NSString *) customerName toCustomer:(Customer *) customer
{
    NSArray *names = [customerName componentsSeparatedByString:@","];
    
    if ([names count] == 2) {
        customer.lastName = [(NSString *) [names objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        customer.firstName = [(NSString *) [names objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    } else {
        customer.firstName = [names objectAtIndex:0];
    }
}

- (id) toObjectFromXmlElement: (CXMLElement *) root {
    
     Customer *customer = [[Customer alloc] init];
    
     customer.customerId = [root elementNumberValue:@"CustomerID"];
     customer.customerTypeId = [root elementNumberValue:@"CustomerTypeID"];
    [self addCustomerName:[root elementStringValue:@"CustomerName"] toCustomer:customer];
    customer.taxExempt = [root elementBoolValue:@"TaxExempt"];
    customer.eOneCustoemrId = [root elementNumberValue:@"E1CustomerID"];
    customer.phoneNumber = [root elementStringValue:@"CustomerPhone"];
    Address *address = [[Address alloc] init];
    address.zipPostalCode = [root elementStringValue:@"Zip"];
    
    customer.address = address;
    
    [address release];
    
    return customer;
}


@end
