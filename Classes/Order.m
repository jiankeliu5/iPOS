//
//  Order.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Order.h"
#import "OrderXmlMarshaller.h"
#import "iPOSFacade.h"

@interface Order()

@end

@implementation Order

@synthesize orderId;
@synthesize orderTypeId;
@synthesize salesPersonEmployeeId;
@synthesize notes;
@synthesize purchaseOrderId;
@synthesize depositAuthorizationID;
@synthesize followUpDate;
@synthesize orderDCTO;
@synthesize promiseDate;
@synthesize requestDate;
@synthesize selectionId;
@synthesize taxExempt;
@synthesize isNewOrder;
@synthesize store;
@synthesize customer;
@synthesize previousPayments;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
            
    if (self == nil) {
        return self;
    }
    
    orderItemList = [[NSMutableArray arrayWithCapacity:0] retain];
    previousPayments = [[NSMutableArray arrayWithCapacity:0] retain];
    
    return self;
}

-(void) dealloc {
    
    [orderId release];
    orderId = nil;
    [orderTypeId release];
    orderTypeId = nil;
    [salesPersonEmployeeId release];
    salesPersonEmployeeId = nil;
    [notes release];
    notes = nil;
    [purchaseOrderId release];
    purchaseOrderId = nil;
    [depositAuthorizationID release];
    depositAuthorizationID = nil;
    [followUpDate release];
    followUpDate = nil;
    [orderDCTO release];
    orderDCTO = nil;
    [promiseDate release];
    promiseDate = nil;
    [requestDate release];
    requestDate = nil;
    [selectionId release];
    selectionId = nil;
    [store release];
    store = nil;
    [customer release];
    customer = nil;
    [previousPayments release];
    previousPayments = nil;
    
    [orderItemList release];
    orderItemList = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma Accessor Methods
- (void) setAsQuote {
    orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_QUOTE];
    
    // Open all order items
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            [item setStatusToOpen];
        }
    }
}

- (void) setAsNewOrder {
    self.orderTypeId = nil;
    
    self.isNewOrder = YES;
    
    // Set the new order type
    if ([self isClosed]) {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_CLOSED];
    } else {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_OPEN];
    }
}

- (NSNumber *) getOrderTypeId {
    // Determine if all items are closed or some are open.  Do this check for safety.
    if (isNewOrder && ![self isQuote] && ![self isClosed]) {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_OPEN];
    }
    
    return self.orderTypeId;
}

- (BOOL) isQuote {
    if (orderTypeId && [orderTypeId intValue]  == ORDER_TYPE_QUOTE) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isClosed {
    if (orderTypeId && [orderTypeId intValue]  == ORDER_TYPE_CLOSED) {
        return YES;
    }
    
    // Determine if all items are closed or some are open
    for (OrderItem *orderItem in orderItemList) {
        if (![orderItem isClosed]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark Existing Orders Methods
- (BOOL) canViewDetails {
    return ([self.orderTypeId intValue] != ORDER_TYPE_CANCELLED);
}

- (BOOL) canEditDetails {
    if ([self.orderTypeId intValue] == ORDER_TYPE_CLOSED || [self.orderTypeId intValue] == ORDER_TYPE_RETURNED) {
        return NO;
    }
    return YES;
}

- (BOOL) canCancel {
    // TODO:  Does it make sense to cancel a quote ??
    // Can only cancel an order if it is in quote or open status and all items in it are in open status
    if ([self.orderTypeId intValue] == ORDER_TYPE_OPEN || [self.orderTypeId intValue] == ORDER_TYPE_QUOTE) {
        for (OrderItem *orderItem in orderItemList) {
            if ([orderItem isOpen] == NO) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL) isModified {
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            if (item.isModified) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark -
#pragma mark Marshalling
+ (Order *) fromXml:(NSString *)xmlString {
    OrderXmlMarshaller *marshaller = [[[OrderXmlMarshaller alloc] init] autorelease];
    return (Order *) [marshaller toObject:xmlString];
}

- (NSString *) toXml {
    OrderXmlMarshaller *marshaller = [[[OrderXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

#pragma mark -
#pragma mark Validation methods
- (BOOL) validateAsNew {
    if (self.orderId != nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = [NSString stringWithFormat:@"Order is seems to have been alread created with id '%@'.", self.orderId];
        error.reference = self;
        
        [self addError:error];
        return NO;
    } 
    
    return YES;        
}

- (BOOL) validateAsNewQuote {
    [self validateAsNew];
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL) validateAsNewOrder {
    [self validateAsNew];
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark OrderItems Get Accessors
-(NSArray *) getOrderItems {
    return orderItemList;
}

- (NSArray *) getOrderItemsSortedByStatus {
    // Sort the items by description
    NSArray *sortedOrderItemsList = nil;
    
    if ([orderItemList count] > 0) {
        NSSortDescriptor *itemDetailStatusDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"statusId"
                                                                            ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:itemDetailStatusDescriptor, nil];
        sortedOrderItemsList = [[NSArray arrayWithArray: orderItemList] sortedArrayUsingDescriptors:sortDescriptors];
        
        return sortedOrderItemsList;
    } 
    
    return orderItemList;
}

- (NSArray *) getOrderItemsSortedByStatusFilterCanceled {
    NSArray *sorted = [self getOrderItemsSortedByStatus];
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:0];
    
    if (sorted && [sorted count] > 0) {
        for (OrderItem *item in sorted) {
            if (![item isCanceled]) {
                [filtered addObject:item];
            }
        }
    }
    
    return filtered;
}

-(void) addItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity {
    
    if (orderItemList != nil) {
        // We can add multiple items of the same type to an order
        OrderItem *orderItem = [[[OrderItem alloc] initWithItem:item AndQuantity:quantity] autorelease];
        
        [orderItemList addObject:orderItem];

        // Set the line number based on the index the item was added in
        orderItem.lineNumber = [NSNumber numberWithInt: [orderItemList count]];
        
        // Set the selling price to the retail price
        // Default the status to 1 (Open)
        [orderItem setStatusToOpen];
        
        // Set the order item to be a newly added
        orderItem.isNew = YES;
    }
}

- (void) addOrderItemToOrder:(OrderItem *)orderItem {
    
    // set the sales person id for the order item
    if (!orderItem.salesPersonEmployeeId) {
        orderItem.salesPersonEmployeeId = [iPOSFacade sharedInstance].sessionInfo.employeeId;
    }
    
    [orderItemList addObject:orderItem];
}

-(void) removeItemFromOrder:(OrderItem *)item {
    if (orderItemList != nil) {
        
        // Remove the instance of order item
        for (OrderItem *orderItem in orderItemList) {
            if (orderItem == item) {
                
                // Set the item to canceled if it is an existing item
                if (isNewOrder || orderItem.isNew) {
                    [orderItemList removeObject:orderItem];
                } else {
                    [orderItem setStatusToCancel]; 
                }
                break;
            }
        }   
        
        // Adjust the line number for the remaining order items (Start at 1)
        int index = 1;
        for (OrderItem *orderItem in orderItemList) {
            orderItem.lineNumber = [NSNumber numberWithInt:index++];
        }
    }
    
}

-(void) removeAll {
    if (orderItemList != nil) {
        [orderItemList removeAllObjects];
    }
}

- (void) mergeWith:(Order *) mergeOrder {
    // If there are errors just merge the errors, otherwise merge everything else
    if (mergeOrder.errorList && [mergeOrder.errorList count] > 0) {
        self.errorList = [NSArray arrayWithArray: mergeOrder.errorList];
        return;
    }

    if (mergeOrder.orderId && ![mergeOrder.orderId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        self.orderId = mergeOrder.orderId;
        
        // Set the items to unmodified
        self.isNewOrder = NO;
        
        for (OrderItem *item in orderItemList) {
            item.isModified = NO;
            item.isNew = NO;
        }
    }
}

- (void) cancelOrder {
    // Make sure all open items are canceled
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            if ([item.statusId intValue] == LINE_ORDERSTATUS_OPEN) {
                item.isModified = YES;
                item.statusId = [NSNumber numberWithInt: LINE_ORDERSTATUS_CANCEL];
            }
        }
    }
}

#pragma mark -
#pragma mark Order Calculations
- (NSDecimalNumber *) calcOrderRetailSubTotal {
    NSDecimalNumber *retailTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen] || [item isClosed]) {
            retailTotal = [[item calcLineRetailSubTotal] decimalNumberByAdding:retailTotal];
        }
    }
    
    return retailTotal;
}

- (NSDecimalNumber *) calcOrderSubTotal {
    NSDecimalNumber *subTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen] || [item isClosed]) {
            subTotal = [[item calcLineSubTotal] decimalNumberByAdding:subTotal];
        }
    }
    
    return subTotal;
}

- (NSDecimalNumber *) calcOrderTax {
    BOOL custTaxExempt = NO;
	
	// If the customer is not set yet, we will assume that they are not tax exempt
	if (customer != nil && [customer taxExempt] == YES) {
		custTaxExempt = YES;
	}
	
	NSDecimalNumber *taxTotal = [NSDecimalNumber zero];
    for (OrderItem *item in orderItemList) {
        // If the customer is tax exempt we won't bother with checking further or calculating the tax amount for the line item
        // If the customer is not tax exempt we also need to see if the line item itself is tax exempt or not.
        // Possible concern:  We are allocating a lot of autoreleased NSDecimalNumber objects here.  Performance issue?
        if ([item isOpen] || [item isClosed]) {
            if (custTaxExempt == NO && ![item isTaxExempt]) {
                taxTotal = [[item calcLineTax] decimalNumberByAdding:taxTotal];
            }
        }
    }
    
    return taxTotal;        
}

- (NSDecimalNumber *) calcOrderTotal {
    return [[self calcOrderSubTotal] decimalNumberByAdding:[self calcOrderTax]];
}

- (NSDecimalNumber *) calcOrderDiscountTotal {
    NSDecimalNumber *discountTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen] || [item isClosed]) {
            discountTotal = [[item calcLineDiscount] decimalNumberByAdding:discountTotal];
        }
    }
    
    return discountTotal;
}

- (NSDecimalNumber *) calcBalanceDue {
    
    NSDecimalNumber *balanceDue = [NSDecimalNumber zero];
    NSDecimalNumber *balancePaid = [self calcBalancePaid];
    
    if (customer) {
        NSDecimalNumber *balanceClosedItems = [self calcClosedItemsBalance];
        
        if ([customer isRetailCustomer]) {
            // Retail customers pay 50% of total balance or total of all closed items (whichever is greater)
            NSDecimalNumber *balance50Percent = [[[self calcOrderSubTotal] 
                                                  decimalNumberByAdding:[self calcOrderTax]] 
                                                  decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString: @"0.5"]];
            if ([balanceClosedItems compare:balance50Percent] == NSOrderedDescending) {
                balanceDue = [balanceDue decimalNumberByAdding:balanceClosedItems];
            } else {
                balanceDue = [balanceDue decimalNumberByAdding:balance50Percent];
            }
        } else {
            // Assume the customer is a Contractor and only pays for closed items
            balanceDue = [balanceDue decimalNumberByAdding:balanceClosedItems];
        }
        
        balanceDue = [balanceDue decimalNumberBySubtracting:balancePaid];
        
        if ([balanceDue intValue] < 0) {
            return [NSDecimalNumber zero];
        }
    }
    
    return balanceDue;
}

- (NSDecimalNumber *) calcBalanceOwing {
    NSDecimalNumber *total = [self calcOrderTotal];
    NSDecimalNumber *balancePaid = [self calcBalancePaid];
    
    return [total decimalNumberBySubtracting:balancePaid];
}

- (NSDecimalNumber *) calcBalancePaid {
    NSDecimalNumber *balancePaid = [NSDecimalNumber zero];

    if (previousPayments && [previousPayments count] > 0) {
        for (Payment *payment in previousPayments) {
            balancePaid = [balancePaid decimalNumberByAdding:payment.paymentAmount];
        }
    }
    
    return balancePaid;
}

/* Calculates the profit margin for a given order 
 For display use banker rounding - look at cart display for example*/
-(NSDecimalNumber *) calculateProfitMargin {
    NSDecimalNumber *totalExtendedCost = [NSDecimalNumber zero];
    NSDecimalNumber *totalExtendedPrice = [NSDecimalNumber zero];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen] || [item isClosed]) {
            totalExtendedCost = [totalExtendedCost decimalNumberByAdding:item.calculateExtendedCost];
            totalExtendedPrice = [totalExtendedPrice decimalNumberByAdding:item.calculateExtendedPrice];
        }
    }
    
    
    NSDecimalNumber *costTimesPrice = [totalExtendedCost decimalNumberByDividingBy: totalExtendedPrice];
    
    NSDecimalNumber *oneMinusCostPrice = [[NSDecimalNumber one] decimalNumberBySubtracting: costTimesPrice  ];
        
    NSDecimalNumber *tempMargin = [oneMinusCostPrice decimalNumberByMultiplyingBy: 
                                   [NSDecimalNumber decimalNumberWithString:@"100.0"] withBehavior: roundUp];
    
    NSDecimalNumber *pointFive = [NSDecimalNumber decimalNumberWithString:@"0.05"];
    NSDecimalNumber *profitMargin = [tempMargin decimalNumberBySubtracting: [tempMargin decimalNumberByMultiplyingBy: pointFive]];
    
    return profitMargin;
}

- (NSDecimalNumber *) calcClosedItemsBalance {
    NSDecimalNumber *balance = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isClosed]) {
            // Fixed to ensure balance is accumulative [Defect:  2011-06-01]
            balance = [balance decimalNumberByAdding:[[item calcLineSubTotal] decimalNumberByAdding: [item calcLineTax]]];
        }
    }
    
    return balance;
        
}

#pragma mark -
#pragma mark Refund methods
- (Refund *) getRefundInfo {
    // TODO: Replace with actual building of a Refund object
    Refund *refund = [[[Refund alloc] init] autorelease];
    
    // Add 4 refund items
    RefundItem *refundItem1 = [[[RefundItem alloc] init] autorelease];
    RefundItem *refundItem2 = [[[RefundItem alloc] init] autorelease];
    RefundItem *refundItem3 = [[[RefundItem alloc] init] autorelease];
    RefundItem *refundItem4 = [[[RefundItem alloc] init] autorelease];
    RefundItem *refundItem5 = [[[RefundItem alloc] init] autorelease];
    
    CreditCardPayment *ccPay1 = [[[CreditCardPayment alloc] init] autorelease];
    CreditCardPayment *ccPay2 = [[[CreditCardPayment alloc] init] autorelease];
    CreditCardPayment *ccPay3 = [[[CreditCardPayment alloc] init] autorelease];
    
    refundItem1.orderPaymentTypeID = [NSNumber numberWithInt:ONACCT];
    refundItem1.amount = [NSDecimalNumber decimalNumberWithString:@"40.00"];
    
    refundItem2.orderPaymentTypeID = [NSNumber numberWithInt:CREDITCARD_VISA];
    refundItem2.amount = [NSDecimalNumber decimalNumberWithString:@"50.00"];
    ccPay1.paymentRefId = @"ref1";
    ccPay1.cardNumber = @"1234";
    refundItem2.creditCard = ccPay1;
    
    refundItem3.orderPaymentTypeID = [NSNumber numberWithInt:CREDITCARD_VISA];
    refundItem3.amount = [NSDecimalNumber decimalNumberWithString:@"30.00"];
    ccPay2.paymentRefId = @"ref2";
    ccPay2.cardNumber = @"4567";
    refundItem3.isSignatureRequired = YES;
    refundItem3.creditCard = ccPay2;
    
    refundItem4.orderPaymentTypeID = [NSNumber numberWithInt:CREDITCARD_VISA];
    refundItem4.amount = [NSDecimalNumber decimalNumberWithString:@"25.00"];
    refundItem4.creditCard = ccPay3;
    
    refundItem5.orderPaymentTypeID = [NSNumber numberWithInt:CASH];
    refundItem5.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    
    refund.refundItems = [NSArray arrayWithObjects:refundItem1, refundItem2, refundItem3, refundItem4, refundItem5, nil];
    
    return refund;
}

- (NSDecimalNumber *) calcRefundTotal {
    //TODO: Implement this method
    return [NSDecimalNumber decimalNumberWithString:@"150.00"];
}

-(TenderDecision) isRefundEligble{
    NSDecimalNumber *balanceOwing = [self calcBalanceOwing];

    NSComparisonResult comparisonresult = [[NSDecimalNumber zero] compare:balanceOwing];
    
    if (comparisonresult == NSOrderedSame) {
        return NOCHANGE;
    } else if (comparisonresult == NSOrderedAscending) {
        return TENDER;
    }
    else {
        return REFUND;
    }
}


@end
