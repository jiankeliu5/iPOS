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
        
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId, itemSku]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:10];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
        
    ProductItem *item = [ProductItem fromXml:response];
    return item;
}

-(BOOL) isProductItemAvailable:  (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity withSession:  (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return false;
    }
    
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/availability/%@/%@/%@", baseUrl, posInventoryMgmtUri,sessionInfo.storeId, itemId, quantity]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:10];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
    [request startSynchronous];
    
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

- (void) adjustSellingPriceFor:(OrderItem *)orderItem withCustomer:(Customer *)customer {
    //TODO:  Implement this method
}

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover withSession: (SessionInfo *) sessionInfo {
    
    // TODO: Implement this method.  Calculate selling price from discount amt
    return true;
}
@end
