//
//  Order.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractModel.h"
#import "Store.h"
#import "Customer.h"
#import "OrderItem.h"

static int const ORDER_TYPE_QUOTE = 1;
static int const ORDER_TYPE_OPEN = 2;
static int const ORDER_TYPE_CANCELLED = 3;
static int const ORDER_TYPE_CLOSED = 4;
static int const ORDER_TYPE_RETURNED = 5;

typedef enum{
    REFUND,
    TENDER,
    NOCHANGE
} TenderDecision;

@class Refund;
@interface Order : AbstractModel {
    NSNumber *orderId;
    NSNumber *orderTypeId;
    NSNumber *salesPersonEmployeeId;
    NSString *notes;
    NSString *purchaseOrderId;
    
    NSNumber *depositAuthorizationID;
    NSString *followUpDate;
    NSString *orderDCTO;
    NSString *promiseDate;
    NSString *requestDate;
    NSNumber *selectionId;
    BOOL taxExempt;
    BOOL isNewOrder;
    
    Store *store;
    Customer *customer;
    
    NSMutableArray *previousPayments;
    
    @private NSMutableArray *orderItemList;
    
    //Enning Tang added currentVersion string 3/20/2013
    NSString *currentVersion;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *orderTypeId;
@property (nonatomic, retain) NSNumber *salesPersonEmployeeId;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *purchaseOrderId;

@property (nonatomic, retain) NSNumber *depositAuthorizationID;
@property (nonatomic, retain) NSString *followUpDate;
@property (nonatomic, retain) NSString *orderDCTO;
@property (nonatomic, retain) NSString *promiseDate;
@property (nonatomic, retain) NSString *requestDate;
@property (nonatomic, retain) NSNumber *selectionId;
@property (nonatomic, assign) BOOL taxExempt;
@property (nonatomic, assign) BOOL isNewOrder;
@property (nonatomic, retain) Store *store;
@property (nonatomic, retain) Customer *customer;

@property (nonatomic, retain) NSMutableArray *previousPayments;

//Enning Tang added currentVersion string 3/20/2013
@property (nonatomic, retain) NSString *currentVersion;


- (NSArray *) getOrderItems;
- (NSArray *) getOrderItemsSortedByStatus;
- (NSArray *) getOrderItemsSortedByStatusFilterCanceled;

- (NSArray *) getOrderItems:(LineOrderStatus) lineItemStatus;

- (void) addItemToOrder: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
-(void) addReturnItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity SellingPricePrimary:(NSDecimalNumber *) SellingPricePrimary SellingPriceSecondary:(NSDecimalNumber *) SellingPriceSecondary;
- (void) addOrderItemToOrder:(OrderItem *)orderItem;
- (void) removeItemFromOrder: (OrderItem *) item;
- (void) removeAll;

#pragma mark -
#pragma mark Order Type methods
- (void) setAsQuote;
- (void) setAsNewOrder;
- (void) setAsClosed;
- (void) setAsCanceled;
//Enning Tang Set header closed 3/20/2013
- (void) setHeaderClosed;

- (BOOL) isQuote;
- (BOOL) isClosed;
- (BOOL) isCanceled;

- (void) mergeWith: (Order *) mergeOrder;

- (void) cancelOrder;

// These routines are more for determining what can be done with existing orders
- (BOOL) canViewDetails;
- (BOOL) canEditDetails;
- (BOOL) canCancel;
- (BOOL) canApplyDiscount: (NSDecimalNumber *) discountAmt;

- (BOOL) isModified;

#pragma mark -
#pragma mark Validation methods
- (BOOL) validateAsNew;
- (BOOL) validateAsNewQuote;
- (BOOL) validateAsNewOrder;

- (BOOL) purchaseOrderInfoRequired;
 
#pragma mark -
#pragma mark Marshalling methods
+ (Order *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;

#pragma mark -
#pragma mark Order Calculations
- (NSDecimalNumber *) calcOrderRetailSubTotal;
- (NSDecimalNumber *) calcOrderSubTotal;
- (NSDecimalNumber *) calcOpenItemsSubTotal;
- (NSDecimalNumber *) calcOrderTax;

- (NSDecimalNumber *) calcOrderTotal;
- (NSDecimalNumber *) calcOrderDiscountTotal;

- (NSDecimalNumber *) calcBalanceDue;
- (NSDecimalNumber *) calcBalanceOwing;
- (NSDecimalNumber *) calcBalancePaid;


- (NSDecimalNumber *) calcClosedItemsBalance;
- (NSDecimalNumber *) calculateProfitMargin;

- (NSNumber *) calcOpenItemsWeight;

#pragma mark -
#pragma mark Refund methods
-(TenderDecision) isRefundEligble;

- (Refund *) getRefundInfo;
- (NSDecimalNumber *) calcRefundTotal;

@end
