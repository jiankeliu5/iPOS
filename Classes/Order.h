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
    NSString *followUpdate;
    NSString *orderDCTO;
    NSString *promiseDate;
    NSString *requestDate;
    NSNumber *selectionId;
    BOOL taxExempt;
    BOOL isNewOrder;
    
    BOOL partialPaymentOnAccount;
    
    Store *store;
    Customer *customer;
    
    NSMutableArray *previousPayments;
    
        
    @private NSMutableArray *orderItemList;
}

@property (nonatomic, retain) NSNumber *orderId;
@property (nonatomic, retain) NSNumber *orderTypeId;
@property (nonatomic, retain) NSNumber *salesPersonEmployeeId;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *purchaseOrderId;

@property (nonatomic, retain) NSNumber *depositAuthorizationID;
@property (nonatomic, retain) NSString *followUpdate;
@property (nonatomic, retain) NSString *orderDCTO;
@property (nonatomic, retain) NSString *promiseDate;
@property (nonatomic, retain) NSString *requestDate;
@property (nonatomic, retain) NSNumber *selectionId;
@property (nonatomic, assign) BOOL taxExempt;
@property (nonatomic, assign) BOOL isNewOrder;
@property (nonatomic, retain) Store *store;
@property (nonatomic, retain) Customer *customer;
@property (nonatomic, assign) BOOL partialPaymentOnAccount;
@property (nonatomic, assign) NSMutableArray *previousPayments;


- (NSArray *) getOrderItems;
- (void) addItemToOrder: (ProductItem *) item withQuantity: (NSDecimalNumber *) quantity;
- (void) addOrderItemToOrder:(OrderItem *)orderItem;
- (void) removeItemFromOrder: (OrderItem *) item;
- (void) removeAll;

#pragma mark -
#pragma mark Order Type methods
- (void) setAsQuote;

- (NSNumber *) getOrderTypeId;
- (BOOL) isClosed;

- (void) mergeWith: (Order *) mergeOrder;

// These routines are more for determining what can be done with existing orders
- (BOOL) canViewDetails;
- (BOOL) canEditDetails;
- (BOOL) canCancel;

#pragma mark -
#pragma mark Validation methods
- (BOOL) validateAsNew;
- (BOOL) validateAsNewQuote;
- (BOOL) validateAsNewOrder;
 
#pragma mark -
#pragma mark Marshalling methods
+ (Order *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;

#pragma mark -
#pragma mark Order Calculations
- (NSDecimalNumber *) calcOrderRetailSubTotal;
- (NSDecimalNumber *) calcOrderSubTotal;
- (NSDecimalNumber *) calcOrderTax;
- (NSDecimalNumber *) calcOrderDiscountTotal;
- (NSDecimalNumber *) calcBalanceOwing;
- (NSDecimalNumber *) calcBalanceDue;
- (NSDecimalNumber *) calcClosedItemsBalance;
- (NSDecimalNumber *) calculateProfitMargin;

#pragma mark -
#pragma mark Refund methods
-(TenderDecision) isRefundEligble;

- (Refund *) getRefundInfo;
- (NSDecimalNumber *) calcRefundTotal;

@end
