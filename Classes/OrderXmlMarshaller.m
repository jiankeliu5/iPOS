//
//  OrderXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderXmlMarshaller.h"
#import "NSString+StringFormatters.h"
#import "NSString+Extensions.h"

#import "POSOxmUtils.h"
#import "CustomerXmlMarshaller.h"

#import "Order.h"

// Define constants
static NSString * const ORDER_STATUS_ROOT = @"<OrderStatus";

static NSString * const NEW_ORDER_XML = @""
"<OrderClass>"
    "<OrderHeader>"
        "<Comment>%@</Comment>"
        "<Customer>"
            "<CustomerID>%@</CustomerID>"
            "<CustomerTypeID>%@</CustomerTypeID>"
            "<TaxExempt>%@</TaxExempt>"
            "<Zip>%@</Zip>"
        "</Customer>"
        "<OrderID>%@</OrderID>"
        "<OrderTypeID>%@</OrderTypeID>"
        "<PO>%@</PO>"
        "<SalesPersonID>%@</SalesPersonID>"
        "<StoreID>%@</StoreID>"
        "<New>true</New>"
    "</OrderHeader>"
    "<OrderDetail>"
        "${lineItemXml}"
    "</OrderDetail>"
"</OrderClass>";

static NSString * const NEW_ORDER_LINEITEM_XML = @""
@"<Line>"
    @"<Conversion>%@</Conversion>"
    @"<DefaultToBox>%@</DefaultToBox>"
    @"<ItemDescription>%@</ItemDescription>"
    @"<ItemID>%@</ItemID>"
    @"<ItemNumber>%@</ItemNumber>"
    @"<ItemStatusCode>%@</ItemStatusCode>"
    @"<ItemTypeID>%@</ItemTypeID>"
    @"<LineID>%@</LineID>"
    @"<LineState>add</LineState>"
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
@"</Line>";

static NSString * const PREVIOUS_ORDER_XML = @""
"<OrderClass>"
    "<OrderHeader>"
        "<Comment>%@</Comment>"
        "<Customer>"
            "<CustomerID>%@</CustomerID>"
            "<CustomerTypeID>%@</CustomerTypeID>"
            "<TaxExempt>%@</TaxExempt>"
            "<Zip>%@</Zip>"
        "</Customer>"
        "<DepositAuthorizationID>%@</DepositAuthorizationID>"
        "<FollowUpDate>%@</FollowUpDate>"
        "<OrderDCTO>%@</OrderDCTO>"
        "<OrderID>%@</OrderID>"
        "<OrderTypeID>%@</OrderTypeID>"
        "<PO>%@</PO>"
        "<PromiseDate>%@</PromiseDate>"
        "<RequestDate>%@</RequestDate>"
        "<SalesPersonID>%@</SalesPersonID>"
        "<SelectionID>%@</SelectionID>"
        "<StoreID>%@</StoreID>"
        "<New>false</New>"
    "</OrderHeader>"
    "<OrderDetail>"
        "${lineItemXml}"
    "</OrderDetail>"
"</OrderClass>";

static NSString * const PREVIOUSORDER_LINEITEM_XML = @""
    @"<Line>"
        @"<Conversion>%@</Conversion>"
        @"<DefaultToBox>%@</DefaultToBox>"
        @"<ItemDescription>%@</ItemDescription>"
        @"<ItemID>%@</ItemID>"
        @"<ItemNumber>%@</ItemNumber>"
        @"<ItemStatusCode>%@</ItemStatusCode>"
        @"<ItemTypeID>%@</ItemTypeID>"
        @"<LOCN>%@</LOCN>"
        @"<LOTN>%@</LOTN>"
        @"<LTTR>%@</LTTR>"
        @"<LineID>%@</LineID>"
        @"<LineState>%@</LineState>"
        @"<MCU>%@</MCU>"
        @"<NXTR>%@</NXTR>"
        @"<OpenItemStatus>%@</OpenItemStatus>"
        @"<OrderDetailsStatusID>%@</OrderDetailsStatusID>"
        @"<OrderID>%@</OrderID>"
        @"<PiecesPerBox>%@</PiecesPerBox>"
        @"${priceAuthorizationXml}"
        @"<PrimaryUOM>%@</PrimaryUOM>"
        @"<QuantityOrderedPrimary>%@</QuantityOrderedPrimary>"
        @"<QuantityOrderedSecondary>%@</QuantityOrderedSecondary>"
        @"<RequestDate>%@</RequestDate>"
        @"<RetailPricePrimary>%@</RetailPricePrimary>"
        @"<ReturnReferenceID>%@</ReturnReferenceID>"
        @"<SalesPersonID>%@</SalesPersonID>"
        @"<SecondaryUOM>%@</SecondaryUOM>"
        @"<SellingPricePrimary>%@</SellingPricePrimary>"
        @"<SellingPriceSecondary>%@</SellingPriceSecondary>"
        @"<Spiff>%@</Spiff>"
        @"<Split>%@</Split>"
        @"<StdCost>%@</StdCost>"
        @"<StockingCode>%@</StockingCode>"
        @"<StoreID>%@</StoreID>"
        @"<TaxExempt>%@</TaxExempt>"
        @"<TaxRate>%@</TaxRate>"
        @"<URRF>%@</URRF>"
    @"</Line>";

#pragma mark -
#pragma mark Private Interface
@interface OrderXmlMarshaller()
-(Order *) toOrderFromOrderStatus: (NSString *) xmlString;
-(Order *) toOrderFromOrderDetail: (NSString *) xmlString;

- (NSString *) orderItemsToXml: (Order *) order;
@end

@implementation OrderXmlMarshaller

#pragma mark -
-(id) toObject:(NSString *)xmlString {
    Order *orderDetails = nil;
    
    if (xmlString == nil) {
        return nil;
    }
    
    // Parse as an OrderStatus result (contains just OrderId and ErrorList)
    NSRange textRange = [xmlString rangeOfString:ORDER_STATUS_ROOT];
    if (textRange.location != NSNotFound) {
        orderDetails = [self toOrderFromOrderStatus: xmlString];
    } else {
        orderDetails = [self toOrderFromOrderDetail: xmlString];
    }
    
    // Support for other elements not supported
    return orderDetails;
}

-(NSString *) toXml:(id)marshalObj {
    NSString *orderXml = @"<OrderClass />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[Order class]]) {
        Order *order = (Order *) marshalObj;
        
        NSString *customerId = @"";
        NSString *customerTypeId = @"";
        NSString *customerTaxExempt = @"false";
        NSString *customerZip = @"";
        
        NSString *orderId = @"";
        NSString *orderTypeId = @"1"; // Default to Quote
        NSString *salespersonEmpId = @"";
        NSString *storeId = @"0";
       
        
        // For existing/previous orders
        NSString *commentNotes = @"";
        NSString *depositAuthorizationID = @"0";
        NSString *followUpDate = @"";
        NSString *orderDCTO = @"";
        NSString *purchaseOrder = @"";
        NSString *promiseDate = @"";
        NSString *requestDate = @"";
        NSString *selectionId = @"0";
        
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
            commentNotes = order.notes;
        }
        if (order.purchaseOrderId) {
            purchaseOrder = order.purchaseOrderId;
        }
        
        if (orderId) {
            if(order.depositAuthorizationID) {
                depositAuthorizationID = [order.depositAuthorizationID stringValue];
            }
            
            if (order.orderDCTO) {
                orderDCTO = order.orderDCTO;
            }
            
            if(order.followUpDate) {
                promiseDate = order.followUpDate;
            }
            
            if(order.promiseDate) {
                promiseDate = order.promiseDate;
            }
            
            if (order.requestDate) {
                requestDate = order.requestDate;
            }
            
            if (order.selectionId) {
                selectionId = [NSString stringWithFormat:@"%@", order.selectionId]; 
            }
        }
        
        // Create the XML (new or previous)
        if ([orderId isNotEmpty] && !order.isNewOrder) {
             orderXml = [NSString stringWithFormat: PREVIOUS_ORDER_XML, 
                            commentNotes, customerId, customerTypeId, customerTaxExempt, customerZip,
                            depositAuthorizationID, followUpDate, orderDCTO, orderId, orderTypeId, purchaseOrder,
                            promiseDate, requestDate, salespersonEmpId, selectionId, storeId];
        } else {
            orderXml = [NSString stringWithFormat: NEW_ORDER_XML, 
                            commentNotes, customerId, customerTypeId, customerTaxExempt, customerZip,
                            orderId, orderTypeId, purchaseOrder, salespersonEmpId, storeId];
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

- (Order *) toOrderFromOrderDetail:(NSString *)xmlString {
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    Order *order = [[[Order alloc] init] autorelease];
    
    // Attach any errors
    [POSOxmUtils attachErrors: [root firstElementNamed:@"ErrorList"] toModel:order];
    
    CXMLElement *headerNode = [root firstElementNamed:@"OrderHeader"];
    
    // Order Header
    order.notes = [headerNode elementStringValue:@"Comment"];
    order.depositAuthorizationID = [headerNode elementNumberValue:@"DepositAuthorizationID"];
    order.followUpDate = [headerNode elementStringValue:@"FollowUpDate"];
    order.orderDCTO = [headerNode elementStringValue:@"OrderDCTO"];
    order.orderId = [headerNode elementNumberValue:@"OrderID"];
    order.orderTypeId = [headerNode elementNumberValue:@"OrderTypeID"];
    order.purchaseOrderId = [headerNode elementStringValue:@"PO"];
    order.promiseDate = [headerNode elementStringValue:@"PromiseDate"];
    order.requestDate = [headerNode elementStringValue:@"RequestDate"];
    order.salesPersonEmployeeId = [headerNode elementNumberValue:@"SalesPersonID"];
    order.selectionId = [headerNode elementNumberValue:@"SelectionID"];
    order.taxExempt = [headerNode elementBoolValue:@"TaxExempt"];
    
    // Add the Customer
    CustomerXmlMarshaller *customerXmlMarshaller = [[CustomerXmlMarshaller alloc] init];
    Customer *customer = [customerXmlMarshaller toObjectFromXmlElement: [headerNode firstElementNamed:@"Customer"]];
    
    order.customer = customer;
    [customerXmlMarshaller release];
    
    // Add the store where the order originated
    Store *store = [[Store alloc] init];
    store.storeId = [headerNode elementNumberValue:@"StoreID"];
    
    order.store = store;
    [store release];
    store = nil;
    
    
    // Add the inidividual line items
    OrderItem *orderItem = nil;
    ProductItem *productItem = nil;
    
    CXMLElement *productItems = [root firstElementNamed:@"OrderDetail"];
    
    for (CXMLElement *node in [productItems elementsForName:@"Line"]) {
        productItem = [[ProductItem alloc] init];
        
        // Standard Elements
        productItem.conversion = [node elementDecimalValue:@"Conversion"];
        productItem.defaultToBox = [node elementBoolValue:@"DefaultToBox"];
        productItem.description = [node elementStringValue:@"ItemDescription"];
        productItem.itemId = [node elementNumberValue:@"ItemID"];
        productItem.sku = [node elementStringValue:@"ItemNumber"];
        productItem.statusCode = [node elementStringValue:@"ItemStatusCode"];
        productItem.typeId = [node elementNumberValue:@"ItemTypeID"];
        productItem.piecesPerBox = [node elementNumberValue:@"PiecesPerBox"];
        productItem.primaryUnitOfMeasure = [node elementStringValue:@"PrimaryUOM"];
        productItem.priceGroupId = [root elementNumberValue:@"PriceGroupID"];
        productItem.retailPricePrimary = [node elementDecimalValue:@"RetailPricePrimary"];
        productItem.secondaryUnitOfMeasure = [node elementStringValue:@"SecondaryUOM"];
        productItem.standardCost = [node elementDecimalValue:@"StdCost"];
        productItem.stockingCode = [node elementStringValue:@"StockingCode"];
        productItem.taxExempt = [node elementBoolValue:@"TaxExempt"];
        productItem.taxRate = [node elementDecimalValue:@"TaxRate"];
        
        // Set the store for the product item
        Store *productStore = [POSOxmUtils toStore:node];
        productItem.store = productStore; 
        
        // Create the order item and set its properties
        orderItem = [[OrderItem alloc] initWithItem:productItem AndQuantity:[node elementDecimalValue:@"QuantityOrderedPrimary"]];
        orderItem.orderId = order.orderId;
        orderItem.locn = [node elementStringValue:@"LOCN"];
        orderItem.lotn = [node elementStringValue:@"LOTN"];
        orderItem.lttr = [node elementStringValue:@"LTTR"];
        orderItem.lineNumber = [node elementNumberValue:@"LineID"];
        orderItem.mcu = [node elementStringValue:@"MCU"];
        orderItem.nxtr = [node elementStringValue:@"NXTR"];
        orderItem.openItemStatus = [node elementStringValue:@"OpenItemStatus"];
        orderItem.statusId = [node elementNumberValue:@"OrderDetailStatusID"];
        orderItem.priceAuthorizationId = [node elementNumberValue:@"PriceAuthorizationID"];
        orderItem.quantityPrimary = [node elementDecimalValue:@"QuantityOrderedPrimary"];
        orderItem.quantitySecondary = [node elementDecimalValue:@"QuantityOrderedSecondary"];
        orderItem.requestDate = [node elementStringValue:@"RequestDate"];
        orderItem.returnReferenceId = [node elementNumberValue:@"ReturnReferenceID"];
        orderItem.salesPersonEmployeeId = [node elementNumberValue:@"SalesPersonID"];
        orderItem.sellingPricePrimary = [node elementDecimalValue:@"SellingPricePrimary"];
        orderItem.sellingPriceSecondary = [node elementDecimalValue:@"SellingPriceSecondary"];
        orderItem.spiff = [node elementNumberValue:@"Spiff"];
        orderItem.split = [node elementBoolValue:@"Split"];
        orderItem.urrf = [node elementStringValue:@"ItemNumber"];
        
        // Flag the item as not new and not modified
        orderItem.isNew = NO;
        orderItem.isModified = NO;
        
        [order addOrderItemToOrder:orderItem];
        
        [productItem release];
        productItem = nil;
        
        [orderItem release];
        orderItem = nil;
    }
    
    if (order.orderId) {
        // Flag the item as not new and not modified
        order.isNewOrder = NO;
    }
    
    return order;
}

-(NSString *) orderItemsToXml:(Order *)order {
    NSString *lineItemXml = @"";

    NSString *conversion = nil;
    NSString *defaultToBox = nil;
    NSString *itemId = nil;
    NSString *itemDescription = nil;
    NSString *itemNumber = nil;
    NSString *itemStatusCode = nil;
    NSString *itemTypeId = nil;
    NSString *lineNumber = @"";
    NSString *lineState = @"";
    NSString *openItemStatus = @"";
    NSString *orderDetailStatus = nil;
    NSString *piecesPerBox = nil;
    NSString *primaryUom = nil;
    NSString *quantityPrimary = nil;
    NSString *quantitySecondary = nil;
    NSString *retailPrice = nil;
    NSString *salepersonEmpId = nil;
    NSString *secondaryUom = nil;
    NSString *sellingPricePrimary = nil;
    NSString *sellingPriceSecondary = nil;
    NSString *stdCost = nil;
    NSString *stockingCode = nil;
    NSString *storeId = nil;
    NSString *taxExempt = nil;
    NSString *taxRate = nil;
    
    // New elements for existing/previous orders
    NSString *locn = @"";
    NSString *lotn = @"";
    NSString *lttr = @"";
    NSString *mcu = @"";
    NSString *nxtr = @"";
    NSString *orderId = @"";
    NSString *requestDate = @"";
    NSString *returnedReferenceID = @"0";
    NSString *spiff = @"0";
    NSString *split = @"false";
    NSString *urrf = @"";
    
    if (order) {
        NSArray *items = [order getOrderItems];
        
        if (items && [items count] > 0) {
            for (OrderItem *orderItem in items) {
                conversion = @"1.00000";
                defaultToBox = @"false";
                itemId = @"0";
                itemDescription = @"";
                itemNumber = @"0";
                itemStatusCode = @"0";
                itemTypeId = @"0";
                lineNumber = @"0";
                openItemStatus = @"";
                orderDetailStatus = @"1";
                piecesPerBox = @"0";
                primaryUom = @"0";
                quantityPrimary = @"0";
                quantitySecondary = @"0";
                retailPrice = @"0";
                salepersonEmpId = @"0";
                secondaryUom = @"0";
                sellingPricePrimary = @"0";
                sellingPriceSecondary = @"0";
                stdCost = @"0";
                stockingCode = @"S";
                storeId = @"0";
                taxExempt = @"false";
                taxRate = @"0";
                
                // New elements for existing/previous orders
                locn = @"";
                lotn = @"";
                lttr = @"";
                mcu = @"";
                nxtr = @"";
                orderId = @"0";
                requestDate = @"";
                returnedReferenceID = @"0";
                spiff = @"0";
                split = @"false";
                urrf = @"";

                if (orderItem.item.conversion) {
                    conversion = [NSString stringWithFormat: @"%@", orderItem.item.conversion];
                }
                if (orderItem.item.defaultToBox) {
                    defaultToBox = @"true";
                }
                if (orderItem.item.itemId) {
                    itemId = [NSString stringWithFormat: @"%@", orderItem.item.itemId];
                }
                if (orderItem.item.description) {
                    itemDescription = orderItem.item.description;
                }
                if (orderItem.item.sku) {
                    itemNumber = [NSString stringWithFormat: @"%@", orderItem.item.sku];
                }
                if (orderItem.item.statusCode) {
                    itemStatusCode = orderItem.item.statusCode;
                }
                if (orderItem.item.typeId) {
                    itemTypeId = [NSString stringWithFormat: @"%@", orderItem.item.typeId];
                }
                if (orderItem.lineNumber) {
                    lineNumber = [NSString stringWithFormat: @"%@", orderItem.lineNumber];
                }
                
                // Determine the lineStatus
                switch ([orderItem getLineStatus]) {
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
                        lineState = @"nochange";
                        break;
                }
                
                if (orderItem.openItemStatus) {
                    openItemStatus = orderItem.openItemStatus;
                }
                if (orderItem.statusId) {
                    orderDetailStatus = [NSString stringWithFormat: @"%@", orderItem.statusId];
                }
                if (orderItem.item.piecesPerBox) {
                    piecesPerBox = [NSString stringWithFormat: @"%@", orderItem.item.piecesPerBox];
                }
                if (orderItem.item.primaryUnitOfMeasure) {
                    primaryUom = orderItem.item.primaryUnitOfMeasure;
                }
                if (orderItem.quantityPrimary) {
                    quantityPrimary = [NSString stringWithFormat: @"%@", orderItem.quantityPrimary];
                }
                if (orderItem.quantitySecondary) {
                    quantitySecondary = [NSString stringWithFormat: @"%@", orderItem.quantitySecondary];
                }
                if (orderItem.item.retailPricePrimary) {
                    retailPrice = [NSString stringWithFormat: @"%@", orderItem.item.retailPricePrimary]; 
                }
                if (orderItem.salesPersonEmployeeId) {
                    salepersonEmpId = [NSString stringWithFormat: @"%@", orderItem.salesPersonEmployeeId];
                } else if (order.salesPersonEmployeeId) {
                    salepersonEmpId = [NSString stringWithFormat: @"%@", order.salesPersonEmployeeId];
                }
                if (orderItem.item.secondaryUnitOfMeasure) {
                    secondaryUom = orderItem.item.secondaryUnitOfMeasure;
                }
                if (orderItem.sellingPricePrimary) {
                    sellingPricePrimary = [NSString stringWithFormat: @"%@", orderItem.sellingPricePrimary];    
                }
                if (orderItem.sellingPriceSecondary) {
                    sellingPriceSecondary = [NSString stringWithFormat: @"%@", orderItem.sellingPriceSecondary];    
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
                
                // New items
                if (orderItem.locn) {
                    locn = orderItem.locn;
                }
                if (orderItem.lotn) {
                    lotn = orderItem.lotn;
                }
                if (orderItem.lttr) {
                    lotn = orderItem.lttr;
                }
                if (orderItem.mcu) {
                    mcu = orderItem.mcu;
                }
                if (orderItem.nxtr) {
                    nxtr = orderItem.nxtr;
                }
                
                if (orderItem.orderId) {
                    orderId = [orderItem.orderId stringValue];
                } else if (order.orderId) {
                    orderId = [order.orderId stringValue];
                }
                
                if (orderItem.requestDate) {
                    requestDate = orderItem.requestDate;
                }
                
                if (orderItem.returnReferenceId) {
                    returnedReferenceID = [orderItem.returnReferenceId stringValue];
                }
                
                if (orderItem.split) {
                    split = @"true";
                }
                
                if(orderItem.urrf) {
                    urrf = orderItem.urrf;
                }
                
                if (orderId && !order.isNewOrder) {
                    lineItemXml = [lineItemXml stringByAppendingFormat:PREVIOUSORDER_LINEITEM_XML,
                                    conversion, defaultToBox, itemDescription, itemId, itemNumber, itemStatusCode, itemTypeId,
                                    locn, lotn, lttr, lineNumber, lineState, mcu, nxtr, openItemStatus, orderDetailStatus, orderId,
                                    piecesPerBox, primaryUom, quantityPrimary, quantitySecondary, requestDate, retailPrice, returnedReferenceID,
                                    salepersonEmpId, secondaryUom, sellingPricePrimary, sellingPriceSecondary, spiff, split, stdCost, stockingCode, storeId, 
                                    taxExempt, taxRate, urrf];
                } else {
                    lineItemXml = [lineItemXml stringByAppendingFormat:NEW_ORDER_LINEITEM_XML,
                                    conversion, defaultToBox, itemDescription, itemId, itemNumber, itemStatusCode, itemTypeId, 
                                    lineNumber, orderDetailStatus, piecesPerBox, primaryUom, quantityPrimary, quantitySecondary,
                                    retailPrice, salepersonEmpId, secondaryUom, sellingPricePrimary, sellingPriceSecondary, 
                                    stdCost, stockingCode, storeId, taxExempt, taxRate];
                }
                
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
