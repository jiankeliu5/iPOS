//
//  InventoryServiceMock.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "InventoryServiceMock.h"


@implementation InventoryServiceMock

-(ProductItem *) lookupProductItem: (NSString *) itemSku withSession:  (SessionInfo *) sessionInfo {
    ItemAvailability *storeAvailability = [[[ItemAvailability alloc] init] autorelease];
    ItemAvailability *dc1Availability = [[[ItemAvailability alloc] init] autorelease];
    ItemAvailability *dc2Availability = [[[ItemAvailability alloc] init] autorelease];
    ProductItem *item = [[[ProductItem alloc] init] autorelease];
    Store *store = [[[Store alloc] init] autorelease];
    
    DistributionCenter *dc1 = [[[DistributionCenter alloc] init] autorelease];
    DistributionCenter *dc2 = [[[DistributionCenter alloc] init] autorelease];

    // Initialization
    store.availability = storeAvailability;
    dc1.availability = dc1Availability;
    dc2Availability = dc2Availability;
    
    item.itemId = [NSNumber numberWithInt:283186];
    item.sku = [NSNumber numberWithInt: 440915];
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.defaultToBox = NO;
    item.primaryUnitOfMeasure = @"EA";
    item.secondaryUnitOfMeasure = @"EA";
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    item.priceGroupId = [NSNumber numberWithInt:123];
    item.retailPrice = [NSDecimalNumber decimalNumberWithString:@"18.99"];
    item.standardCost = [NSDecimalNumber decimalNumberWithString:@"3.99"];
    item.taxRate = [NSDecimalNumber decimalNumberWithString:@"0.7"];
    item.taxExempt = NO;
    
    // Initialize the distribution center
    dc1.dcId = [NSNumber numberWithInt:801];
    dc1.availability.available = [NSDecimalNumber decimalNumberWithString:@"1212"];
    dc1.availability.onHand = [NSDecimalNumber decimalNumberWithString:@"1000"];
    dc1.isPrimary = YES;
    
    dc2.dcId = [NSNumber numberWithInt:806];
    dc2.availability.available = [NSDecimalNumber decimalNumberWithString:@"0"];
    dc2.availability.onHand = [NSDecimalNumber decimalNumberWithString:@"0"];
    dc2.availability.etaDateAsString = @"JAN 24 2011";
    dc2.isPrimary = NO;
    
    // Add the distribution center
    NSMutableArray *dcList = [[[NSMutableArray alloc] init] autorelease];
    
    [dcList addObject: dc1];
    [dcList addObject: dc2];
    
    store.storeId = [NSNumber numberWithInt: 1200];
    store.availability.available = [NSDecimalNumber decimalNumberWithString: @"13"];
    store.availability.onHand = [NSDecimalNumber decimalNumberWithString:@"10"];
    
    item.store = store;
    item.distributionCenterList = [[dcList copy] autorelease];
    
    
    return item;
}

-(BOOL) isProductItemAvailable:  (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity withSession:  (SessionInfo *) sessionInfo {
    return YES;
}

- (BOOL) adjustSellingPriceFor:(OrderItem *)orderItem withCustomer:(Customer *)customer withSession: (SessionInfo *) sessionInfo {
    return YES;
}

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover withSession: (SessionInfo *) sessionInfo {
    return YES;
}

@end
