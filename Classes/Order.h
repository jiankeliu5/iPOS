//
//  Order.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Customer.h"
#import "OrderItem.h"

@interface Order : NSObject {

    @private NSMutableArray *orderItemList;
    
    Customer *customer;
    NSArray *errorList;
}

@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) NSArray *errorList;

-(void) addItemToOrder: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
-(void) removeItemFromOrder: (ProductItem *) item;
-(void) removeAll;
@end
