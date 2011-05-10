//
//  ProductItemListXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 5/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ProductItemListXmlMarshaller.h"
#import "CXMLElement+CustomExtensions.h"

#import "ProductItem.h"

@implementation ProductItemListXmlMarshaller

- (id) toObject:(NSString *) xmlString {
    if (xmlString == nil) {
        return nil;
    }
    
    ProductItem *item = nil;
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Add the items to the list
    for (CXMLElement *node in [root elementsForName:@"Item"]) {
        item = [[ProductItem alloc] init];
        
        item.description = [node elementStringValue:@"ItemDescription"];
        item.itemId = [node elementNumberValue:@"ItemID"];
        item.sku = [node elementNumberValue:@"ItemNumber"];
        
        [itemList addObject:item];
        
        [item release];
        item = nil;
    }
    
    // Sort the items by description
    NSArray *returnList = nil;
    
    if ([itemList count] > 0) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"description"
                                                      ascending:NO] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        returnList = [[NSArray arrayWithArray: itemList] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        returnList = [NSArray arrayWithArray: itemList];
    }
    
    return returnList;
}

- (NSString *) toXml: (id) marshalObj {
    NSString *itemListXml = @"<ArrayOfItem />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[NSArray class]]) {
        // TODO: Do the marshalling code here.  Future iteration.
    }
    
    return itemListXml;
}
@end
