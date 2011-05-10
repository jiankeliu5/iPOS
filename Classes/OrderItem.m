//
//  OrderItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderItem.h"

static int const STATUS_OPEN = 1;
static int const STATUS_CLOSE = 2;
static int const STATUS_RETURN = 3;
static int const STATUS_CANCEL = 4;

// Private interface
@interface OrderItem()
    - (NSDecimalNumber *) convertQuantity: (NSDecimalNumber *) quantity;
@end

@implementation OrderItem

@synthesize lineNumber, statusId, priceAuthorizationId, sellingPrice, quantity, managerApprover, item;
@synthesize doConversionToFullBoxes, shouldDelete, shouldClose;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    if (self) {
        doConversionToFullBoxes = YES;
    }
    
    return self;
}

-(id) initWithItem:(ProductItem *) productItem AndQuantity:(NSDecimalNumber *) productQuantity {
    self = [self init];
    
    if (self == nil) {
        return nil;
    }
    
    // Set the doConversionToBoxes based on item defaultToBoxes
    doConversionToFullBoxes = productItem.defaultToBox;
    
    // Default the status to open
    statusId = [[NSNumber numberWithInt:STATUS_OPEN] retain];
    
    // Default selling price to retail price
    sellingPrice = [productItem.retailPrice copy];
    
    item = [productItem retain];
    quantity = [[self convertQuantity:productQuantity] retain];
    return self;
}

-(void) dealloc {
    [lineNumber release];
    [statusId release];
    [priceAuthorizationId release];
    [sellingPrice release];
    
    if (managerApprover != nil) {
        [managerApprover release];
    }
    
    [item release];
    [quantity release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Overriden Acessors
-(void) setItem:(ProductItem *) productItem {
    if (item != productItem) {
		[item release];
		item = [productItem	retain];
        
        // Set the doConversionToBoxes based on item defaultToBoxes
        doConversionToFullBoxes = productItem.defaultToBox;
	}
}

- (void) setQuantity:(NSDecimalNumber *) newQuantity {
    if (quantity != newQuantity) {
		[quantity release];
		quantity = [[self convertQuantity:newQuantity] retain];
	}
}

- (void) setDoConversionToFullBoxes:(BOOL) newValue {
    if (doConversionToFullBoxes != newValue) {
        doConversionToFullBoxes = newValue;
        
        // Perform conversion if necessary
        NSDecimalNumber *newQuantity = [NSDecimalNumber decimalNumberWithDecimal:[quantity decimalValue]];
        [self setQuantity:newQuantity];
    }
}

#pragma mark -
#pragma mark Conversion Methods
- (BOOL) isConversionNeeded {
    BOOL isConversionNeeded = NO;
    
    if (item && 
        item.conversion && 
        item.piecesPerBox && 
        [item.conversion compare: [NSDecimalNumber decimalNumberWithString:@"1.0"]] != NSOrderedSame) {
        isConversionNeeded = YES;
    }
    
    return isConversionNeeded;
}

- (NSNumber *) getQuantityInPieces {
    if (item && 
        item.conversion && 
        item.piecesPerBox && 
        [item.conversion compare: [NSDecimalNumber decimalNumberWithString:@"1.0"]] != NSOrderedSame) {
        
        // Get the number of pieces needed
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSDecimalNumber *piecesNeeded = [[quantity decimalNumberByDividingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundUp];
        
        return piecesNeeded;
    } 
    
    return nil;
}

- (NSNumber *) getQuantityInBoxes {    
    if (item && 
        item.conversion && 
        item.piecesPerBox && 
        [item.conversion compare: [NSDecimalNumber decimalNumberWithString:@"1.0"]] != NSOrderedSame) {
        
        // Get the number of pieces needed
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        NSDecimalNumber *piecesPerBox = [NSDecimalNumber decimalNumberWithDecimal:[item.piecesPerBox decimalValue]];
        NSDecimalNumber *piecesNeeded = [NSDecimalNumber decimalNumberWithDecimal:[[self getQuantityInPieces] decimalValue]];
        NSDecimalNumber *boxesNeeded = [[piecesNeeded decimalNumberByDividingBy:piecesPerBox] decimalNumberByRoundingAccordingToBehavior:roundUp];
        
        return boxesNeeded;
    } 
    
    return nil;
}

- (NSNumber *) getPiecesPerBox {
    if (self.item == nil) {
        return nil;
    }
    
    return self.item.piecesPerBox;
}


#pragma mark -
#pragma mark Method implementations
- (void) setStatusToOpen {
    self.statusId = [NSNumber numberWithInt:STATUS_OPEN];
}

- (void) setStatusToClosed {
    self.statusId = [NSNumber numberWithInt:STATUS_CLOSE];
}

- (BOOL) allowClose {
    NSDecimalNumber *numberAvailableInStore = item.store.availability.available;
    
    // If quantity is greater do not allow a close
    if ([self.quantity compare:numberAvailableInStore] == NSOrderedDescending){
        return NO;
    }
    
    return YES;
}

- (BOOL) isTaxExempt {
    if (item == nil) {
        return NO;
    }
    
    return self.item.taxExempt;
}

- (BOOL) isClosed {
    return [self.statusId isEqualToNumber: [NSNumber numberWithInt:STATUS_CLOSE]];
}

#pragma mark -
#pragma mark Order Item Calculations
- (NSDecimalNumber *) calcLineRetailSubTotal {
    NSDecimalNumber *retailTotal = [item.retailPrice decimalNumberByMultiplyingBy:quantity];
    
    return retailTotal;
}

- (NSDecimalNumber *) calcLineSubTotal {
    NSDecimalNumber *lineTotal = [sellingPrice decimalNumberByMultiplyingBy:quantity];
    
    return lineTotal;
}

- (NSDecimalNumber *) calcLineTax {
    NSDecimalNumber *lineTax = [[item.taxRate decimalNumberByMultiplyingBy:sellingPrice] decimalNumberByMultiplyingBy:quantity];
    return lineTax;
}

-(NSDecimalNumber *) calcSellingPriceFrom:(NSDecimalNumber *)discount {
    if (quantity == nil || 
        [quantity compare:[NSDecimalNumber zero]] == NSOrderedSame ||
        [quantity compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        return sellingPrice;
    }
    
    // Calculate a new selling price
    NSDecimalNumber *newSellingPrice = [sellingPrice  decimalNumberBySubtracting:[discount decimalNumberByDividingBy:quantity]];
    return newSellingPrice;
}

- (NSDecimalNumber *) calcLineDiscount {
    NSDecimalNumber *discount = [[self calcLineRetailSubTotal] decimalNumberBySubtracting:[self calcLineSubTotal]];
    return discount;
}

- (NSString *) getQuantityForDisplay {
    NSDecimalNumber *displayQuantity = self.quantity;
    
    if ([self isConversionNeeded]) {
        NSDecimalNumberHandler *roundingUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 
                                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO]; 
        displayQuantity = [displayQuantity decimalNumberByRoundingAccordingToBehavior:roundingUp];
    }
    
    return [NSString stringWithFormat:@"%@", displayQuantity];
}

#pragma mark -
#pragma mark Private Methods
-(NSDecimalNumber *) convertQuantity: (NSDecimalNumber *) quantityToConvert {
    BOOL isConversionNeeded = [self isConversionNeeded];
        
    if (!isConversionNeeded) {
        return quantityToConvert;
    }
    
    // Get the number of pieces needed
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                       raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                       raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    // Do we convert to full boxes or not ??
    if (!doConversionToFullBoxes) {
       NSDecimalNumber *piecesNeeded = [[quantityToConvert decimalNumberByDividingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundUp];
       return [piecesNeeded decimalNumberByMultiplyingBy:item.conversion];
    }
    
    NSDecimalNumber *piecesPerBox = [NSDecimalNumber decimalNumberWithDecimal:[item.piecesPerBox decimalValue]];                                                                                                                                                                  
    NSDecimalNumber *piecesNeeded = [[quantityToConvert decimalNumberByDividingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundUp];
    NSDecimalNumber *boxesNeeded = [[piecesNeeded decimalNumberByDividingBy:piecesPerBox] decimalNumberByRoundingAccordingToBehavior:roundUp];
    return [[boxesNeeded decimalNumberByMultiplyingBy:piecesPerBox] decimalNumberByMultiplyingBy:item.conversion];
}

@end
