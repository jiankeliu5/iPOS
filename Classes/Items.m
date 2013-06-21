//
//  Items.m
//  iPOS
//
//  Created by Enning Tang on 8/1/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "Items.h"

@implementation Items

@synthesize ItemID;
@synthesize StoreID;
@synthesize ItemNumber;
@synthesize ItemDescription;
@synthesize ItemTypeID;
@synthesize StockingCode;
@synthesize ItemStatusCode;
@synthesize ItemQty;
@synthesize PrimaryUOM;
@synthesize ShipToStoreID;

-(id)init:(NSString *)paraItemID StoreID:(NSString *)paraStoreID ItemNumber:(NSString *)paraItemNumber ItemDescription:(NSString *)paraItemDescription ItemTypeID:(NSString *)paraItemTypeID StockingCode:(NSString *)paraStockingCode ItemStatusCode:(NSString *)paraItemStatusCode ItemQty:(NSString *)paraItemQty PrimaryUOM:(NSString *)paraPrimaryUOM ShipToStoreID:(NSString *)paraShipToStoreID{
    if ((self = [super init])){
        self.ItemID = paraItemID;
        self.StoreID = paraStoreID;
        self.ItemNumber = paraItemNumber;
        self.ItemDescription = paraItemDescription;
        self.ItemTypeID = paraItemTypeID;
        self.StockingCode = paraStockingCode;
        self.ItemStatusCode = paraItemStatusCode;
        self.ItemQty = paraItemQty;
        self.PrimaryUOM = paraPrimaryUOM;
        self.ShipToStoreID = paraShipToStoreID;
        NSLog(@"Initialized");
    }
    return self;
}

-(void) dealloc{
    self.ItemID = nil;
    self.StoreID = nil;
    self.ItemNumber = nil;
    self.ItemDescription = nil;
    self.ItemTypeID = nil;
    self.StockingCode = nil;
    self.ItemStatusCode = nil;
    self.ItemQty = nil;
    self.PrimaryUOM = nil;
    [super dealloc];
}

@end
