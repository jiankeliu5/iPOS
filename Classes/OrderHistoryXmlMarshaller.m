//
//  OrderHistoryXmlMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderHistoryXmlMarshaller.h"
#import "POSOxmUtils.h"
#import "Customer.h"
#import "ProductItem.h"
#import "Order.h"
#import "CustomerXmlMarshaller.h"
#import "OrderXmlMarshaller.h"
#import "OrderXmlMarshaller.h"
#import "OrderItem.h"

@implementation OrderHistoryXmlMarshaller

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) toObject:(NSString *)xmlString {
    
       
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];

    
    
    CustomerXmlMarshaller *customerXmlMarshaller = [[CustomerXmlMarshaller alloc] init];
    
    Order *order = [[[Order alloc] init] autorelease];
    
    [POSOxmUtils attachErrors: [root firstElementNamed:@"ErrorList"] toModel:order];
    
    CXMLElement *headerNode = [root firstElementNamed:@"OrderHeader"];
    
    
    order.depositAuthorizationID = [headerNode elementNumberValue:@"DepositAuthorizationID"];
    order.followUpdate = [headerNode elementStringValue:@"FollowUpDate"];
    order.orderDCTO = [headerNode elementStringValue:@"OrderDCTO"];
    order.orderId = [headerNode elementNumberValue:@"OrderID"];
    order.orderTypeId = [headerNode elementNumberValue:@"OrderTypeID"];
    order.purchaseOrderId = [headerNode elementStringValue:@"PO"];
    order.promiseDate = [headerNode elementStringValue:@"PromiseDate"];
    order.requestDate = [headerNode elementStringValue:@"RequestDate"];
    order.salesPersonEmployeeId = [headerNode elementNumberValue:@"SalesPersonID"];
    order.selectionId = [headerNode elementNumberValue:@"SelectionID"];
    //order.storeId = [root elementStringValue:@"StoreID"];
    order.taxExempt = [headerNode elementBoolValue:@"TaxExempt"];

    OrderItem *orderHistoryItem = nil;
    ProductItem *productItem = nil;
    
    CXMLElement *productItems = [root firstElementNamed:@"OrderDetail"];
    
     for (CXMLElement *node in [productItems elementsForName:@"Line"]) {
         
                  
         productItem = [[ProductItem alloc] init];
         productItem.itemId = [node elementNumberValue:@"ItemID"];
         productItem.description = [node elementStringValue:@"ItemDescription"];
         productItem.statusCode = [node elementStringValue:@"ItemStatusCode"];
         productItem.typeId = [node elementNumberValue:@"ItemTypeID"];
         productItem.primaryUnitOfMeasure = [node elementStringValue:@"PrimaryUOM"];
         productItem.retailPricePrimary = [node elementDecimalValue:@"RetailPricePrimary"];
         productItem.secondaryUnitOfMeasure = [node elementStringValue:@"SecondaryUOM"];
         productItem.standardCost = [node elementDecimalValue:@"StdCost"];
         productItem.stockingCode = [node elementStringValue:@"StockingCode"];
         productItem.taxExempt = [node elementBoolValue:@"TaxExempt"];
         productItem.taxRate = [node elementDecimalValue:@"TaxRate"];
         productItem.sku = [node elementStringValue:@"ItemNumber"];
         
         orderHistoryItem = [[OrderItem alloc] initWithItem:productItem AndQuantity:[node elementDecimalValue:@"QuantityOrderedPrimary"]];
         orderHistoryItem.lineNumber = [node elementNumberValue:@"LineID"];
         orderHistoryItem.statusId = [node elementNumberValue:@"OrderDetailStatusID"];
         orderHistoryItem.sellingPricePrimary = [node elementDecimalValue:@"SellingPricePrimary"];
         orderHistoryItem.sellingPriceSecondary = [node elementDecimalValue:@"SellingPriceSecondary"];
         orderHistoryItem.quantityPrimary = [node elementDecimalValue:@"QuantityOrderedPrimary"];
         orderHistoryItem.quantitySecondary = [node elementDecimalValue:@"QuantityOrderedSecondary"];
         orderHistoryItem.requestDate = [node elementStringValue:@"RequestDate"];
         orderHistoryItem.returnReferenceId = [node elementNumberValue:@"ReturnReferenceID"];
         orderHistoryItem.orderId = order.orderId;
         orderHistoryItem.split = [node elementBoolValue:@"Split"];
         orderHistoryItem.locn = [node elementStringValue:@"LOCN"];
         orderHistoryItem.lotn = [node elementStringValue:@"LOTN"];
         orderHistoryItem.lttr = [node elementStringValue:@"LTTR"];
         orderHistoryItem.mcu = [node elementStringValue:@"MCU"];
         orderHistoryItem.nxtr = [node elementStringValue:@"NXTR"];
         orderHistoryItem.openItemStatus = [node elementStringValue:@"OpenItemStatus"];

         [order addOrderItemToOrder:orderHistoryItem];
         
         [orderHistoryItem release];
         orderHistoryItem = nil;
         [productItem release];
         productItem = nil;
         
     }
    
    
    
    Customer *customer = [customerXmlMarshaller toObjectFromXmlElement: [headerNode firstElementNamed:@"Customer"]];
    
    order.customer = customer;
    
    [customerXmlMarshaller release];

    return order;
}


-(NSString *) toXml:(id)marshalObj {
    return nil;
}


@end
