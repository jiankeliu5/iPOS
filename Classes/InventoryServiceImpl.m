//
//  InventoryServiceImpl.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "InventoryServiceImpl.h"
#import "SessionInfo.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "ASIHTTPRequest.h"

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
    BOOL enabled = [defaults boolForKey:@"enableDemoMode"];
    
    if (enabled) {
        self.baseUrl = @"http://ipad.demo.objectpartners.com:8080/ipos-demo-services-0.1/webservices";
        self.posInventoryMgmtUri = @"ipos/ItemService";
    } else {
        self.baseUrl = @"http://tsipos01/webservices";
        self.posInventoryMgmtUri = @"ipos/ItemService";
    }

    return self;
}
-(void) dealloc {
    [baseUrl release];
    [posInventoryMgmtUri release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem: (NSString *) itemSku withSession:  (SessionInfo *) sessionInfo {
    ProductItem *item = nil;
    
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId, itemSku]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        return nil;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:response options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Extract the itemID.  If it 0 return nil;
    NSArray *nodes = nil;
    CXMLDocument *element = nil;
    
    //TODO: May have to make this more robust to handle error conditions.  This assumes clean XML coming back.
    nodes = [root elementsForName:@"ItemID"];
    element = [nodes lastObject];


    if (![[element stringValue] isEqualToString:@"0"]) {
        item = [[[ProductItem alloc] init] autorelease];
        
        item.itemId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"BinLocation"];
        element = [nodes lastObject];
        item.binLocation = [element stringValue];
        
        nodes = [root elementsForName:@"Conversion"];
        element = [nodes lastObject];
        item.conversion = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"DCAvailability"];
        element = [nodes lastObject];
        item.distributionCenterAvailability = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"DefaultToBox"];
        element = [nodes lastObject];
        item.defaultToBox = [[element stringValue] boolValue];
        
        nodes = [root elementsForName:@"ItemDescription"];
        element = [nodes lastObject];
        item.description = [element stringValue];
        
        nodes = [root elementsForName:@"ItemNumber"];
        element = [nodes lastObject];
        item.sku = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"ItemStatusCode"];
        element = [nodes lastObject];
        item.statusCode = [element stringValue];
        
        nodes = [root elementsForName:@"ItemType"];
        element = [nodes lastObject];
        item.type = [element stringValue];
        
        nodes = [root elementsForName:@"ItemTypeID"];
        element = [nodes lastObject];
        item.typeId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"PiecesPerBox"];
        element = [nodes lastObject];
        item.piecesPerBox = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"PriceGroupID"];
        element = [nodes lastObject];
        item.priceGroupId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"PrimaryUOM"];
        element = [nodes lastObject];
        item.primaryUnitOfMeasure = [element stringValue];
        
        nodes = [root elementsForName:@"RetailPrice"];
        element = [nodes lastObject];
        item.retailPrice = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"SecondaryUOM"];
        element = [nodes lastObject];
        item.secondaryUnitOfMeasure = [element stringValue];
        
        nodes = [root elementsForName:@"StdCost"];
        element = [nodes lastObject];
        item.standardCost = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"StockingCode"];
        element = [nodes lastObject];
        item.stockingCode = [element stringValue];
        
        nodes = [root elementsForName:@"StoreAvailability"];
        element = [nodes lastObject];
        item.storeAvailability = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"StoreID"];
        element = [nodes lastObject];
        item.storeId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"TaxExempt"];
        element = [nodes lastObject];
        item.taxExempt = [[element stringValue] boolValue];
        
        nodes = [root elementsForName:@"TaxRate"];
        element = [nodes lastObject];
        item.taxRate = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"VendorName"];
        element = [nodes lastObject];
        item.vendorName = [element stringValue];
        
    } 
    
    return item;
}

-(BOOL) isProductItemAvailable:  (NSString *) itemId forQuantity: (NSDecimal *) quantity withSession:  (SessionInfo *) sessionInfo {
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/availability/%@/%@/%@", baseUrl, posInventoryMgmtUri,sessionInfo.storeId, itemId, quantity]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        return NO;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:response options:0] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    BOOL isAvailable = NO;
    
    // Parse the response to fetch the boolean result
    if (root != nil) {
        isAvailable = [[root stringValue] boolValue];
    }
    
    // Return resul
    return isAvailable;
}

@end
