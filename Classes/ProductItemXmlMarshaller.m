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
#import "iPOSFacade.h"

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
    //Enning Tang check availability 11/19/2012
    //ProductItem *StoreItem = [[[ProductItem alloc] init] autorelease];
    //iPOSFacade *facade;
    //facade = [iPOSFacade sharedInstance];
    
        
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    
    // Product Item Fields
    item.itemId = [root elementNumberValue:@"ItemID"];
    item.sku = [root elementStringValue:@"ItemNumber"];
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
    item.retailPricePrimary = [root elementDecimalValue:@"RetailPricePrimary"];
    item.retailPriceSecondary = [root elementDecimalValue:@"RetailPriceSecondary"];
    item.standardCost = [root elementDecimalValue:@"StdCost"];
    item.stockingCode = [root elementStringValue:@"StockingCode"];
    item.taxExempt = [root elementBoolValue:@"TaxExempt"];
    item.taxRate = [root elementDecimalValue:@"TaxRate"];
    item.vendorName = [root elementStringValue:@"VendorName"];
    //Enning Tang Add SellingPrice 8/23/2013
    item.sellingPricePrimary = [root elementDecimalValue:@"SellingPricePrimary"];
    item.sellingPriceSecondary = [root elementDecimalValue:@"SellingPriceSecondary"];
    //Enning Tang 8/23/2013 round up numbers before doing calculation
    NSDecimalNumberHandler *roundingUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2
                                                                                     raiseOnExactness:NO raiseOnOverflow:NO
                                                                                     raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    //item.retailPricePrimary = [item.retailPricePrimary decimalNumberByRoundingAccordingToBehavior:roundingUp];
    //item.retailPriceSecondary = [item.retailPriceSecondary decimalNumberByRoundingAccordingToBehavior:roundingUp];
    item.sellingPricePrimary = [item.sellingPricePrimary decimalNumberByRoundingAccordingToBehavior:roundingUp];
    item.sellingPriceSecondary = [item.sellingPriceSecondary decimalNumberByRoundingAccordingToBehavior:roundingUp];
    NSLog(@"RetailPricePrimary: %@", item.retailPricePrimary.stringValue);
    NSLog(@"RetailPriceSecondary: %@", item.retailPriceSecondary.stringValue);
    NSLog(@"After rounding:");
    NSLog(@"SellingPricePrimary: %@", item.sellingPricePrimary);
    NSLog(@"SellingPriceSecondary: %@", item.sellingPriceSecondary);
    
    // Determine selected UOM.  If there is a conversion select the second UOM as the default
    if (![item.primaryUnitOfMeasure isEqualToString:item.secondaryUnitOfMeasure] && [item.conversion compare: [NSDecimalNumber decimalNumberWithString:@"1.0"]] != NSOrderedSame) {
        item.selectedUOM = UOMSecondary;
    } else {
        item.selectedUOM = UOMPrimary;
    }
    
    
    // Store (Set the item on availability
    item.store = [POSOxmUtils toStore:root];
    if (item.store.availability) {
        item.store.availability.item = item;
    }
    
    //Enning Tang Change check store availability to shiptostore
    //StoreItem = [facade lookupProductItemByStore:item.sku withStoreid:item.ShipToStoreID];
    //if (item.store.availability) {
    //    item.store.availability.item = StoreItem;
    //    NSLog(@"Store Ava storeid = %@", StoreItem.store.storeId.stringValue);
    //}
    //==========================================================
    
    // Distribution Centers
   item.distributionCenterList = [POSOxmUtils toDistributionCenterList:[root firstElementNamed:@"Distribution"] forItem: item];
    
    return item;
    
}
@end
