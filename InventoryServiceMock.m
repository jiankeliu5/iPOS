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
    ProductItem *item = [[[ProductItem alloc] init] autorelease];
    DistributionCenter *dc1 = [[[DistributionCenter alloc] init] autorelease];
    DistributionCenter *dc2 = [[[DistributionCenter alloc] init] autorelease];

    
    item.itemId = [NSNumber numberWithInt:283186];
    item.storeId = [NSNumber numberWithInt: 1200];
    item.sku = [NSNumber numberWithInt: 440915];
    item.description = @"Driftwood Hon. Martel";
    item.vendorName = @"SHAO LIN STONE/CHINA METALLURGICAL";
    item.statusCode = @"S";
    item.type = @"Travertine";
    item.typeId = [NSNumber numberWithInt: 26];
    item.binLocation = @"TR0520";
    item.stockingCode = @"S";
    item.storeAvailability = [NSDecimalNumber decimalNumberWithString: @"13"];
    item.storeOnHand = [NSDecimalNumber decimalNumberWithString:@"10"];
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
    dc1.availability = [NSDecimalNumber decimalNumberWithString:@"1212"];
    dc1.onHand = [NSDecimalNumber decimalNumberWithString:@"1000"];
    dc1.isPrimary = YES;
    
    dc2.dcId = [NSNumber numberWithInt:806];
    dc2.availability = [NSDecimalNumber decimalNumberWithString:@"0"];
    dc2.onHand = [NSDecimalNumber decimalNumberWithString:@"0"];
    dc2.etaDateAsString = @"JAN 24 2011";
    dc2.isPrimary = NO;
    
    // Add the distribution center
    NSMutableArray *dcList = [[[NSMutableArray alloc] init] autorelease];
    
    [dcList addObject: dc1];
    [dcList addObject: dc2];
    
    item.distributionCenterList = [[dcList copy] autorelease];
    
    
    return item;
}

-(BOOL) isProductItemAvailable:  (NSString *) itemId forQuantity: (NSDecimal *) quantity withSession:  (SessionInfo *) sessionInfo {
    return YES;
}

@end
