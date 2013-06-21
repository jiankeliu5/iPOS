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

static NSString * const OPEN_STATUS_BACK_ORDERED = @"Back Ordered";
static NSString * const OPEN_STATUS_ZERO_SHIPPED = @"Zero Shipped";
static NSString * const OPEN_STATUS_TO_BE_PICKED = @"To Be Picked";
static NSString * const OPEN_STATUS_PICK_TICKET_RAN = @"Pick Ticket Ran";
static NSString * const OPEN_STATUS_PULLED_TO_STAGE = @"Pulled to Stage";
static NSString * const OPEN_STATUS_LEFT_OFF_TRUCK = @"Left Off Truck";
static NSString * const OPEN_STATUS_LOADED_ON_TRUCK = @"Loaded on Truck";
static NSString * const OPEN_STATUS_IN_TRAN = @"In Tran";
static NSString * const OPEN_STATUS_STORE_RECEIVED = @"Store Received";
static NSString * const OPEN_STATUS_NOT_AVAILABLE = @"Status Not Available";

typedef enum {
    LineStatusNone = 0,
    LineStatusAdd = 1,
    LineStatusModify = 2,
    LineStatusCancel = 3
} LineStatus;

typedef enum {
    LINE_ORDERSTATUS_OPEN = 1,
    LINE_ORDERSTATUS_CLOSED = 2,
    LINE_ORDERSTATUS_RETURN = 3,
    LINE_ORDERSTATUS_CANCEL = 4
} LineOrderStatus;

@interface OrderItem : NSObject {
    NSNumber *lineNumber;
    NSNumber *statusId;
    
    NSNumber *salesPersonEmployeeId;
    NSNumber *priceAuthorizationId;
    
    NSDecimalNumber *sellingPricePrimary;
    NSDecimalNumber *sellingPriceSecondary;
    
    NSDecimalNumber *quantityPrimary;
    NSDecimalNumber *quantitySecondary;
    NSString *requestDate;
    NSNumber *returnReferenceId;
    NSNumber *orderId;
    
    BOOL split;
    NSNumber *spiff;
    NSString *locn;
    NSString *lotn;
    NSString *lttr;
    NSString *mcu;
    NSString *nxtr;
    NSString *urrf;
    NSString *openItemStatus;
    
    ManagerInfo *managerApprover;
    ProductItem *item;
	
    // This boolean controls whether conversion converts to pieces or full boxes
    BOOL doConversionToFullBoxes;
    
	// These are for batch editing of the order.
	BOOL shouldDelete;
	BOOL shouldClose;
    
    // Tells whether the line item is newly added or not and is modified or not.  This 
    // lets us know what operations we can do on it compared to 
    // line items that come from a previous order that has already
    // been submitted.  This should always be set when adding a new
    // line item.
    BOOL isNew;
    BOOL isModified;

}

@property (nonatomic, retain) NSNumber *lineNumber;
@property (nonatomic, retain) NSNumber *statusId;
@property (nonatomic, retain) NSNumber *priceAuthorizationId;
@property (nonatomic, retain) NSNumber *salesPersonEmployeeId;

@property (nonatomic, retain) NSDecimalNumber *sellingPricePrimary;
@property (nonatomic, retain) NSDecimalNumber *sellingPriceSecondary;
@property (nonatomic, retain) NSDecimalNumber *quantityPrimary;
@property (nonatomic, retain) NSDecimalNumber *quantitySecondary;

@property (nonatomic, retain) ManagerInfo *managerApprover;
@property (nonatomic, retain) ProductItem *item;

@property (nonatomic, assign) BOOL doConversionToFullBoxes;
@property (nonatomic, assign) BOOL shouldDelete;
@property (nonatomic, assign) BOOL shouldClose;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) BOOL isModified;

@property (nonatomic, retain) NSString *requestDate;
@property (nonatomic, retain) NSNumber *returnReferenceId;
@property (nonatomic, assign) BOOL split;
@property(nonatomic, retain) NSNumber *spiff;
@property (nonatomic, retain) NSNumber *orderId;


@property(nonatomic, retain) NSString *locn;
@property(nonatomic, retain) NSString *lotn;
@property(nonatomic, retain) NSString *lttr;
@property(nonatomic, retain) NSString *mcu;
@property(nonatomic, retain) NSString *nxtr;
@property(nonatomic, retain) NSString *urrf;
@property(nonatomic, retain) NSString *openItemStatus;

-(id) initWithItem: (ProductItem *) productItem AndQuantity: (NSDecimalNumber *) productQuantity;
-(id) initWithReturnItem:(ProductItem *) productItem AndQuantity:(NSDecimalNumber *) productQuantity SellingPricePrimary:(NSDecimalNumber *) SellingPricePrimary SellingPriceSecondary:(NSDecimalNumber *) SellingPriceSecondary;

- (void) setStatusToClosed;
- (void) setStatusToOpen;
- (void) setStatusToCancel;
- (void) setStatusToReturn;

- (BOOL) isTaxExempt;
- (BOOL) isClosed;
- (BOOL) isOpen;
- (BOOL) isCanceled;
- (BOOL) isReturned;
- (BOOL) allowClose;
- (BOOL) allowEdit;
- (BOOL) allowQuantityChange;

#pragma mark -
#pragma mark Custom Accessors
- (BOOL) isConversionNeeded;
- (NSNumber *) getPiecesPerBox;
- (void) setQuantity: (NSDecimalNumber *) newQuantity;
- (void) setSellingPriceFrom: (NSDecimalNumber *) discount;

// Is the line newly added, modified or cancelled?
- (LineStatus) getLineStatus;

#pragma mark -
#pragma mark Order Item Calculations
- (NSDecimalNumber *) calcDiscountFromPrimarySellingPrice: (NSDecimalNumber *) newSellingPrice;
- (NSDecimalNumber *) calcSellingPricePrimaryFrom: (NSDecimalNumber *) discount;
- (NSDecimalNumber *) calcSellingPriceSecondaryFrom: (NSDecimalNumber *) discount;
- (NSDecimalNumber *) calcLineRetailSubTotal;
- (NSDecimalNumber *) calcLineSubTotal;
- (NSDecimalNumber *) calcLineTax;
- (NSDecimalNumber *) calcLineDiscount;
- (NSDecimalNumber *) calculateExtendedCost;
- (NSDecimalNumber *) calculateExtendedPrice;
- (NSNumber *) calcLineWeight;

#pragma mark -
#pragma mark UOM Switching support
- (void) toggleUOM;
- (NSString *) getUOMForDisplay;
- (NSString *) getQuantityForDisplay;
- (NSString *) getSellingPriceForDisplay;

@end
