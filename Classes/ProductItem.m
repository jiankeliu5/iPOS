//
//  ProductItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ProductItem.h"


@implementation ProductItem

@synthesize itemId, sku, description, vendorName, statusCode, type, typeId;
@synthesize binLocation, stockingCode;
@synthesize defaultToBox, piecesPerBox, primaryUnitOfMeasure, secondaryUnitOfMeasure, conversion;
@synthesize priceGroupId, retailPrice, standardCost, taxRate, taxExempt;
@synthesize store, distributionCenterList;

#pragma mark Constuctor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(void) dealloc {
    [itemId release];
    [sku release];
    [description release];
    [vendorName release];
    [statusCode release];
    [type release];
    [typeId release];
    
    [binLocation release];
    [stockingCode release];    
    [piecesPerBox release];
    [primaryUnitOfMeasure release];
    [secondaryUnitOfMeasure release];
    [conversion release];
    
    [priceGroupId release];
    [retailPrice release];
    [standardCost release];
    [taxRate release];
    
    [store release];
    [distributionCenterList release];
    
    [super dealloc];
}

@end
