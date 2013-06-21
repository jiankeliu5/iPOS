//
//  Items.h
//  iPOS
//
//  Created by Enning Tang on 8/1/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Items : NSObject{
    
    NSString *ItemID;
    NSString *StoreID;
    NSString *ItemNumber;
    NSString *ItemDescription;
    NSString *ItemTypeID;
    NSString *StockingCode;
    NSString *ItemStatusCode;
    NSString *ItemQty;
    NSString *PrimaryUOM;
    NSString *ShipToStoreID;
    
}

@property (nonatomic, retain) NSString *ItemID;
@property (nonatomic, retain) NSString *StoreID;
@property (nonatomic, retain) NSString *ItemNumber;
@property (nonatomic, retain) NSString *ItemDescription;
@property (nonatomic, retain) NSString *ItemTypeID;
@property (nonatomic, retain) NSString *StockingCode;
@property (nonatomic, retain) NSString *ItemStatusCode;
@property (nonatomic, retain) NSString *ItemQty;
@property (nonatomic, retain) NSString *PrimaryUOM;
@property (nonatomic, retain) NSString *ShipToStoreID;

-(id)init:(NSString *)paraItemID StoreID:(NSString *)paraStoreID ItemNumber:(NSString *)paraItemNumber ItemDescription:(NSString *)paraItemDescription ItemTypeID:(NSString *)paraItemTypeID StockingCode:(NSString *)paraStockingCode ItemStatusCode:(NSString *)paraItemStatusCode ItemQty:(NSString *)paraItemQty PrimaryUOM:(NSString *)paraPrimaryUOM ShipToStoreID:(NSString *)paraShipToStoreID;

@end
