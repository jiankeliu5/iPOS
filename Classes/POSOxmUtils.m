//
//  POSXmlUtils.m
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "POSOxmUtils.h"

#import "CXMLDocument.h"
#import "CXMLElement+CustomExtensions.h"
#import "DistributionCenter.h"

@implementation POSOxmUtils

#pragma mark -
#pragma mark XML To Object utilities
+ (void) attachErrors:(CXMLElement *)errorXmlElement toModel:(AbstractModel *)modelObj {
    
    if (errorXmlElement && modelObj) {
        NSArray *nodes = [errorXmlElement elementsForName:@"Error"];
        
        // Create the errors
        if ([nodes count] > 0) {        
            for (CXMLElement *node in nodes) {
                Error *error = [[[Error alloc] init] autorelease];
                error.errorId =  [node elementStringValue: @"ErrorID"]; 
                error.message = [node elementStringValue:@"ErrorMessage"];
                
                if (![error.errorId isEqualToString:@"0"] && ![error.message isEqualToString:@""]) {
                    [modelObj addError:error];
                }
            }
        }
    }
}

+ (Address *) toAddress:(CXMLElement *)addressXmlElement {

    if (addressXmlElement == nil) {
        return nil;
    }
    
    Address *address = [[[Address alloc] init] autorelease];
    
    address.line1 = [addressXmlElement elementStringValue:@"Address1"];
    address.line2 = [addressXmlElement elementStringValue:@"Address2"];
    address.city = [addressXmlElement elementStringValue:@"City"];
    address.stateProv = [addressXmlElement elementStringValue:@"State"];
    address.zipPostalCode = [addressXmlElement elementStringValue:@"Zip"];
    
    return address;
}

+ (Store *) toStore:(CXMLElement *)parentXmlElement {

    if (parentXmlElement == nil) {
        return nil;
    }
    
    NSNumber *storeId = [parentXmlElement elementNumberValue:@"StoreID"];
    NSDecimalNumber *available = [parentXmlElement elementDecimalValue:@"StoreAvailability"];
    NSDecimalNumber *onHand = [parentXmlElement elementDecimalValue:@"StoreOnHand"];
    
    Store *store = [[[Store alloc] init] autorelease];
    ItemAvailability *storeAvailability = [[[ItemAvailability alloc] init] autorelease];
    
    store.storeId = storeId;
    storeAvailability.available = available;
    storeAvailability.onHand = onHand;
    store.availability = storeAvailability;
    
    return store;
}

+ (NSArray *) toDistributionCenterList:(CXMLElement *)parentXmlElement forItem: (ProductItem *) item {

    if (parentXmlElement == nil) {
        return nil;
    }
    
   // Loop through the nodes of the element and add to array
    DistributionCenter *dc = nil;
    ItemAvailability *availability = nil;
    NSMutableArray *dcList = [[[NSMutableArray alloc] init] autorelease];        
    
    for (CXMLElement *node in [parentXmlElement elementsForName:@"DC"]) {
        dc = [[[DistributionCenter alloc] init] autorelease];
        ItemAvailability *availability = [[[ItemAvailability alloc] init] autorelease];
        
        dc.dcId = [node elementNumberValue:@"dcID"];
        dc.isPrimary = [node elementBoolValue:@"primary"];
        
        availability.available = [node elementDecimalValue:@"availability"];
        availability.onHand = [node elementDecimalValue:@"onHand"];
        availability.etaDateAsString = [node elementStringValue:@"eta"];
        
        availability.item = item;
        dc.availability = availability;
        
        [dcList addObject: dc];
        
        dc = nil;
        availability = nil;
    }
        
    // Copy to the item sorted with primary first
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"isPrimary"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [[NSArray arrayWithArray: dcList] sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark -
#pragma mark Object to XML utilities
+(NSString *) genXmlElementWithName:(NSString *)name value:(NSString *)value {
    if (name && value) {
        return [NSString stringWithFormat:@"<%@>%@</%@>", name, value, name];
    }
    
    return nil;
}
+ (NSString *) replaceInXmlTemplate: (NSString *) template parameter: (NSString *) parameter withValue: (NSString *) value {
    if (template && parameter && value) {
        NSString *placeholder = [NSString stringWithFormat:@"${%@}", parameter];
        return [template stringByReplacingOccurrencesOfString:placeholder withString:value];
    }
    
    return nil; 
}

#pragma mark -
#pragma mark Other Helper Utilities
+(BOOL) isXmlResultTrue:(NSString *)xmlString {
    // Create an XML document parser
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    BOOL isTrue = NO;
    
    // Parse the response to fetch the boolean result
    if (root != nil) {
        isTrue = [[root stringValue] boolValue];
    }
    
    // Return result
    return isTrue;    
}

@end
