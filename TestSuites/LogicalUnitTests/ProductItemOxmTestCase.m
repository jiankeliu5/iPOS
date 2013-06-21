//
//  ProductItemOxmTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ProductItem.h"

@interface ProductItemOxmTestCase : SenTestCase

-(void) testProductItemFromXml;

@end

@implementation ProductItemOxmTestCase

- (void) testProductItemFromXml {
    NSString *itemXml = @"<ItemClass>"
                            "<BinLocation>TR0520</BinLocation>"
                            "<Conversion>1.0000000</Conversion>"
                            "<Distribution>"
                            "<DC>"
                            "<dcID>80600</dcID>"
                            "<availability>660</availability>"
                            "<onHand>200</onHand>"
                            "<primary>true</primary>"
                            "</DC>"
                            "<DC>"
                            "<dcID>81000</dcID>"
                            "<availability>660</availability>"
                            "<onHand>200</onHand>"
                            "<primary>true</primary>"
                            "</DC>"
                            "<DC>"
                            "<dcID>81100</dcID>"
                            "<availability>660</availability>"
                            "<onHand>200</onHand>"
                            "<primary>true</primary>"
                            "</DC>"
                            "</Distribution>"
                            "<ItemDescription>Driftwood Hon. Martel</ItemDescription>"
                            "<ItemID>283186</ItemID>"
                            "<ItemNumber>494700</ItemNumber>"
                            "<ItemStatusCode>S</ItemStatusCode>"
                            "<ItemType>Travertine</ItemType>"
                            "<ItemTypeID>26</ItemTypeID>"
                            "<PiecesPerBox>6</PiecesPerBox>"
                            "<PriceGroupID>17</PriceGroupID>"
                            "<PrimaryUOM>EA</PrimaryUOM>"
                            "<RetailPrice>18.9900</RetailPrice>"
                            "<SecondaryUOM>EA</SecondaryUOM>"
                            "<StdCost>3.9000</StdCost>"
                            "<StockingCode>S</StockingCode>"
                            "<StoreAvailability>13</StoreAvailability>"
                            "<StoreID>1200</StoreID>"
                            "<StoreOnHand>13</StoreOnHand>"
                            "<TaxExempt>false</TaxExempt>"
                            "<TaxRate>0.072750</TaxRate>"
                            "<VendorName>SHAO LIN STONE/CHINA METALLURGICAL</VendorName>"
                            "</ItemClass>";
                            
   ProductItem *item = [ProductItem fromXml:itemXml]; 
   
    STAssertNotNil(item, @"Expected item to not be nil");
    STAssertTrue([item.itemId isEqualToNumber:[NSNumber numberWithInt:283186]], @"The itemId does not match :-(");
}
@end
