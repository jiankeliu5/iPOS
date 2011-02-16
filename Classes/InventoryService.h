//
//  InventoryService.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//
#import "SessionInfo.h"
#import "ProductItem.h"

@protocol InventoryService <NSObject>

#pragma mark Product Item Services
@required
-(ProductItem *) lookupProductItem: (NSString *) itemSku withSession:  (SessionInfo *) sessionInfo;
-(BOOL) isProductItemAvailable:  (NSString *) itemId forQuantity: (NSDecimal *) quantity withSession:  (SessionInfo *) sessionInfo;


@end
