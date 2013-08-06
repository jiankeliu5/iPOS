//
//  Order.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Order.h"
#import "OrderXmlMarshaller.h"
#import "NSString+StringFormatters.h"

#import "iPOSFacade.h"

@interface Order()

// Refund Methods
- (NSDecimalNumber *) refundForOnAccount:refund withAmount: refundAmount;
- (NSDecimalNumber *) refundForCCWithSignature:refund withAmount: refundAmount;
- (NSDecimalNumber *) refundForCCWithSwipeAndSignature:refund withAmount: refundAmount;
- (NSDecimalNumber *) refundForToCCT:refund withAmount: refundAmount;
- (NSDecimalNumber *) refundForToPOS:refund withAmount: refundAmount;

- (NSArray *) groupCCPayments: (NSArray *) ccPayments;
- (NSArray *) groupToPOSPayments: (NSArray *) paymentList;

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
//Enning Tang added currentVersion 3/20/2013
@synthesize currentVersion;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return self;
    }
    
    orderItemList = [[NSMutableArray arrayWithCapacity:0] retain];
    previousPayments = [[NSMutableArray arrayWithCapacity:0] retain];
    
    isNewOrder = YES;
    
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

- (void) setAsCanceled {
    self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_CANCELLED];
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            [item setStatusToCancel];
        }
    }
}

- (void) setAsClosed {
    self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_CLOSED];
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            [item setStatusToClosed];
        }
    }
}

//Enning Tang set header closed 3/20/2013
- (void) setHeaderClosed {
    self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_CLOSED];
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
    
    // Determine if all items are closed or some are open (ignore returned)
    for (OrderItem *orderItem in orderItemList) {
        if (![orderItem isClosed] && ![orderItem isReturned]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) isCanceled {
    if (orderTypeId && [orderTypeId intValue]  == ORDER_TYPE_CANCELLED) {
        return YES;
    }
    
    // Determine if all items are canceled (ignore returned)
    for (OrderItem *orderItem in orderItemList) {
        if (![orderItem isCanceled] && ![orderItem isReturned]) {
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
    // Can only cancel an order if it is in quote or open status and all items in it are in open or canceled status
    if ([self.orderTypeId intValue] == ORDER_TYPE_OPEN || [self.orderTypeId intValue] == ORDER_TYPE_QUOTE) {
        for (OrderItem *orderItem in orderItemList) {
            if ([orderItem isOpen] == NO && [orderItem isCanceled] == NO) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL) canApplyDiscount: (NSDecimalNumber *) discountAmt {
    NSDecimalNumber *openItemTotal = [self calcOpenItemsSubTotal];
    
    if ([discountAmt compare:openItemTotal] == NSOrderedAscending) {
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

- (BOOL) purchaseOrderInfoRequired {
    if (customer && ([customer isPaymentOnAccountEligable] || [customer isContractor])) {
        return YES;
    }
    
    return NO;
}

- (BOOL) purchaseOrderInfoRequiredForCash {
    if (customer && [customer isContractor]) {
        return YES;
    }
    
    return NO;
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
        NSSortDescriptor *openItemStatusDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"openItemStatus"
                                                                                  ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:itemDetailStatusDescriptor, openItemStatusDescriptor, nil];
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

- (NSArray *) getOrderItems:(LineOrderStatus)lineItemStatus {
    NSMutableArray *itemsByStatus = [NSMutableArray arrayWithCapacity:0];
    
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            if ([item.statusId intValue] == lineItemStatus) {
                [itemsByStatus addObject:item];
            }
        }
    }
    
    return itemsByStatus;
}

-(void) addItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity {
    
    NSLog(@"Order.m addItemToOrder called");
    
    //Enning Tang Check if outside freight is taxFree
    
    NSLog(@"Item ID: %@", item.itemId.stringValue);
    if ([item.itemId isEqualToNumber:[NSNumber numberWithInt:5000042]])
    {
        NSLog(@"deal with outside freight order.m");
        NSLog(@"Store ID: %@", item.store.storeId.stringValue);
        //if ([iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:100] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:900] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:1700] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:1900] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:2400] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:3400] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:3600] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:4200] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:4300] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:4500] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:5000] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:6400] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:1200])
        if ([item.store.storeId isEqualToNumber:[NSNumber numberWithInt:100]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:900]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:1700]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:1900]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:2400]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:3400]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:3600]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:4200]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:4300]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:4500]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:5000]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:6400]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:7000]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:7100]])
        {
            NSLog(@"Set to 0");
            item.taxRate = [NSDecimalNumber zero];
        }
    }
    
    if (orderItemList != nil) {
        // We can add multiple items of the same type to an order
        NSLog(@"quantityAdded to array: %@", quantity.stringValue);
        OrderItem *orderItem = [[[OrderItem alloc] initWithItem:item AndQuantity:quantity] autorelease];
        
        NSLog(@"item primaryUOM: %@", item.primaryUnitOfMeasure);
        
        [orderItemList addObject:orderItem];
        
        // Set the line number based on the index the item was added in
        orderItem.lineNumber = [NSNumber numberWithInt: [orderItemList count]];
        
        // Set the selling price to the retail price
        // Default the status to 1 (Open)
        [orderItem setStatusToOpen];
        
        // Set the order item to be a newly added
        orderItem.isNew = YES;
        
    }
    else {
        NSLog(@"Order.m addItemToOrder orderItemList is nil");
    }
}

//Enning Tang addReturnItemToOrder 3/22/2013
-(void) addReturnItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity SellingPricePrimary:SellingPricePrimary SellingPriceSecondary:SellingPriceSecondary{
    
    NSLog(@"Order.m addReturnItemToOrder called");
    
    //Enning Tang Check if outside freight is taxFree
    
    NSLog(@"Item ID: %@", item.itemId.stringValue);
    if ([item.itemId isEqualToNumber:[NSNumber numberWithInt:5000042]])
    {
        NSLog(@"deal with outside freight order.m");
        NSLog(@"Store ID: %@", item.store.storeId.stringValue);
        //if ([iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:100] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:900] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:1700] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:1900] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:2400] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:3400] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:3600] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:4200] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:4300] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:4500] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:5000] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:6400] || [iPOSFacade sharedInstance].sessionInfo.storeId == [NSNumber numberWithInt:1200])
        if ([item.store.storeId isEqualToNumber:[NSNumber numberWithInt:100]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:900]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:1700]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:1900]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:2400]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:3400]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:3600]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:4200]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:4300]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:4500]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:5000]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:6400]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:7000]] || [item.store.storeId isEqualToNumber:[NSNumber numberWithInt:7100]])
        {
            NSLog(@"Set to 0");
            item.taxRate = [NSDecimalNumber zero];
        }
    }
    
    if (orderItemList != nil) {
        // We can add multiple items of the same type to an order
        NSLog(@"quantityAdded to array: %@", quantity.stringValue);
        OrderItem *orderItem = [[OrderItem alloc] initWithReturnItem:item AndQuantity:quantity SellingPricePrimary:SellingPricePrimary SellingPriceSecondary:SellingPriceSecondary];
        
        [orderItemList addObject:orderItem];
        
        // Set the line number based on the index the item was added in
        orderItem.lineNumber = [NSNumber numberWithInt: [orderItemList count]];
        
        // Set the selling price to the retail price
        [orderItem setStatusToReturn];
        
        // Set the order item to be a newly added
        orderItem.isNew = YES;
        
    }
    else {
        NSLog(@"Order.m addReturnItemToOrder orderItemList is nil");
    }
}
//==========================================

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
        
        // Adjust the line number for the remaining order items (Start at 1) for new orders
        if (isNewOrder || item.isNew) {
            int index = 1;
            for (OrderItem *orderItem in orderItemList) {
                if (orderItem.isNew || orderItem.orderId == nil) {
                    orderItem.lineNumber = [NSNumber numberWithInt:index++];
                } else {
                    // Do not change line numbers for existing line items.
                    index++;
                }
            }
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
        if ([item isOpen] || [item isClosed] || [item isReturned]) {
            retailTotal = [[item calcLineRetailSubTotal] decimalNumberByAdding:retailTotal];
        }
    }
    
    return retailTotal;
}

- (NSDecimalNumber *) calcOrderSubTotal {
    NSDecimalNumber *subTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen] || [item isClosed] || [item isReturned]) {
            subTotal = [[item calcLineSubTotal] decimalNumberByAdding:subTotal];
        }
    }
    
    return subTotal;
}

- (NSDecimalNumber *) calcOpenItemsSubTotal {
    NSDecimalNumber *subTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen]) {
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
        if ([item isOpen] || [item isClosed] || [item isReturned]) {
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
        
        //Enning Tang added check contractor 1, if contractor 1 pay 50% first
        if ([customer isRetailCustomer] || [customer isContractor1]) {
            // Retail customers or Contractor 1 pay 50% of total balance or total of all closed items (whichever is greater)
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
    
    @try {
        NSDecimalNumber *costTimesPrice = [totalExtendedCost decimalNumberByDividingBy: totalExtendedPrice];
        
        NSDecimalNumber *oneMinusCostPrice = [[NSDecimalNumber one] decimalNumberBySubtracting: costTimesPrice  ];
        
        NSDecimalNumber *tempMargin = [oneMinusCostPrice decimalNumberByMultiplyingBy:
                                       [NSDecimalNumber decimalNumberWithString:@"100.0"] withBehavior: roundUp];
        
        NSDecimalNumber *pointFive = [NSDecimalNumber decimalNumberWithString:@"0.05"];
        NSDecimalNumber *profitMargin = [tempMargin decimalNumberBySubtracting: [tempMargin decimalNumberByMultiplyingBy: pointFive]];
        return profitMargin;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return 0;
    }
    //return profitMargin;
}

- (NSDecimalNumber *) calcClosedItemsBalance {
    NSDecimalNumber *balance = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        // FIX:  Need to include returned items in the closed items balance (subtract from total)
        if ([item isClosed] || [item isReturned]) {
            // Fixed to ensure balance is accumulative [Defect:  2011-06-01]
            NSDecimalNumber *tax = [NSDecimalNumber decimalNumberWithString:@"0.00"];
            
            if (!customer.taxExempt && ![item isTaxExempt]) {
                tax = [item calcLineTax];
            }
            balance = [balance decimalNumberByAdding:[[item calcLineSubTotal] decimalNumberByAdding:tax]];
        }
    }
    
    return balance;
    
}

#pragma mark -
#pragma mark Refund methods
- (NSDecimalNumber *) calcRefundTotal {
    
    NSDecimalNumber *refundAmount = [self calcBalanceOwing];
    
    if ([refundAmount intValue] < 0) {
        return refundAmount;
    }
    
    return [NSDecimalNumber zero];
}

-(TenderDecision) isRefundEligble {
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *balanceOwingInMoney = [[self calcBalanceOwing] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    NSComparisonResult comparisonresult = [[NSDecimalNumber zero] compare:balanceOwingInMoney];
    
    if (comparisonresult == NSOrderedSame) {
        return NOCHANGE;
    } else if (comparisonresult == NSOrderedAscending) {
        return TENDER;
    }
    else {
        return REFUND;
    }
}

- (Refund *) getRefundInfo {
    NSDecimalNumber *refundAmount = [self calcBalanceOwing];
    Refund *refund = [[[Refund alloc] init] autorelease];
    
    // Set info for the refund
    refund.orderId = orderId;
    
    if (customer) {
        refund.customerId = customer.customerId;
    }
    
    refund.refundDate = [NSString formatDateAsTimestamp:[NSDate date]];
    
    if ([refundAmount compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                          exponent:0
                                                                        isNegative:YES];
        refundAmount = [refundAmount decimalNumberByMultiplyingBy:negativeOne];
    }
    
    if ([refundAmount intValue] > 0 && previousPayments && [previousPayments count] > 0) {
        // Build the refund items, by order of precedence (on acct, credit card signature only, credit card swipe & signature, to CCT, to POS)
        refundAmount = [self refundForOnAccount:refund withAmount:refundAmount];
        
        if ([refundAmount intValue] > 0) {
            refundAmount = [self refundForCCWithSignature:refund withAmount:refundAmount];
            
            if ([refundAmount intValue] > 0) {
                refundAmount = [self refundForCCWithSwipeAndSignature:refund withAmount:refundAmount];
                
                if ([refundAmount intValue] > 0) {
                    refundAmount = [self refundForToCCT:refund withAmount:refundAmount];
                    
                    if ([refundAmount intValue] > 0) {
                        refundAmount = [self refundForToPOS:refund withAmount:refundAmount];
                    }
                }
            }
        }
        
        // There should be no refund balance remaining at this point since we distributed accordingly above.
        //If there is, add another cash refund
        if ([refundAmount intValue] > 0) {
            NSLog(@"There is a refund amount left over of $%@.  Applying it as a cach refund.", refundAmount);
            
            RefundItem *cashItem = [[RefundItem alloc] init];
            cashItem.orderPaymentTypeID = [NSNumber numberWithInt:CASH];
            cashItem.amount = refundAmount;
            cashItem.toPOS = YES;
            
            [refund addRefundItem:cashItem];
            
            [cashItem release];
        }
    }
    
    return refund;
}

- (NSDecimalNumber *) refundForOnAccount:(id)refund withAmount:(id)refundAmount {
    NSDecimalNumber *refundLeft = refundAmount;
    NSDecimalNumber *totalPaymentAmount = [NSDecimalNumber zero];
    
    RefundItem *onAcctItem = [[RefundItem alloc] init];
    
    @try {
        onAcctItem.orderPaymentTypeID = [NSNumber numberWithInt:ONACCT];
        
        // Loop through payments, find on account payments to determine how much to apply for the refund
        if (previousPayments && [previousPayments count] > 0) {
            for (Payment *payment in previousPayments) {
                if ([payment.paymentTypeId intValue] == ONACCT) {
                    totalPaymentAmount = [totalPaymentAmount decimalNumberByAdding:payment.paymentAmount];
                }
            }
        }
        
        if ([totalPaymentAmount compare:[NSDecimalNumber zero]] == NSOrderedSame) {
            return refundLeft;
        }
        
        // Determine the refund amount to apply
        if ([refundLeft compare:totalPaymentAmount] == NSOrderedAscending || [refundLeft compare:totalPaymentAmount] == NSOrderedSame) {
            onAcctItem.amount = refundLeft;
            refundLeft = [NSDecimalNumber zero];
        } else {
            onAcctItem.amount = totalPaymentAmount;
            refundLeft = [refundLeft decimalNumberBySubtracting:totalPaymentAmount];
        }
        
        onAcctItem.isSignatureRequired = YES;
        [refund addRefundItem:onAcctItem];
        
        return refundLeft;
    } @finally {
        [onAcctItem release];
        onAcctItem = nil;
    }
}

- (NSDecimalNumber *) refundForCCWithSignature:(id)refund withAmount:(id)refundAmount {
    NSMutableArray *sameStoreCCWithRefIdList = [NSMutableArray arrayWithCapacity:0];
    NSDecimalNumber *refundLeft = refundAmount;
    
    if ([refundLeft compare:[NSDecimalNumber zero]] == NSOrderedDescending && previousPayments && [previousPayments count] > 0) {
        
        // Pass 1, pullout matching payments
        for (Payment *payment in previousPayments) {
            if (payment.paymentTypeId && ([payment.paymentTypeId intValue] == CREDITCARD_VISA
                                          || [payment.paymentTypeId intValue] == CREDITCARD_MC
                                          || [payment.paymentTypeId intValue] == CREDITCARD_DISCOVER
                                          || [payment.paymentTypeId intValue] == CREDITCARD_AX)) {
                
                // Do I add the payment to the array or not (has ref id and store IDs match)
                if (payment.paymentRefId
                    && ![payment.paymentRefId isEqualToString:@"0"]
                    && ![payment.paymentRefId isEqualToString:@""]
                    && payment.storeId
                    && [payment.storeId isEqualToNumber:[iPOSFacade sharedInstance].sessionInfo.storeId]) {
                    [sameStoreCCWithRefIdList addObject:payment];
                }
            }
        }
        
        // Build merged/grouped cc payment mapped by token, refId or toCCT
        NSArray *groupedPayments =  [self groupCCPayments:sameStoreCCWithRefIdList];
        
        if (groupedPayments && [groupedPayments count] > 0) {
            // Sort the array by payment amount descending
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"paymentAmount"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            groupedPayments = [groupedPayments sortedArrayUsingDescriptors:sortDescriptors];
            
            // Apply refund amount from max cc payment amount to least
            RefundItem *refundItem = nil;
            
            for (CreditCardPayment *ccPayment in groupedPayments) {
                refundItem = [[RefundItem alloc] init];
                refundItem.isSignatureRequired = YES;
                refundItem.orderPaymentTypeID = ccPayment.paymentTypeId;
                refundItem.creditCard = ccPayment;
                
                if ([refundLeft compare:ccPayment.paymentAmount] == NSOrderedAscending || [refundLeft compare:ccPayment.paymentAmount] == NSOrderedSame) {
                    refundItem.amount = refundLeft;
                    refundLeft = [NSDecimalNumber zero];
                } else {
                    refundItem.amount = ccPayment.paymentAmount;
                    refundLeft = [refundLeft decimalNumberBySubtracting:ccPayment.paymentAmount];
                }
                
                [refund addRefundItem:refundItem];
                [refundItem release];
                refundItem = nil;
            }
        }
    }
    
    return refundLeft;
}

- (NSDecimalNumber *) refundForCCWithSwipeAndSignature:(id)refund withAmount:(id)refundAmount {
    NSMutableArray *diffStoreCCWithRefIdList = [NSMutableArray arrayWithCapacity:0];
    NSDecimalNumber *refundLeft = refundAmount;
    
    if ([refundLeft intValue] > 0 && previousPayments && [previousPayments count] > 0) {
        
        // Pass 1, pullout matching payments
        for (Payment *payment in previousPayments) {
            if (payment.paymentTypeId && ([payment.paymentTypeId intValue] == CREDITCARD_VISA
                                          || [payment.paymentTypeId intValue] == CREDITCARD_MC
                                          || [payment.paymentTypeId intValue] == CREDITCARD_DISCOVER
                                          || [payment.paymentTypeId intValue] == CREDITCARD_AX)) {
                
                // Do I add the payment to the array or not (has token and store IDs do not match)
                if (((CreditCardPayment *) payment).lpToken
                    && ![((CreditCardPayment *) payment).lpToken isEqualToString:@""]
                    && ![((CreditCardPayment *) payment).lpToken isEqualToString:@"0"]
                    && payment.storeId
                    && ![payment.storeId isEqualToNumber:[iPOSFacade sharedInstance].sessionInfo.storeId]) {
                    
                    [diffStoreCCWithRefIdList addObject:payment];
                }
            }
        }
        
        // Build merged/grouped cc payment mapped by token, refId or toCCT
        NSArray *groupedPayments =  [self groupCCPayments:diffStoreCCWithRefIdList];
        
        if (groupedPayments && [groupedPayments count] > 0) {
            // Sort the array by payment amount descending
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"paymentAmount"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            groupedPayments = [groupedPayments sortedArrayUsingDescriptors:sortDescriptors];
            
            // Apply refund amount from max cc payment amount to least
            RefundItem *refundItem = nil;
            
            for (CreditCardPayment *ccPayment in groupedPayments) {
                refundItem = [[RefundItem alloc] init];
                refundItem.isSignatureRequired = YES;
                refundItem.isSwipeRequired = YES;
                refundItem.orderPaymentTypeID = ccPayment.paymentTypeId;
                refundItem.creditCard = ccPayment;
                
                if ([refundLeft compare:ccPayment.paymentAmount] == NSOrderedAscending || [refundLeft compare:ccPayment.paymentAmount] == NSOrderedSame) {
                    refundItem.amount = refundLeft;
                    refundLeft = [NSDecimalNumber zero];
                } else {
                    refundItem.amount = ccPayment.paymentAmount;
                    refundLeft = [refundLeft decimalNumberBySubtracting:ccPayment.paymentAmount];
                }
                
                [refund addRefundItem:refundItem];
                [refundItem release];
                refundItem = nil;
            }
        }
        
    }
    
    return refundLeft;
}

- (NSDecimalNumber *) refundForToCCT:(id)refund withAmount:(id)refundAmount {
    NSMutableArray *toCCTPaymentList = [NSMutableArray arrayWithCapacity:0];
    NSDecimalNumber *refundLeft = refundAmount;
    
    if ([refundLeft intValue] > 0 && previousPayments && [previousPayments count] > 0) {
        
        // Pass 1, pullout matching payments (to CCT)
        for (Payment *payment in previousPayments) {
            if (payment.paymentTypeId && ([payment.paymentTypeId intValue] == CREDITCARD_VISA
                                          || [payment.paymentTypeId intValue] == CREDITCARD_MC
                                          || [payment.paymentTypeId intValue] == CREDITCARD_DISCOVER
                                          || [payment.paymentTypeId intValue] == CREDITCARD_AX)) {
                
                // To CCT:  Different store and no token, or same store no ref id
                if ((((CreditCardPayment *) payment).lpToken == nil
                     || [((CreditCardPayment *) payment).lpToken isEqualToString:@""]
                     || [((CreditCardPayment *) payment).lpToken isEqualToString:@"0"])
                    && payment.storeId
                    && ![payment.storeId isEqualToNumber:[iPOSFacade sharedInstance].sessionInfo.storeId]) {
                    [toCCTPaymentList addObject:payment];
                } else if ((payment.paymentRefId == nil
                            || [payment.paymentRefId isEqualToString:@""]
                            || [payment.paymentRefId isEqualToString:@"0"])
                           && payment.storeId
                           && [payment.storeId isEqualToNumber:[iPOSFacade sharedInstance].sessionInfo.storeId]) {
                    [toCCTPaymentList addObject:payment];
                }
            }
        }
        
        // Build merged/grouped cc payment mapped by token, refId or toCCT
        NSArray *groupedPayments =  [self groupCCPayments:toCCTPaymentList];
        
        if (groupedPayments && [groupedPayments count] > 0) {
            // Sort the array by payment amount descending
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"paymentAmount"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            groupedPayments = [groupedPayments sortedArrayUsingDescriptors:sortDescriptors];
            
            // Apply refund amount from max cc payment amount to least
            RefundItem *refundItem = nil;
            
            for (CreditCardPayment *ccPayment in groupedPayments) {
                refundItem = [[RefundItem alloc] init];
                refundItem.orderPaymentTypeID = ccPayment.paymentTypeId;
                refundItem.creditCard = ccPayment;
                
                if ([refundLeft compare:ccPayment.paymentAmount] == NSOrderedAscending || [refundLeft compare:ccPayment.paymentAmount] == NSOrderedSame) {
                    refundItem.amount = refundLeft;
                    refundLeft = [NSDecimalNumber zero];
                } else {
                    refundItem.amount = ccPayment.paymentAmount;
                    refundLeft = [refundLeft decimalNumberBySubtracting:ccPayment.paymentAmount];
                }
                
                refundItem.toCCT = YES;
                [refund addRefundItem:refundItem];
                [refundItem release];
                refundItem = nil;
            }
        }
        
    }
    
    return refundLeft;
}

- (NSDecimalNumber *) refundForToPOS:(id)refund withAmount:(id)refundAmount {
    NSMutableArray *toPOSPaymentList = [NSMutableArray arrayWithCapacity:0];
    NSDecimalNumber *refundLeft = refundAmount;
    
    if ([refundLeft intValue] > 0 && previousPayments && [previousPayments count] > 0) {
        
        // Pass 1, pullout matching payments (to CCT)
        for (Payment *payment in previousPayments) {
            if ([payment.paymentTypeId intValue] == CASH
                || [payment.paymentTypeId intValue] == CHECK
                || [payment.paymentTypeId intValue] > ONACCT) {
                // All other types
                [toPOSPaymentList addObject:payment];
            }
        }
        
        // Build merged/grouped cc payment mapped by token, refId or toCCT
        NSArray *groupedPayments =  [self groupToPOSPayments:toPOSPaymentList];
        
        if (groupedPayments && [groupedPayments count] > 0) {
            // Sort the array by payment amount descending
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"paymentAmount"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            groupedPayments = [groupedPayments sortedArrayUsingDescriptors:sortDescriptors];
            
            // Apply refund amount from max cc payment amount to least
            RefundItem *refundItem = nil;
            
            for (Payment *payment in groupedPayments) {
                refundItem = [[RefundItem alloc] init];
                refundItem.isSignatureRequired = NO;
                refundItem.isSwipeRequired = NO;
                refundItem.orderPaymentTypeID = payment.paymentTypeId;
                
                if ([refundLeft compare:payment.paymentAmount] == NSOrderedAscending || [refundLeft compare:payment.paymentAmount] == NSOrderedSame) {
                    refundItem.amount = refundLeft;
                    refundLeft = [NSDecimalNumber zero];
                } else {
                    refundItem.amount = payment.paymentAmount;
                    refundLeft = [refundLeft decimalNumberBySubtracting:payment.paymentAmount];
                }
                
                refundItem.toPOS = YES;
                [refund addRefundItem:refundItem];
                [refundItem release];
                refundItem = nil;
            }
        }
    }
    
    return refundLeft;
}

- (NSArray *) groupCCPayments:(NSArray *) ccPayments {
    NSMutableDictionary *ccDictByCardNumAndToken = [NSMutableDictionary dictionaryWithCapacity:0];
    CreditCardPayment *groupedPayment = nil;
    NSString *key = nil;
    
    if (ccPayments && [ccPayments count] > 0) {
        for (CreditCardPayment *payment in ccPayments) {
            if (payment.lpToken) {
                key = [NSString stringWithFormat:@"token-%@", payment.lpToken];
            } else if (payment.paymentRefId) {
                key = [NSString stringWithFormat:@"refId-%@", payment.paymentRefId];
            } else {
                key = [NSString stringWithFormat:@"toCCT-%@", payment.paymentTypeId];
            }
            
            groupedPayment = [ccDictByCardNumAndToken objectForKey:key];
            
            if (!groupedPayment) {
                groupedPayment = [[CreditCardPayment alloc] initWithOrder:nil];
                groupedPayment.paymentRefId = payment.paymentRefId;
                groupedPayment.paymentAmount = payment.paymentAmount;
                groupedPayment.paymentTypeId = payment.paymentTypeId;
                groupedPayment.cardNumber = payment.cardNumber;
                groupedPayment.lpToken = payment.lpToken;
                
                [ccDictByCardNumAndToken setValue:groupedPayment forKey:key];
                [groupedPayment release];
                groupedPayment = nil;
            } else {
                // Increase total amount
                groupedPayment.paymentAmount = [groupedPayment.paymentAmount decimalNumberByAdding:payment.paymentAmount];
            }
        }
    }
    
    return [ccDictByCardNumAndToken allValues];
}

- (NSArray *) groupToPOSPayments:(NSArray *)paymentList {
    NSMutableDictionary *paymentDict = [NSMutableDictionary dictionaryWithCapacity:0];
    Payment *groupedPayment = nil;
    
    NSString *key = nil;
    
    if (paymentList && [paymentList count] > 0) {
        for (Payment *payment in paymentList) {
            key = [NSString stringWithFormat:@"%@", payment.paymentTypeId];
            
            groupedPayment = [paymentDict objectForKey:key];
            
            if (!groupedPayment) {
                switch ([payment.paymentTypeId intValue]) {
                    case CASH: {
                        groupedPayment = [[CashPayment alloc] initWithOrder:nil];
                        break;
                    }
                    case CHECK: {
                        groupedPayment = [[CheckPayment alloc] initWithOrder:nil];
                        break;
                    }
                    case INSTORE_CREDIT: {
                        groupedPayment = [[InStoreCreditPayment alloc] initWithOrder:nil];
                        break;
                    }
                    case GIFT_CARD: {
                        groupedPayment = [[GiftCardPayment alloc] initWithOrder:nil];
                        break;
                    }
                    case GOOGLE: {
                        groupedPayment = [[GooglePayment alloc] initWithOrder:nil];
                        break;
                    }
                    case HOMEDESIGN: {
                        groupedPayment = [[HomeDesignPayment alloc] initWithOrder:nil];
                        break;
                    }
                    case PAYPAL: {
                        groupedPayment = [[PayPalPayment alloc] initWithOrder:nil];
                        break;
                    }
                    default: {
                        groupedPayment = [[Payment alloc] initWithOrder:nil];
                        break;
                    }
                }
                
                groupedPayment.paymentAmount = payment.paymentAmount;
                groupedPayment.paymentTypeId = payment.paymentTypeId;
                [paymentDict setValue:groupedPayment forKey:key];
                
                [groupedPayment release];
                groupedPayment = nil;
                
            } else {
                // Increase total amount
                groupedPayment.paymentAmount = [groupedPayment.paymentAmount decimalNumberByAdding:payment.paymentAmount]; 
            }
        }
    }
    
    return [paymentDict allValues];
}

- (NSNumber *) calcOpenItemsWeight {
    NSLog(@"calcOpenItemsWeight called");
    NSNumber *WeightTotal = [NSNumber numberWithInt:0];
    
    for (OrderItem *item in orderItemList) {
        if ([item isOpen]) {
            WeightTotal = [NSNumber numberWithFloat:([[item calcLineWeight] floatValue] + [WeightTotal floatValue])];
        }
    }
    
    return WeightTotal;
}

@end
