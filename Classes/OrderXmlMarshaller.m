//
//  OrderXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderXmlMarshaller.h"
#import "NSString+StringFormatters.h"

#import "POSOxmUtils.h"

#import "Order.h"

// Define constants
static NSString * const ORDER_STATUS_ROOT = @"<OrderStatus";

static NSString * const ORDER_XML = @""
"<OrderClass>"
    "<OrderHeader>"
        "<Customer>"
            "<CustomerID>%@</CustomerID>"
            "<CustomerTypeID>%@</CustomerTypeID>"
            "<TaxExempt>%@</TaxExempt>"
            "<Zip>%@</Zip>"
        "</Customer>"
        "${orderIdXml}"
        "<OrderTypeID>%@</OrderTypeID>"
        "<SalesPersonID>%@</SalesPersonID>"
        "<StoreID>%@</StoreID>"
        "<Notes>%@</Notes>"
        "<PurchaseOrder>%@</PurchaseOrder>"
        "<DepositAuthorizationID>%@</DepositAuthorizationID>"
        "<OrderDCTO>%@</OrderDCTO>"
        "<PromiseDate>%@</PromiseDate>"
        "<RequestDate>%@</RequestDate>"
        "<New>%@</New>"
    "</OrderHeader>"
    "<OrderDetail>"
        "${lineItemXml}"
    "</OrderDetail>"
"</OrderClass>";


static NSString * const ORDER_LINEITEM_XML = @""
    @"<Line>"
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
        @"${priceAuthorizationXml}"
        @"<PrimaryUOM>%@</PrimaryUOM>"
        @"<QuantityOrderedPrimary>%@</QuantityOrderedPrimary>"
        @"<QuantityOrderedSecondary>%@</QuantityOrderedSecondary>"
        @"<RetailPricePrimary>%@</RetailPricePrimary>"
        @"<SalesPersonID>%@</SalesPersonID>"
        @"<SecondaryUOM>%@</SecondaryUOM>"
        @"<SellingPricePrimary>%@</SellingPricePrimary>"
        @"<SellingPriceSecondary>%@</SellingPriceSecondary>"
        @"<StdCost>%@</StdCost>"
        @"<StockingCode>%@</StockingCode>"
        @"<StoreID>%@</StoreID>"
        @"<TaxExempt>%@</TaxExempt>"
        @"<TaxRate>%@</TaxRate>"
        @"<LOCN>%@</LOCN>"
        @"<LOTN>%@</LOTN>"
        @"<LineID>%@</LineID>"
        @"<MCU>%@</MCU>"
        @"<NXTR>%@</NXTR>"
        @"<OrderID>%@</OrderID>"
        @"<RequestDate>%@</RequestDate>"
        @"<ReturnReferenceID>%@</ReturnReferenceID>"
        @"<Spiff>%@</Spiff>"
        @"<Split>%@</Split>"
        @"<URRF>%@</URRF>"
        @"<LineState>%@</LineState>"
    @"</Line>";

#pragma mark -
#pragma mark Private Interface
@interface OrderXmlMarshaller()
-(Order *) toOrderFromOrderStatus: (NSString *) xmlString;
- (NSString *) orderItemsToXml: (Order *) order;
@end

@implementation OrderXmlMarshaller

#pragma mark -
-(id) toObject:(NSString *)xmlString {
    
    if (xmlString == nil) {
        return nil;
    }
    
    // Parse as an OrderStatus result (contains just OrderId and ErrorList)
    NSRange textRange = [xmlString rangeOfString:ORDER_STATUS_ROOT];
    if (textRange.location != NSNotFound) {
        return [self toOrderFromOrderStatus: xmlString];
    } 
    
    // Support for other elements not supported
    return nil;
}

-(NSString *) toXml:(id)marshalObj {
    NSString *orderXml = @"<OrderClass />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[Order class]]) {
        Order *order = (Order *) marshalObj;
        
        NSString *orderId = nil;
        NSString *orderTypeId = @"1";
        NSString *salespersonEmpId = @"";
        NSString *storeId = @"0";
        NSString *customerId = @"";
        NSString *customerTypeId = @"";
        NSString *customerTaxExempt = @"false";
        NSString *customerZip = @"";
        NSString *notes = @"";
        NSString *purchaseOrder = @"";
        NSString *depositAuthorizationID = @"";
        NSString *orderDCTO = @"";
        NSString *promiseDate = @"";
        NSString *requestDate = @"";
        NSString *new = @"";

        
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
        if (order.notes) {
            notes = order.notes;
        }
        if (order.purchaseOrderId) {
            purchaseOrder = order.purchaseOrderId;
        }
        
        if(order.depositAuthorizationID)
        {
            depositAuthorizationID = [order.depositAuthorizationID stringValue];
        }
        
        if (order.orderDCTO)
        {
            orderDCTO = order.orderDCTO;
        }
        
        if(order.promiseDate)
        {
            promiseDate = order.promiseDate;
        }
        
        if (order.requestDate)
        {
            requestDate = order.requestDate;
        }
        
        if(order.isNewOrder)
        {
            if (order.isNewOrder == NO)
            {
                new = @"false";
            }
            else{
                new = @"true";
            }
        }
        
        // Create the XML
        orderXml = [NSString stringWithFormat: ORDER_XML, customerId, customerTypeId, customerTaxExempt, customerZip, orderTypeId, salespersonEmpId, storeId, notes, purchaseOrder, depositAuthorizationID, orderDCTO, promiseDate, requestDate, new];
        
        // Perform any variable replacement (ignore the order id field if it is not there
        if (orderId) {
            orderXml = [POSOxmUtils replaceInXmlTemplate:orderXml parameter:@"orderIdXml" withValue:[POSOxmUtils genXmlElementWithName:@"OrderID" value:orderId]];
        } else {
            orderXml = [POSOxmUtils replaceInXmlTemplate:orderXml parameter:@"orderIdXml" withValue:@""];
        }
        
        
        // The Order items xml
        orderXml = [POSOxmUtils replaceInXmlTemplate:orderXml parameter:@"lineItemXml" withValue:[self orderItemsToXml:order]];
    }
    
    return orderXml;
}

#pragma mark -
#pragma mark Private
-(Order *) toOrderFromOrderStatus: (NSString *) xmlString {
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    Order *order = [[[Order alloc] init] autorelease];
    
    order.orderId = [root elementNumberValue:@"OrderID"];
    
    // Parse any errors
    [POSOxmUtils attachErrors:[root firstElementNamed:@"ErrorList"] toModel:order];
    
    return order;
}

-(NSString *) orderItemsToXml:(Order *)order {
    NSString *lineItemXml = @"";
    
    NSString *orderDetailsStatus = nil;
    NSString *lineNumber = nil;
    NSString *quantityPrimary = nil;
    NSString *quantitySecondary = nil;
    NSString *sellingPricePrimary = nil;
    NSString *sellingPriceSecondary = nil;
    
    NSString *conversion = nil;
    NSString *defaultToBox = nil;
    NSString *itemId = nil;
    NSString *itemNumber = nil;
    NSString *itemDescription = nil;
    NSString *itemStatusCode = nil;
    NSString *itemTypeId = nil;
    NSString *piecesPerBox = nil;
    NSString *primaryUom = nil;
    NSString *secondaryUom = nil;
    NSString *retailPrice = nil;
    NSString *salepersonEmpId = nil;
    NSString *stdCost = nil;
    NSString *stockingCode = nil;
    NSString *storeId = nil;
    NSString *taxExempt = nil;
    NSString *taxRate = nil;
    
    NSString *locn = @"";
    NSString *lotn = @"";
    NSString *lineID = @"";
    NSString *mcu = @"";
    NSString *nxtr = @"";
    NSString *orderID = @"";
    NSString *requestDate = @"";
    NSString *returnedReferenceID = @"";
    NSString *spiff = @"";
    NSString *split = @"";
    NSString *urrf = @"";
    NSString *lineState = @"";
    
    
    if (order) {
        NSArray *items = [order getOrderItems];
        
        if (items && [items count] > 0) {
            for (OrderItem *orderItem in items) {
                orderDetailsStatus = @"1";
                lineNumber = @"0";
                quantityPrimary = @"0";
                quantitySecondary = @"0";
                sellingPricePrimary = @"";
                sellingPriceSecondary = @"";
                conversion = @"0";
                defaultToBox = @"false";
                itemId = @"0";
                itemNumber = @"0";
                itemDescription = @"0";
                itemStatusCode = @"0";
                itemTypeId = @"0";
                piecesPerBox = @"0";
                primaryUom = @"0";
                secondaryUom = @"0";
                retailPrice = @"0";
                salepersonEmpId = @"0";
                stdCost = @"0";
                stockingCode = @"S";
                storeId = @"0";
                taxExempt = @"false";
                taxRate = @"0";
                
                if (orderItem.statusId) {
                    orderDetailsStatus = [NSString stringWithFormat: @"%@", orderItem.statusId];
                }
                if (orderItem.lineNumber) {
                    lineNumber = [NSString stringWithFormat: @"%@", orderItem.lineNumber];
                }
                if (orderItem.quantityPrimary) {
                    quantityPrimary = [NSString stringWithFormat: @"%@", orderItem.quantityPrimary];
                }
                if (orderItem.quantitySecondary) {
                    quantitySecondary = [NSString stringWithFormat: @"%@", orderItem.quantitySecondary];
                }
                if (orderItem.sellingPricePrimary) {
                    sellingPricePrimary = [NSString stringWithFormat: @"%@", orderItem.sellingPricePrimary];    
                }
                if (orderItem.sellingPriceSecondary) {
                    sellingPriceSecondary = [NSString stringWithFormat: @"%@", orderItem.sellingPriceSecondary];    
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
                if (orderItem.item.retailPricePrimary) {
                    retailPrice = [NSString stringWithFormat: @"%@", orderItem.item.retailPricePrimary]; 
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
                
                if (orderItem.locn)
                {
                    locn = orderItem.locn;
                }
                
                if (orderItem.lotn)
                {
                    lotn = orderItem.lotn;
                }
                
                if (orderItem.mcu)
                {
                    mcu = orderItem.mcu;
                }
                
                if (orderItem.nxtr)
                {
                    nxtr = orderItem.nxtr;
                }
                
                if (orderItem.orderId)
                {
                    orderID = [orderItem.orderId stringValue];
                }
                
                if (orderItem.requestDate)
                {
                    requestDate = orderItem.requestDate;
                }
                
                if (orderItem.returnReferenceId)
                {
                    returnedReferenceID = [orderItem.returnReferenceId stringValue];
                }
                
                if (orderItem.split)
                {
                    if (orderItem.split == NO)
                    {
                        split = @"false";
                    }
                    else {
                        split = @"true";
                    }
                }
                
                if(orderItem.urrf)
                {
                    urrf = orderItem.urrf;
                }
                
                switch (orderItem.lineStatus) {
                    case LineStatusAdd:
                        lineState = @"add";
                        break;
                    case LineStatusModify:
                        lineState = @"modify";
                        break;
                    case LineStatusCancel:
                        lineState = @"cancel";
                        break;
                    case LineStatusNone:
                    default:
                        lineState = @"";
                        break;
                }
                
                if(orderItem.spiff)
                {
                    spiff = [orderItem.spiff stringValue];
                }

                
                lineItemXml = [lineItemXml stringByAppendingFormat:ORDER_LINEITEM_XML, conversion, defaultToBox, itemId, itemNumber, itemDescription, itemStatusCode, itemTypeId, 
                               lineNumber, orderDetailsStatus, piecesPerBox, primaryUom, quantityPrimary, quantitySecondary, retailPrice, salepersonEmpId,
                               secondaryUom, sellingPricePrimary, sellingPriceSecondary, stdCost, stockingCode, storeId, taxExempt, taxRate, locn, lotn, lineID, mcu, nxtr, orderID, requestDate,returnedReferenceID, spiff, split, urrf, lineState];
                
                // Is there an authorization ID for selling price?
                if (orderItem.priceAuthorizationId) {
                    lineItemXml = [POSOxmUtils replaceInXmlTemplate:lineItemXml parameter:@"priceAuthorizationXml" 
                                                          withValue:[NSString stringWithFormat:@"<PriceAuthorizationID>%@</PriceAuthorizationID>", orderItem.priceAuthorizationId]];
                } else {
                    lineItemXml = [POSOxmUtils replaceInXmlTemplate:lineItemXml parameter:@"priceAuthorizationXml" withValue:@""];
                }
                
            }
        }
    }
    
    return lineItemXml;
}

@end
