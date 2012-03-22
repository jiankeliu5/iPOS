//
//  CustomerListXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 10/31/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "CustomerListXmlMarshaller.h"

#import "CXMLElement+CustomExtensions.h"

#import "Customer.h"

@implementation CustomerListXmlMarshaller

- (id) toObject:(NSString *)xmlString {
    if (xmlString == nil) {
        return nil;
    }
    
    Customer *cust = nil;
    NSMutableArray *custList = [NSMutableArray arrayWithCapacity:0];    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    // Add the items to the list
    for (CXMLElement *node in [root children]) {
        if (![node.name isEqualToString:@"text"]) {
            
        cust = [[Customer alloc] init];
        NSLog(@"Node is %@",node.name);
        
        cust.customerId = [node elementNumberValue:@"CustomerID"];
        cust.customerTypeId = [node elementNumberValue:@"CustomerTypeID"]; 
        cust.customerType = [node elementStringValue:@"CustomerType"];
        cust.phoneNumber = [node elementStringValue:@"CustomerPhone"];
        
        // Customer Name
        NSArray *names = [[node elementStringValue:@"CustomerName"] componentsSeparatedByString:@","];
        if ([names count] == 2) {
            cust.lastName = [(NSString *) [names objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            cust.firstName = [(NSString *) [names objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        } else {
            cust.firstName = [names objectAtIndex:0];
        }
        
        [custList addObject:cust];
        
        [cust release];
        cust = nil;
        }
    }
    
    // Sort the items by description
    NSArray *returnList = nil;
    
    if ([custList count] > 0) {
        NSSortDescriptor *lastNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"lastName"
                                                      ascending:YES] autorelease];
        NSSortDescriptor *firstNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                                            ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:lastNameDescriptor, firstNameDescriptor, nil];
        returnList = [[NSArray arrayWithArray: custList] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        returnList = [NSArray arrayWithArray: custList];
    }
    
    return returnList;
}

- (NSString *) toXml: (id) marshalObj {
    NSString *itemListXml = @"<ArrayOfCustomer />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[NSArray class]]) {
        // TODO: Do the marshalling code here.  Future iteration.
    }
    
    return itemListXml;
}

@end
