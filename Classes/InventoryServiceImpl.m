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
    
    ProductItem *item = nil;
    Store *store = nil;
    
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId, itemSku]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
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
    CXMLElement *element = nil;
    
    //TODO: May have to make this more robust to handle error conditions.  This assumes clean XML coming back.
    nodes = [root elementsForName:@"ItemID"];
    element = [nodes lastObject];


    if (![[element stringValue] isEqualToString:@"0"]) {
        ItemAvailability *storeAvailability = [[[ItemAvailability alloc] init] autorelease];
    
        item = [[[ProductItem alloc] init] autorelease];
        store = [[[Store alloc] init] autorelease];
        
        // Good to set the item id
        item.itemId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        // Build store
        nodes = [root elementsForName:@"StoreID"];
        element = [nodes lastObject];
        store.storeId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"StoreAvailability"];
        element = [nodes lastObject];
        storeAvailability.available = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"StoreOnHand"];
        element = [nodes lastObject];
        storeAvailability.onHand = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        storeAvailability.item = item;
        store.availability = storeAvailability;
                        
        // Build the Item Info
        item.store = store;
        
        nodes = [root elementsForName:@"BinLocation"];
        element = [nodes lastObject];
        item.binLocation = [element stringValue];
        
        nodes = [root elementsForName:@"Conversion"];
        element = [nodes lastObject];
        item.conversion = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"DefaultToBox"];
        element = [nodes lastObject];
        
        if ([[element stringValue] isEqualToString: @"true"]) {
            item.defaultToBox = YES;
        } else {
            item.defaultToBox = NO;
        }
        
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
        
        nodes = [root elementsForName:@"TaxExempt"];
        element = [nodes lastObject];
        if ([[element stringValue] isEqualToString: @"true"]) {
            item.taxExempt = YES;
        } else {
            item.taxExempt = NO;
        }
        
        nodes = [root elementsForName:@"TaxRate"];
        element = [nodes lastObject];
        item.taxRate = [NSDecimalNumber decimalNumberWithString:[element stringValue]]; 
        
        nodes = [root elementsForName:@"VendorName"];
        element = [nodes lastObject];
        item.vendorName = [element stringValue];
        
        // Build the Distribution Center Info
        nodes = [root elementsForName:@"Distribution"];
        element = [nodes lastObject];

        // Loop through the nodes of the element and add to array
        if (element) {
            DistributionCenter *dc = nil;
            ItemAvailability *availability = nil;
            NSMutableArray *dcList = [[[NSMutableArray alloc] init] autorelease];        
            
            for (CXMLElement *node in [element elementsForName:@"DC"]) {
                dc = [[[DistributionCenter alloc] init] autorelease];
                
                element = [[node elementsForName:@"dcID"] lastObject];
                dc.dcId = [NSNumber numberWithInt:[[element stringValue] intValue]];
                
                element = [[node elementsForName:@"primary"] lastObject];
                if ([[element stringValue] isEqualToString: @"true"]) {
                    dc.isPrimary = YES;
                } else {
                    dc.isPrimary = NO;
                }
                
                // Build the availability for the DC
                availability = [[[ItemAvailability alloc] init] autorelease];
                element = [[node elementsForName:@"availability"] lastObject];
                availability.available = [NSDecimalNumber decimalNumberWithString:[element stringValue]];
                
                element = [[node elementsForName:@"onHand"] lastObject];
                availability.onHand = [NSDecimalNumber decimalNumberWithString:[element stringValue]];
                
                element = [[node elementsForName:@"eta"] lastObject];
                availability.etaDateAsString = [element stringValue];
                
                availability.item = item;
                dc.availability = availability;
                                                
                [dcList addObject: dc];
                
                dc = nil;
                availability = nil;
            }
            
            // Copy to the item sorted with primary first
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"isPrimary"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            item.distributionCenterList = [[NSArray arrayWithArray: dcList] sortedArrayUsingDescriptors:sortDescriptors];
        }
    } 
    
    return item;
}

-(BOOL) isProductItemAvailable:  (NSString *) itemId forQuantity: (NSDecimal *) quantity withSession:  (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return false;
    }
    
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/availability/%@/%@/%@", baseUrl, posInventoryMgmtUri,sessionInfo.storeId, itemId, quantity]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        return NO;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:response options:0 error:nil] autorelease];
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
