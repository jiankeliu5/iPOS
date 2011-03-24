//
//  CustomerMarshalling.m
//  iPOS
//
//  Created by Torey Lomenda on 3/15/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CustomerMarshalling.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"

@implementation CustomerMarshalling

+ (NSString *) toXml: (Customer *) customer {
    NSString *customerXml = @"<CustomerClass />";
    
    if (customer) {
        NSString *customerId = @"0";
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
        if (customer.firstName && customer.lastName) {
            name = [NSString stringWithFormat:@"%@, %@", customer.lastName, customer.firstName];
        } else if (customer.lastName) {
            name = customer.lastName;
        } else if (customer.firstName) {
            name = customer.firstName;
        }
        if (customer.emailAddress) {
            email = customer.emailAddress;
        }
        if (customer.phoneNumber) {
            phone = customer.phoneNumber;
        }
        
        // Is this a new or existing customer
        if ([customerId isEqualToString:@"0"]) {
            customerXml = [NSString stringWithFormat:@"<CustomerClass>"
                 "<Address><CustomerAddress><Address1>%@</Address1><Address2>%@</Address2><City>%@</City><State>%@</State><Zip>%@</Zip></CustomerAddress></Address>"
                 "<CustomerName>%@</CustomerName>"
                 "<Email>%@</Email>"
                 "<Phone1>%@</Phone1>"
                 "<StoreID>%@</StoreID>"
                 "</CustomerClass>", addrLine1, addrLine2, addrCity, addrState, addrZip, name, email, phone, storeId];
        } else {
            customerXml = [NSString stringWithFormat:@"<CustomerClass>"
                "<Address><CustomerAddress><Address1>%@</Address1><Address2>%@</Address2><City>%@</City><State>%@</State><Zip>%@</Zip></CustomerAddress></Address>"
                "<CustomerID>%@</CustomerID>"
                "<CustomerName>%@</CustomerName>"
                "<Email>%@</Email>"
                "</CustomerClass>", addrLine1, addrLine2, addrCity, addrState, addrZip, customerId, name, email];
            
        }
    }
    
    return customerXml; 
}

+ (Customer *) toObject:(NSString *) xmlString {
    Customer *customer = [[[Customer alloc] init] autorelease];
    Address *address = nil;
    Store *store = nil;
    Error *error = nil;
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Extract the itemID.  If it 0 return nil;
    NSArray *nodes = nil;
    NSArray *errorNodes = nil;
    CXMLElement *element = nil;
    CXMLElement *errorElement = nil;
    CXMLElement *customerAddressElement = nil;
    
    // Parse any error
    nodes = [root elementsForName:@"ErrorList"];
    element = [nodes lastObject];
    if (element) {
        nodes = [element elementsForName:@"Error"];
        
    }
    if ([nodes count] > 0) {
        NSMutableArray *errorList = [NSMutableArray arrayWithCapacity:[nodes count]];
        
        for (CXMLElement *node in nodes) {
            error = [[[Error alloc] init] autorelease];
            
            errorNodes = [node elementsForName:@"ErrorID"];
            element = [errorNodes lastObject];
            if (element) {
                error.errorId = [element stringValue];
            }
            
            errorNodes = [node elementsForName:@"ErrorMessage"];
            element = [errorNodes lastObject];
            if (element) {
                error.message = [element stringValue];
            }
            
            if (error.errorId && ![error.errorId isEqualToString:@""] && error.message && ![error.message isEqualToString:@""]) {
                [errorList addObject:error];
            }
        }
        
        customer.errorList = [NSArray arrayWithArray:errorList];
    }
    
    // Map the customer if no errors are present
    if (customer.errorList == nil || [customer.errorList count] == 0) {
        // Return fully "mapped" customer If no error
        nodes = [root elementsForName:@"CustomerID"];
        element = [nodes lastObject];
        
        if (element) {
            customer.customerId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        }
        
        nodes = [root elementsForName:@"CustomerType"];
        element = [nodes lastObject];
        
        if (element) {
            customer.customerType = [element stringValue];
        }
        
        nodes = [root elementsForName:@"CustomerTypeID"];
        element = [nodes lastObject];
        
        if (element) {
            customer.customerTypeId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        }
        
        nodes = [root elementsForName:@"CustomerName"];
        element = [nodes lastObject];
        
        // Split into first and last name
        if (element) {
            NSArray *names = [[element stringValue] componentsSeparatedByString:@","];
            
            if ([names count] == 2) {
                customer.lastName = [(NSString *) [names objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                customer.firstName = [(NSString *) [names objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            } else {
                customer.firstName = [element stringValue];
            }
        }
        nodes = [root elementsForName:@"Phone1"];
        element = [nodes lastObject];
        
        if (element) {
            customer.phoneNumber = [element stringValue];
        }
        
        nodes = [root elementsForName:@"Email"];
        element = [nodes lastObject];
        
        if (element) {
            customer.emailAddress = [element stringValue];
        }
        nodes = [root elementsForName:@"TaxExempt"];
        element = [nodes lastObject];
        
        if (element && [[element stringValue] isEqualToString: @"true"]) {
            customer.taxExempt = YES;
        } else {
            customer.taxExempt = NO;
        }
        
        nodes = [root elementsForName:@"Address"];
        element = [nodes lastObject];
        
        if (element) {
            // Now get the Customer Address
            nodes = [element elementsForName:@"CustomerAddress"];
            customerAddressElement = [nodes lastObject];
            
            if (customerAddressElement) {
                address = [[[Address alloc] init] autorelease];
                
                nodes = [customerAddressElement elementsForName:@"Address1"];
                element = [nodes lastObject];
                
                if (element) {
                    address.line1 = [element stringValue];
                }
                nodes = [customerAddressElement elementsForName:@"Address2"];
                element = [nodes lastObject];
                
                
                if (element) {
                    address.line2 = [element stringValue];
                }
                nodes = [customerAddressElement elementsForName:@"City"];
                element = [nodes lastObject];
                
                if (element) {
                    address.city = [element stringValue];
                }
                
                nodes = [customerAddressElement elementsForName:@"State"];
                element = [nodes lastObject];
                
                if (element) {
                    address.stateProv = [element stringValue];
                }
                
                nodes = [customerAddressElement elementsForName:@"Zip"];
                element = [nodes lastObject];
                
                if (element) {
                    address.zipPostalCode = [element stringValue];
                }
                
                customer.address = address;
            }
        }
        
        nodes = [root elementsForName:@"StoreID"];
        element = [nodes lastObject];
        
        if (element) {
            store = [[[Store alloc] init] autorelease];
            store.storeId = [NSNumber numberWithInt:[[element stringValue] intValue]];
            customer.store = store;
        }
    } 
    
    element = nil;
    errorElement = nil;
    customerAddressElement = nil;
    
    return customer;
    
}


@end
