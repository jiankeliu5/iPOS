//
//  OrderMarhsalling.m
//  iPOS
//
//  Created by Torey Lomenda on 3/21/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderMarshalling.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"

@interface OrderMarshalling()

    + (NSString *) orderItemToXml: (OrderItem *) orderItem from: (Order *) order;

@end


@implementation OrderMarshalling

#pragma mark -
#pragma mark Public implementation
+ (NSString *) toXml:(Order *)order {
    NSString *orderXml = @"<OrderClass />";
    
    // Set the defaults
    if (order) {
        NSString *orderId = @"0";
        NSString *orderTypeId = @"1";
        NSString *salespersonEmpId = @"";
        NSString *storeId = @"0";
        NSString *customerId = @"";
        NSString *customerTypeId = @"";
        NSString *customerTaxExempt = @"false";
        NSString *customerZip = @"";
        
        // Set the header element values from the order
        if (order.orderId) {
            orderId = [NSString stringWithFormat:@"%@", order.orderId]; 
        }
        if (order.orderTypeId) {
            orderTypeId = [NSString stringWithFormat:@"%@", order.orderTypeId]; 
        }
        if (order.salesPersonEmployeeId) {
            salespersonEmpId = [NSString stringWithFormat:@"%@", order.salesPersonEmployeeId]; 
        }
        if (order.store && order.store.storeId) {
            storeId = [NSString stringWithFormat:@"%@", order.store.storeId]; 
        }
        if (order.customer) {
            if (order.customer.customerId) {
                customerId = [NSString stringWithFormat:@"%@", order.customer.customerId]; 
            }
            if (order.customer.customerTypeId) {
                customerTypeId = [NSString stringWithFormat:@"%@", order.customer.customerTypeId]; 
            }
            if (order.customer.taxExempt) {
                customerTaxExempt = @"true";
            }
            if (order.customer.address && order.customer.address.zipPostalCode) {
                customerZip = order.customer.address.zipPostalCode;
            }
        }
        
        // Is this a new order or an existing order
        if ([orderId isEqualToString:@"0"]) {
            orderXml = [NSString stringWithFormat: @"<OrderClass>"
                        "<OrderHeader><Customer>"
                        "<CustomerID>%@</CustomerID>"
                        "<CustomerTypeID>%@</CustomerTypeID>"
                        "<TaxExempt>%@</TaxExempt>"
                        "<Zip>%@</Zip>"
                        "</Customer>"
                        "<OrderTypeID>%@</OrderTypeID>"
                        "<SalesPersonID>%@</SalesPersonID>"
                        "<StoreID>%@</StoreID>"
                        "</OrderHeader>"
                        "<OrderDetail>", customerId, customerTypeId, customerTaxExempt, customerZip, orderTypeId, salespersonEmpId, storeId];
        } else {
            orderXml = [NSString stringWithFormat: @"<OrderClass>"
                        "<OrderHeader><Customer>"
                        "<CustomerID>%@</CustomerID>"
                        "<CustomerTypeID>%@</CustomerTypeID>"
                        "<TaxExempt>%@</TaxExempt>"
                        "<ZipCode>%@</ZipCode>"
                        "</Customer>"
                        "<OrderID>%@</OrderID>"
                        "<OrderTypeID>%@</OrderTypeID>"
                        "<SalesPersonID>%@</SalesPersonID>"
                        "<StoreID>%@</StoreID>"
                        "</OrderHeader>"
                        "<OrderDetail>", customerId, customerTypeId, customerTaxExempt, customerZip, orderId, orderTypeId, salespersonEmpId, storeId];
        }
        
        // Add the order line items to the order XML
        NSArray *orderItemList = [order getOrderItems];
        if ([orderItemList count] > 0) {
            for (OrderItem *orderItem in orderItemList) {
                orderXml = [orderXml stringByAppendingString:[OrderMarshalling orderItemToXml:orderItem from:order]];
            }
        }
        
        orderXml = [orderXml stringByAppendingString:@"</OrderDetail></OrderClass>"];
    }
    return orderXml;    
}

+ (Order *) toObjectFromOrderReturn:(NSString *)orderReturnXml {
    Error *error = nil;
    NSArray *nodes = nil;
    NSArray *errorNodes = nil;
    CXMLElement *element = nil;
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:orderReturnXml options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    Order *order = [[[Order alloc] init] autorelease];
    
    nodes = [root elementsForName:@"OrderID"];
    element = [nodes lastObject];
    
    if (element) {
        order.orderId = [NSNumber numberWithInt:[[element stringValue] intValue]];
    }
    
    // Parse any errors
    nodes = [root elementsForName:@"ErrorList"];
    element = [nodes lastObject];
    if (element) {
        nodes = [element elementsForName:@"Error"];
        
    }
    
    // Create the errors
    if ([nodes count] > 0) {
        NSMutableArray *errorList = [NSMutableArray arrayWithCapacity:[nodes count]];
        
        for (CXMLElement *node in nodes) {
            error = [[[Error alloc] init] autorelease];
            
            errorNodes = [node elementsForName:@"ErrorID"];
            element = [errorNodes lastObject];
            
            if (element) {
                error.errorId = [element stringValue];
            }
            errorNodes = [node elementsForName:@"Message"];
            element = [errorNodes lastObject];
            if (element) {
                error.message = [element stringValue];
            }
            
            if (error.errorId && ![error.errorId isEqualToString:@""] && error.message && ![error.message isEqualToString:@""]) {
                [errorList addObject:error];
            }
        }
        
        order.errorList = [NSArray arrayWithArray:errorList];
    }
    
    return order;
}

#pragma mark -
#pragma mark Private implementation
+ (NSString *) orderItemToXml: (OrderItem *) orderItem from: (Order *) order {
    NSString *lineItemXml = @"<Line />";
    
    if (orderItem && orderItem.item) {
        // The Defaults
        NSString *orderDetailsStatus = @"1";
        NSString *lineNumber = @"0";
        NSString *quantity = @"0";
        NSString *sellingPrice = @"";
        
        NSString *conversion = @"0";
        NSString *defaultToBox = @"false";
        NSString *itemId = @"0";
        NSString *itemNumber = @"0";
        NSString *itemDescription = @"0";
        NSString *itemStatusCode = @"0";
        NSString *itemTypeId = @"0";
        NSString *piecesPerBox = @"0";
        NSString *primaryUom = @"0";
        NSString *secondaryUom = @"0";
        NSString *retailPrice = @"0";
        NSString *salepersonEmpId = @"0";
        NSString *stdCost = @"0";
        NSString *stockingCode = @"S";
        NSString *storeId = @"0";
        NSString *taxExempt = @"false";
        NSString *taxRate = @"0";
        
        if (orderItem.statusId) {
            orderDetailsStatus = [NSString stringWithFormat: @"%@", orderItem.statusId];
        }
        if (orderItem.lineNumber) {
            lineNumber = [NSString stringWithFormat: @"%@", orderItem.lineNumber];
        }
        if (orderItem.quantity) {
            quantity = [NSString stringWithFormat: @"%@", orderItem.quantity];
        }
        if (orderItem.sellingPrice) {
            sellingPrice = [NSString stringWithFormat: @"%@", orderItem.sellingPrice];
        }
        if (orderItem.item.conversion) {
            conversion = [NSString stringWithFormat: @"%@", orderItem.item.conversion];
        }
        if (orderItem.item.defaultToBox) {
            defaultToBox = @"true";
        }
        if (orderItem.item.itemId) {
            itemId = [NSString stringWithFormat: @"%@", orderItem.item.itemId];
        }
        if (orderItem.item.sku) {
            itemNumber = [NSString stringWithFormat: @"%@", orderItem.item.sku];
        }
        if (orderItem.item.description) {
            itemDescription = orderItem.item.description;
        }
        if (orderItem.item.statusCode) {
            itemStatusCode = orderItem.item.statusCode;
        }
        if (orderItem.item.typeId) {
            itemTypeId = [NSString stringWithFormat: @"%@", orderItem.item.typeId];
        }
        if (orderItem.item.piecesPerBox) {
            piecesPerBox = [NSString stringWithFormat: @"%@", orderItem.item.piecesPerBox];
        }
        if (orderItem.item.primaryUnitOfMeasure) {
            primaryUom = orderItem.item.primaryUnitOfMeasure;
        }
        if (orderItem.item.secondaryUnitOfMeasure) {
            secondaryUom = orderItem.item.secondaryUnitOfMeasure;
        }
        if (orderItem.item.retailPrice) {
            retailPrice = [NSString stringWithFormat: @"%@", orderItem.item.retailPrice];
        }
        if (order.salesPersonEmployeeId) {
            salepersonEmpId = [NSString stringWithFormat: @"%@", order.salesPersonEmployeeId];
        }
        if (orderItem.item.standardCost) {
            stdCost = [NSString stringWithFormat: @"%@", orderItem.item.standardCost];
        }
        if (orderItem.item.stockingCode) {
            stockingCode = orderItem.item.stockingCode;
        }
        if (orderItem.item.store && orderItem.item.store.storeId) {
            storeId = [NSString stringWithFormat: @"%@", orderItem.item.store.storeId];
        }
        if (orderItem.item.taxExempt) {
            taxExempt = @"true";
        }
        if (orderItem.item.taxRate) {
            taxRate = [NSString stringWithFormat: @"%@", orderItem.item.taxRate];
        }
        
        lineItemXml = [NSString stringWithFormat:@"<Line>"
                            @"<Conversion>%@</Conversion>"
                            @"<DefaultToBox>%@</DefaultToBox>"
                            @"<ItemID>%@</ItemID>"
                            @"<ItemNumber>%@</ItemNumber>"
                            @"<ItemDescription>%@</ItemDescription>"
                            @"<ItemStatusCode>%@</ItemStatusCode>"
                            @"<ItemTypeID>%@</ItemTypeID>"
                            @"<LineID>%@</LineID>"
                            @"<OrderDetailsStatusID>%@</OrderDetailsStatusID>"
                            @"<PiecesPerBox>%@</PiecesPerBox>"
                            @"<PrimaryUOM>%@</PrimaryUOM>"
                            @"<QuantityOrderedPrimary>%@</QuantityOrderedPrimary>"
                            @"<RetailPricePrimary>%@</RetailPricePrimary>"
                            @"<SalesPersonID>%@</SalesPersonID>"
                            @"<SecondaryUOM>%@</SecondaryUOM>"
                            @"<SellingPricePrimary>%@</SellingPricePrimary>"
                            @"<StdCost>%@</StdCost>"
                            @"<StockingCode>%@</StockingCode>"
                            @"<StoreID>%@</StoreID>"
                            @"<TaxExempt>%@</TaxExempt>"
                            @"<TaxRate>%@</TaxRate>"
                            @"</Line>",conversion, defaultToBox, itemId, itemNumber, itemDescription, itemStatusCode, itemTypeId, 
                                lineNumber, orderDetailsStatus, piecesPerBox, primaryUom, quantity, retailPrice, salepersonEmpId,
                                secondaryUom, sellingPrice, stdCost, stockingCode, storeId, taxExempt, taxRate];
    }
    
    return lineItemXml;
}


@end
