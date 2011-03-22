//
//  OxmMarshallingTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 3/21/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OxmMarshallingTestCase.h"
#import "OrderMarshalling.h"

@implementation OxmMarshallingTestCase

-(void) testOrderFromOrderReturnXml {
    Order *order = [OrderMarshalling toObjectFromOrderReturn: @"<OrderReturn>"
                    "<ErrorList><Error><ErrorID>1</ErrorID><Message>Error1</Message></Error>"
                    "<Error><ErrorID>2</ErrorID><Message>Error2</Message></Error></ErrorList>"
                    "<OrderID>1234</OrderID></OrderReturn>"];
 
    STAssertNotNil(order, @"Expected Order to not be nil");                                   
    STAssertEquals([order.orderId intValue], 1234, @"I expected this to be equal to 1234");
    STAssertNotNil(order.errorList, @"Expected Order Error List to not be nil");  
    STAssertTrue([order.errorList count] == 2, @"I expected error count to be equal to 2");
}

-(void) testXmlFromOrder {
    Order *order = [[[Order alloc] init] autorelease];
    Customer *customer = [[[Customer alloc] init] autorelease];
    Store *store = [[[Store alloc] init] autorelease];
    ProductItem *item= [[[ProductItem alloc] init] autorelease];
    
    // Build the store
    store.storeId = [NSNumber numberWithInt:1234];
    
    // Build the item
    item.store = store;
    item.itemId = [NSNumber numberWithInt:1414];
    item.sku = [NSNumber numberWithInt:232323];
    item.description = @"Some product";
    item.defaultToBox = YES;
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    item.statusCode = @"S";
    item.typeId = [NSNumber numberWithInt:1];
    item.piecesPerBox = [NSNumber numberWithInt: 12];
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.retailPrice = [NSDecimalNumber decimalNumberWithString:@"3.75"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"2.70"]; 
    item.stockingCode = @"S";
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    
    
    // Build the customer
    customer.customerId = [NSNumber numberWithInt:1414];
    customer.taxExempt = NO;
    customer.customerTypeId = [NSNumber numberWithInt:1];
    customer.address = [[[Address alloc] init] autorelease];
    customer.address.zipPostalCode = @"55044";
    
    // Build the order
    order.salesPersonEmployeeId = [NSNumber numberWithInt:1111];
    order.store = store;
    order.customer = customer;
    order.orderTypeId = [NSNumber numberWithInt:1];
    [order addItemToOrder:item withQuantity:[NSDecimalNumber decimalNumberWithString:@"24.5"]];
    
    // Render the xml
    NSString *xml = [OrderMarshalling toXml:order];
    
    STAssertNotNil(xml, @"Expected an XML String");
    STAssertTrue([xml isEqualToString:@"<OrderClass>"
                  "<OrderHeader><Customer><CustomerID>1414</CustomerID><CustomerTypeID>1</CustomerTypeID><TaxExempt>false</TaxExempt><ZipCode>55044</ZipCode></Customer>"
                  "<OrderTypeID>1</OrderTypeID><SalesPersonID>1111</SalesPersonID><StoreID>1234</StoreID></OrderHeader>"
                  "<OrderDetail><Line><Conversion>1</Conversion><DefaultToBox>true</DefaultToBox><ItemID>1414</ItemID><ItemNumber>232323</ItemNumber>"
                  "<ItemDescription>Some product</ItemDescription><ItemStatusCode>S</ItemStatusCode><ItemTypeID>1</ItemTypeID>"
                  "<LineID>1</LineID><OrderDetailsStatusID>1</OrderDetailsStatusID><PiecesPerBox>12</PiecesPerBox><PrimaryUOM>EA</PrimaryUOM>"
                  "<QuantityOrderedPrimary>24.5</QuantityOrderedPrimary><RetailPricePrimary>3.75</RetailPricePrimary>"
                  "<SalesPersonID>1111</SalesPersonID><SecondaryUOM>EA</SecondaryUOM><SellingPricePrimary>3.75</SellingPricePrimary>"
                  "<StdCost>2.7</StdCost><StockingCode>S</StockingCode><StoreID>1234</StoreID><TaxExempt>false</TaxExempt>"
                  "<TaxRate>0.7</TaxRate></Line></OrderDetail></OrderClass>"], xml);
}

@end
