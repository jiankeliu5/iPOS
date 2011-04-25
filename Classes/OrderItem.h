//
//  OrderItem.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ManagerInfo.h"
#import "ProductItem.h"

@interface OrderItem : NSObject {
    NSNumber *lineNumber;
    NSNumber *statusId;
    
    NSNumber *priceAuthorizationId;
    
    NSDecimalNumber *sellingPrice;
    NSDecimalNumber *quantity;
    
    ManagerInfo *managerApprover;
    ProductItem *item;
	
	// These are for batch editing of the order.
	BOOL shouldDelete;
	BOOL shouldClose;
}

@property (nonatomic, retain) NSNumber *lineNumber;
@property (nonatomic, retain) NSNumber *statusId;
@property (nonatomic, retain) NSNumber *priceAuthorizationId;

@property (nonatomic, retain) NSDecimalNumber *sellingPrice;
@property (nonatomic, retain) NSDecimalNumber *quantity;

@property (nonatomic, retain) ManagerInfo *managerApprover;
@property (nonatomic, retain) ProductItem *item;

@property (nonatomic, assign) BOOL shouldDelete;
@property (nonatomic, assign) BOOL shouldClose;

-(id) initWithItem: (ProductItem *) productItem AndQuantity: (NSDecimalNumber *) productQuantity;

- (NSNumber *) getQuantityInBoxes;
- (NSNumber *) getPiecesPerBox;

- (void) setStatusToClosed;
- (void) setStatusToOpen;

- (BOOL) isTaxExempt;
- (BOOL) isClosed;
- (BOOL) allowClose;

#pragma mark -
#pragma mark Order Item Calculations
- (NSDecimalNumber *) calcSellingPriceFrom: (NSDecimalNumber *) discount;
- (NSDecimalNumber *) calcLineRetailSubTotal;
- (NSDecimalNumber *) calcLineSubTotal;
- (NSDecimalNumber *) calcLineTax;
- (NSDecimalNumber *) calcLineDiscount;

- (NSString *) getQuantityForDisplay;

@end
