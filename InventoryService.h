//
//  InventoryService.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

@protocol InventoryService <NSObject>

#pragma mark Product Item Services
@required
-(void) lookupProductItem;
-(BOOL) isProductItemAvailable;


@end
