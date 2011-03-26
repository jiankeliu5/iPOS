//
//  ProductItemMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ProductItemXmlMarshaller.h"
#import "POSOxmUtils.h"

#import "ProductItem.h"

@implementation ProductItemXmlMarshaller

- (NSString *) toXml:(id)marshalObj {
    NSString *itemXml = @"<ItemClass />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[ProductItem class]]) {
        // TODO: Do the marshalling code here.  Future iteration.
    }
    
    return itemXml;
}

- (id) toObject:(NSString *)xmlString {
    if (xmlString == nil) {
        return nil;
    }
    
    // Map the object
    ProductItem *item = [[[ProductItem alloc] init] autorelease];
        
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    
    // Product Item Fields
    item.itemId = [root elementNumberValue:@"ItemID"];
    item.sku = [root elementNumberValue:@"ItemNumber"];
    item.description = [root elementStringValue:@"ItemDescription"];
    item.type = [root elementStringValue:@"ItemType"];
    item.typeId = [root elementNumberValue:@"ItemTypeID"];
    item.statusCode = [root elementStringValue:@"ItemStatusCode"];
    item.conversion = [root elementDecimalValue:@"Conversion"];
    item.binLocation = [root elementStringValue:@"BinLocation"];
    item.defaultToBox = [root elementBoolValue:@"DefaultToBox"];
    item.piecesPerBox = [root elementNumberValue:@"PiecesPerBox"];
    item.primaryUnitOfMeasure = [root elementStringValue:@"PrimaryUOM"];
    item.secondaryUnitOfMeasure = [root elementStringValue:@"SecondaryUOM"];
    item.priceGroupId = [root elementNumberValue:@"PriceGroupID"];
    item.retailPrice = [root elementDecimalValue:@"RetailPrice"];
    item.standardCost = [root elementDecimalValue:@"StdCost"];
    item.stockingCode = [root elementStringValue:@"StockingCode"];
    item.taxExempt = [root elementBoolValue:@"TaxExempt"];
    item.taxRate = [root elementDecimalValue:@"TaxRate"];
    item.vendorName = [root elementStringValue:@"VendorName"];
    
    // Store (Set the item on availability
    item.store = [POSOxmUtils toStore:root];
    if (item.store.availability) {
        item.store.availability.item = item;
    }
    
    // Distribution Centers
   item.distributionCenterList = [POSOxmUtils toDistributionCenterList:[root firstElementNamed:@"Distribution"] forItem: item];
    
    return item;
    
}
@end
