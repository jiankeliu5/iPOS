//
//  InventoryServiceImpl.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InventoryService.h"

@interface InventoryServiceImpl : NSObject <InventoryService> {
    NSString *baseUrl;
    NSString *posInventoryMgmtUri;
}

@property(nonatomic, retain) NSString *baseUrl;
@property(nonatomic, retain) NSString *posInventoryMgmtUri;

@end
