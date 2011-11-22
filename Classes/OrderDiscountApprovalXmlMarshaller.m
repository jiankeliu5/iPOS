//
//  OrderDiscountApprovalRequestXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 11/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "OrderDiscountApprovalXmlMarshaller.h"
#import "OrderDiscountApprovalRequest.h"
#import "OrderDiscountApprovalResponse.h"

#import "NSString+StringFormatters.h"

#import "POSOxmUtils.h"


static NSString * const PRICE_APPROVAL_REQUEST_XML = @""
"<ItemSellingPriceApproval>"
    "<ItemList>"
        "${itemsXml}"
    "</ItemList>"
    "${approverXml}"
"</ItemSellingPriceApproval>";

static NSString * const ITEM_XML = @""
"<Item>"
    "<ItemID>%@</ItemID>"
    "<ItemSellingPrice>%@</ItemSellingPrice>"
    "<PriceGroupID>%@</PriceGroupID>"
    "<RetailPrice>%@</RetailPrice>"
"</Item>";

static NSString * const APPROVER_XML = @""
"<Approver>"
    "<ApproverUserName>%@</ApproverUserName>"
    "<ApproverPassword>%@</ApproverPassword>"
"</Approver>";


@interface OrderDiscountApprovalXmlMarshaller()

- (NSString *) sellingItemsToXml: (OrderDiscountApprovalRequest *) orderDiscount;
- (NSString *) approverToXml:(ManagerInfo *)approver;

@end

@implementation OrderDiscountApprovalXmlMarshaller

- (NSString *)toXml:(id)marshalObj {
    NSString *requestXml = @"<ItemSellingPriceApproval />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[OrderDiscountApprovalRequest class]]) {
        OrderDiscountApprovalRequest *approvalRequest = (OrderDiscountApprovalRequest *) marshalObj;
        
        requestXml = PRICE_APPROVAL_REQUEST_XML;
        
        // Add the selling items
        requestXml = [POSOxmUtils replaceInXmlTemplate:requestXml parameter:@"itemsXml" withValue:[self sellingItemsToXml:approvalRequest]];
        requestXml = [POSOxmUtils replaceInXmlTemplate:requestXml parameter:@"approverXml" withValue:[self approverToXml:approvalRequest.managerInfo]];
                        
    }
    
    return requestXml;
}

- (id) toObject:(NSString *) xmlString {
    if (xmlString ==  nil) {
        return nil;
    }
    
    ItemSellingPriceApprovalResponse *itemApprovalResponse = nil;
    OrderDiscountApprovalResponse *approvalResponse = [[[OrderDiscountApprovalResponse alloc] init] autorelease];    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    NSMutableArray *approvalItems = [NSMutableArray arrayWithCapacity:0];
    
    for (CXMLElement *node in [root elementsForName:@"PriceApproval"]) {
        itemApprovalResponse = [[ItemSellingPriceApprovalResponse alloc] init];
        
        itemApprovalResponse.itemId = [node elementNumberValue:@"ItemID"];
        itemApprovalResponse.isApproved = [node elementBoolValue:@"Approved"];
        itemApprovalResponse.authorizationId = [node elementNumberValue:@"AuthorizationID"];
        
        [approvalItems addObject:itemApprovalResponse];
        
        [itemApprovalResponse release];
        itemApprovalResponse = nil;
    }
    
    approvalResponse.itemSellingPriceApprovalList = [NSArray arrayWithArray:approvalItems];
    return approvalResponse;
}

#pragma mark -
#pragma mark Private Methods
- (NSString *) sellingItemsToXml: (OrderDiscountApprovalRequest *) orderDiscount {
    NSString *sellingItemsXml = @"";
    
    if (orderDiscount && orderDiscount.itemSellingApprovalList && [orderDiscount.itemSellingApprovalList count] > 0) {
        NSString *itemId = @"";
        NSString *sellingPrice = @"0.00";
        NSString *priceGroupId = @"0";
        NSString *retailPrice = @"0.00";
        
        for (ItemSellingPriceApprovalRequest *sellingItem in orderDiscount.itemSellingApprovalList) {
            itemId = @"";
            sellingPrice = @"0.00";
            priceGroupId = @"0";
            retailPrice = @"0.00";
            
            if (sellingItem.itemId) {
                itemId = [NSString stringWithFormat:@"%@", sellingItem.itemId];
            }
            if (sellingItem.sellingPrice) {
                sellingPrice = [NSString formatDecimalNumber:sellingItem.sellingPrice toScale:2];
            }
            if (sellingItem.priceGroupId) {
                priceGroupId = [NSString stringWithFormat:@"%@", sellingItem.priceGroupId];
            }
            if (sellingItem.retailPrice) {
                retailPrice = [NSString formatDecimalNumber:sellingItem.retailPrice toScale:2];
            }
            
            sellingItemsXml = [sellingItemsXml stringByAppendingFormat:ITEM_XML, itemId, sellingPrice, priceGroupId, retailPrice];
        }
    } else {
        return sellingItemsXml = @"<Item />";
    }
    
    return sellingItemsXml;
}

- (NSString *) approverToXml:(ManagerInfo *)approver {
    NSString *approverXml = @"";
    
    if (approver) {
        NSString *userName = @"";
        NSString *pwd = @"";
        
        if (approver.managerUserName) {
            userName = approver.managerUserName;
        }
        if (approver.managerPassword) {
            pwd = approver.managerPassword;
        }
        
        approverXml = [NSString stringWithFormat:APPROVER_XML, userName, pwd];
    }
    
    return approverXml;
}





@end