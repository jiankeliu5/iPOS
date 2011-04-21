//
//  ItemSellingPriceApprovalMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemSellingPriceApprovalMarshaller.h"
#import "ItemSellingPriceApprovalRequest.h"
#import "ItemSellingPriceApprovalResponse.h"

#import "POSOxmUtils.h"

static NSString * const PRICE_APPROVAL_REQUEST_XML = @""
    "<ItemSellingPriceApproval>"
        "<ItemID>%@</ItemID>"
        "<ItemSellingPrice>%@</ItemSellingPrice>"
        "<PriceGroupID>%@</PriceGroupID>"
        "<RetailPrice>%@</RetailPrice>"
        "${approverXml}"
    "</ItemSellingPriceApproval>";
    
static NSString * const APPROVER_XML = @""
    "<Approver>"
        "<ApproverUserName>%@</ApproverUserName>"
        "<ApproverPassword>%@</ApproverPassword>"
    "</Approver>";

@interface ItemSellingPriceApprovalMarshaller()

- (NSString *) approverToXml: (ManagerInfo *) approver;

@end

@implementation ItemSellingPriceApprovalMarshaller

- (NSString *) toXml:(id)marshalObj {
    NSString *requestXml = @"<ItemSellingPriceApproval />";
    
    if (marshalObj && [marshalObj isMemberOfClass:[ItemSellingPriceApprovalRequest class]]) {
        ItemSellingPriceApprovalRequest *approvalRequest = (ItemSellingPriceApprovalRequest *) marshalObj;
        NSString *itemId = @"";
        NSString *sellingPrice = @"0.00";
        NSString *priceGroupId = @"0";
        NSString *retailPrice = @"0.00";
        
        if (approvalRequest.itemId) {
            itemId = [NSString stringWithFormat:@"%@", approvalRequest.itemId];
        }
        if (approvalRequest.sellingPrice) {
            sellingPrice = [NSString stringWithFormat:@"%@", approvalRequest.sellingPrice];
        }
        if (approvalRequest.priceGroupId) {
            priceGroupId = [NSString stringWithFormat:@"%@", approvalRequest.priceGroupId];
        }
        if (approvalRequest.retailPrice) {
            retailPrice = [NSString stringWithFormat:@"%@", approvalRequest.retailPrice];
        }
        
        requestXml = [NSString stringWithFormat:PRICE_APPROVAL_REQUEST_XML, itemId, sellingPrice, priceGroupId, retailPrice];
        requestXml = [POSOxmUtils replaceInXmlTemplate:requestXml parameter:@"approverXml" withValue:[self approverToXml:approvalRequest.managerInfo]];
    }
    
    return requestXml;
}

- (id) toObject:(NSString *)xmlString {
    if (xmlString ==  nil) {
        return nil;
    }
    
    ItemSellingPriceApprovalResponse *approvalResponse = [[[ItemSellingPriceApprovalResponse alloc] init] autorelease];    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    approvalResponse.isApproved = [root elementBoolValue:@"Approved"];
    approvalResponse.authorizationId = [root elementNumberValue:@"AuthorizationID"];
    
    return approvalResponse;
}

#pragma mark -
#pragma mark Private methods
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
