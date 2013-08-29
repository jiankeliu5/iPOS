//
//  InventoryServiceImpl.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "InventoryServiceImpl.h"
#import "SessionInfo.h"
#import "ASIHTTPRequest.h"

#import "ASIHTTPRequest+Validate.h"

#import "POSOxmUtils.h"
#import "ProductItemXmlMarshaller.h"
#import "ItemSellingPriceApprovalRequest.h"
#import "ItemSellingPriceApprovalResponse.h"

@interface InventoryServiceImpl()

- (ASIHTTPRequest *) startGetRequest: (NSString *) urlString withSession: (SessionInfo *) sessionInfo;

- (NSString *) escapeXMLForParsing: (NSString *) xmlString;

@end

@implementation InventoryServiceImpl

@synthesize baseUrl, posInventoryMgmtUri;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Get user preference for demo mode
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL demoEnabled = [defaults boolForKey:@"enableDemoMode"];
    
#if DEMO_MODE
    demoEnabled = YES;
#endif

    if (demoEnabled) {
        [self setToDemoMode];
    } else {
        [self setToReleaseMode];
    }

    return self;
}

-(void) dealloc {
    [baseUrl release];
    [posInventoryMgmtUri release];
    
    [super dealloc];
}

-(void) setToDemoMode {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.demo.baseurl"];
    self.posInventoryMgmtUri = @"ItemService";
}

-(void) setToReleaseMode {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.baseurl"];
    self.posInventoryMgmtUri = @"ItemService";
}

#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem: (NSString *) itemSku withSession:  (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId, itemSku] withSession:sessionInfo];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    // Create an XML document parser
    NSString *response = [request responseString];
    
    NSLog(@"lookupProductItem response string: %@", response);
        
    ProductItem *item = [ProductItem fromXml:response];
    return item;
}

- (NSArray *) lookupProductItemByName:(NSString *)itemName withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/name/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    /*
    UIAlertView *longPress = [[UIAlertView alloc] init];
    longPress.title = @"Message";
    longPress.message = [NSString stringWithFormat:@"here!"];
    [longPress addButtonWithTitle:@"OK"];
    [longPress show];
    [longPress release];
    */
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<ItemSearch>%@</ItemSearch>", itemName]];   
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    /*
    UIAlertView *longPress = [[UIAlertView alloc] init];
    longPress.title = @"Message";
    longPress.message = [NSString stringWithFormat:@"responseString: %@", [request responseString]];
    [longPress addButtonWithTitle:@"OK"];
    [longPress show];
    [longPress release];
    */
     
    NSArray *items = [ProductItem listFromXml:[request responseString]];
    
    //return [items sortedArrayUsingSelector:@selector(compare:)];
    return items;
}
    

-(BOOL) isProductItemAvailable:  (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity withSession:  (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return NO;
    }
    
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/availability/%@/%@/%@", baseUrl, posInventoryMgmtUri,sessionInfo.storeId, itemId, quantity] withSession:sessionInfo];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return NO;   
    } 
        
    // Create an XML document parser
    NSString *response = [request responseString];
    BOOL isAvailable =  [POSOxmUtils isXmlResultTrue:response];
        
    // Return result
    return isAvailable;
}

- (BOOL) adjustSellingPriceFor:(OrderItem *)orderItem withCustomer:(Customer *)customer withSession: (SessionInfo *) sessionInfo {
    if (sessionInfo == nil || orderItem == nil || customer == nil) {
        return NO;
    }
    NSLog(@"adjustSellingPriceFor called");
    NSLog(@"orderItem.retailPrice: %@", orderItem.item.retailPricePrimary.stringValue);
    NSLog(@"orderItem.sellingPrice: %@", orderItem.item.sellingPricePrimary.stringValue);
    
    // If the customer is a retail customer, selling price is retail price
    if ([customer isRetailCustomer]) {
        //orderItem.sellingPricePrimary = [[orderItem.item.retailPricePrimary copy] autorelease]; //commented 8/23/2013
        //orderItem.sellingPriceSecondary = [[orderItem.item.retailPriceSecondary copy] autorelease]; //commented 8/23/2013
        //Enning Tang 8/23/2013 change to copy selling price instead of retailPrice
        orderItem.sellingPricePrimary = [[orderItem.item.sellingPricePrimary copy] autorelease];
        orderItem.sellingPriceSecondary = [[orderItem.item.sellingPriceSecondary copy] autorelease];
    } else {
        //Enning Tang change to check retailPriceSecondary 8/23/2013
        /*ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/customerSellingPrice/%@/%@/%@",
                                                                baseUrl, posInventoryMgmtUri, customer.priceLevelId, orderItem.item.priceGroupId, orderItem.item.retailPricePrimary] withSession:sessionInfo];
         */
        ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/customerSellingPrice/%@/%@/%@",
                                                          baseUrl, posInventoryMgmtUri, customer.priceLevelId, orderItem.item.priceGroupId, orderItem.item.retailPriceSecondary] withSession:sessionInfo];
        
        NSArray *requestErrors = [request validateAsXmlContent];
        if ([requestErrors count] > 0) {
            return NO;   
        } 
            
        // Parse the result
        NSDecimalNumber *sellingPrice = [POSOxmUtils parseAsDecimal:[request responseString]];
        //Enning Tang check if the new selling price is lower than the default selling price 8/23/2013
        NSLog(@"itemSelling Price: %@", orderItem.item.sellingPriceSecondary.stringValue);
        NSLog(@"Con price: %@", sellingPrice.stringValue);
        if ([sellingPrice floatValue] > [orderItem.item.sellingPriceSecondary floatValue])
        {
            NSLog(@"item.sellingPricePrimary is smaller than Con price");
            sellingPrice = orderItem.item.sellingPriceSecondary;
        }
        
        if (sellingPrice) {
            orderItem.sellingPriceSecondary = sellingPrice;
            NSLog(@"orderItem.item.primaryUnitOfMeasure: --%@--", orderItem.item.primaryUnitOfMeasure);
            if ([orderItem.item.primaryUnitOfMeasure isEqualToString:@"BX"])
            {
                NSLog(@"!!!!!!!!!!!!!!!");
                orderItem.sellingPricePrimary = sellingPrice;
            }
        }
    }
    return YES;
}

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover withSession: (SessionInfo *) sessionInfo {
    BOOL allowAdjustment = NO;
    ItemSellingPriceApprovalRequest *sellingApprovalReq = [[[ItemSellingPriceApprovalRequest alloc] initWithOrderItem:orderItem managerInfo:managerApprover] autorelease];
    
    if (orderItem) {
         sellingApprovalReq.sellingPrice = [orderItem calcSellingPricePrimaryFrom:discountAmount];
         
        // Is it allowed?
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/changePriceApproval", baseUrl, posInventoryMgmtUri]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request setValidatesSecureCertificate:NO];
        [request setTimeOutSeconds:30];
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
        [request addRequestHeader:@"Content-Type" value:@"text/xml"];
        
        NSString *requestXml = [self escapeXMLForParsing:[sellingApprovalReq toXml]];

        [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request startSynchronous];
        
        NSArray *requestErrors = [request validateAsXmlContent];
        if ([requestErrors count] > 0) {
            return NO;   
        } 
        
        // Parse the response and set the authorizer ID
        ItemSellingPriceApprovalResponse *approvalResponse = [ItemSellingPriceApprovalResponse fromXml:[request responseString]];
        
        // Set the authorization ID (if available)
        if (approvalResponse.isApproved && [approvalResponse.authorizationId compare: [NSDecimalNumber zero]] != NSOrderedSame) {
            orderItem.priceAuthorizationId = approvalResponse.authorizationId;
        }
        
        allowAdjustment = approvalResponse.isApproved;
    }

    if (allowAdjustment) {
        [orderItem setSellingPriceFrom:discountAmount];
    }
    
    return allowAdjustment;
}

#pragma mark -
#pragma mark Private Methods
- (ASIHTTPRequest *) startGetRequest: (NSString *) urlString withSession: (SessionInfo *) sessionInfo {
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:10];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
    [request startSynchronous];
    
    return request;
}

- (NSString *) escapeXMLForParsing: (NSString *) xmlString {
    
    // Replace any entity reference or XML special characters that could impact parsing
    NSString *escapedString = [xmlString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    return escapedString;
}

@end
