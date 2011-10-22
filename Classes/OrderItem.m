//
//  OrderItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderItem.h"
#import "NSString+StringFormatters.h"

// Private interface
@interface OrderItem()
- (void) convertToQuantity: (NSDecimalNumber *) productQuantity;

- (NSDecimalNumber *) adjustQuantity: (NSDecimalNumber *) quantityToConvert forUOM: (NSString *) uom;
- (NSDecimalNumber *) convertToPieces: (NSDecimalNumber *) quantityToConvert;
- (NSDecimalNumber *) convertToBoxesWithPieces: (NSDecimalNumber *) quantityToConvert;
- (NSDecimalNumber *) convertToSquareFeet: (NSDecimalNumber *) quantityInPieces;
@end

@implementation OrderItem

@synthesize sellingPricePrimary, sellingPriceSecondary, quantityPrimary, quantitySecondary;
@synthesize lineNumber, statusId, priceAuthorizationId, managerApprover, item;
@synthesize doConversionToFullBoxes, shouldDelete, shouldClose, isNewLineItem;
@synthesize requestDate, returnReferenceId, split, orderId;
@synthesize locn, lotn, lttr, mcu, nxtr, urrf, openItemStatus, spiff;
@synthesize lineStatus;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    if (self) {
        doConversionToFullBoxes = YES;
        lineStatus = LineStatusNone;
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
    statusId = [[NSNumber numberWithInt:ORDER_ITEM_STATUS_OPEN] retain];
    
    // Default selling price to retail price
    sellingPricePrimary = [productItem.retailPricePrimary copy];
    sellingPriceSecondary = [productItem.retailPriceSecondary copy];
    
    item = [productItem retain];
    
    // Is the product item quantity in primary or secondary UOM ??
    [self convertToQuantity:productQuantity];
    
    return self;
}

-(void) dealloc {
    [lineNumber release];
    [statusId release];
    [priceAuthorizationId release];
    [sellingPricePrimary release];
    [sellingPriceSecondary release];
    
    if (managerApprover != nil) {
        [managerApprover release];
    }
    
    [item release];
    [quantityPrimary release];
    [quantitySecondary release];
    
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
    [self convertToQuantity:newQuantity];
}

- (void) setDoConversionToFullBoxes:(BOOL) newValue {
    if (doConversionToFullBoxes != newValue) {
        doConversionToFullBoxes = newValue;
        
        // Perform conversion if necessary
        NSDecimalNumber *convertValue = nil;
        if (item.selectedUOM == UOMPrimary) {
            convertValue = [quantityPrimary copy];
        } else {
            convertValue = [quantitySecondary copy];
        }
        
        [self convertToQuantity:convertValue];
        [convertValue release];
    }
}

#pragma mark -
#pragma mark Custom Accessors
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

- (NSNumber *) getPiecesPerBox {
    if (self.item == nil) {
        return nil;
    }
    
    return self.item.piecesPerBox;
}

- (void) setSellingPriceFrom:(NSDecimalNumber *)discount {
    if (discount) {
        
        if (item.selectedUOM == UOMPrimary) {
            self.sellingPricePrimary = [self calcSellingPricePrimaryFrom:discount];
        } else {
            self.sellingPriceSecondary = [self calcSellingPriceSecondaryFrom:discount];
        }
    }
}

//=========================================================== 
// - setSellingPricePrimary:
//=========================================================== 
- (void)setSellingPricePrimary:(NSDecimalNumber *)aSellingPricePrimary {
    if (sellingPricePrimary != aSellingPricePrimary) {
        [aSellingPricePrimary retain];
        [sellingPricePrimary release];
        sellingPricePrimary = aSellingPricePrimary;
        
        // Convert for selling price secondary
        if ([self isConversionNeeded]) {
            [sellingPriceSecondary release];
            sellingPriceSecondary = [[aSellingPricePrimary decimalNumberByDividingBy:item.conversion] retain];
        }
    }
}
//=========================================================== 
// - setSellingPriceSecondary:
//=========================================================== 
- (void)setSellingPriceSecondary:(NSDecimalNumber *)aSellingPriceSecondary {
    if (sellingPriceSecondary != aSellingPriceSecondary) {
        [aSellingPriceSecondary retain];
        [sellingPriceSecondary release];
        sellingPriceSecondary = aSellingPriceSecondary;
        
        // Convert for selling price primary
        if ([self isConversionNeeded]) {
            [sellingPricePrimary release];
            sellingPricePrimary = [[aSellingPriceSecondary decimalNumberByMultiplyingBy:item.conversion] retain];
        }
    }
}

#pragma mark -
#pragma mark Method implementations
- (void) setStatusToOpen {
    self.statusId = [NSNumber numberWithInt:ORDER_ITEM_STATUS_OPEN];
}

- (void) setStatusToClosed {
    self.statusId = [NSNumber numberWithInt:ORDER_ITEM_STATUS_CLOSE];
}

- (void) setStatusToCancel {
    self.statusId = [NSNumber numberWithInt:ORDER_ITEM_STATUS_CANCEL];
}

- (BOOL) allowClose {
    BOOL canClose = NO;
    
    if (isNewLineItem) {
        // For a newly added line item, it can be closed if the store shows availability
        NSDecimalNumber *numberAvailableInStore = item.store.availability.availablePrimary;
        // If quantity is greater do not allow a close
        if ([self.quantityPrimary compare:numberAvailableInStore] == NSOrderedDescending){
            canClose = NO;
        }
        canClose = YES;
    } else {
        // For an existing line item, it can be closed if the status of the line item is 
        // store received
        if (self.openItemStatus != nil && [self.openItemStatus compare:OPEN_STATUS_STORE_RECEIVED] == NSOrderedSame) {
            canClose = YES;
        }
    }
    
    return canClose;
}

- (BOOL) allowEdit {
    return ([self.statusId intValue] == ORDER_ITEM_STATUS_OPEN);
}

- (BOOL) allowQuantityChange {
    return ([self.statusId intValue] == ORDER_ITEM_STATUS_OPEN && self.isNewLineItem);
}

- (BOOL) isTaxExempt {
    if (item == nil) {
        return NO;
    }
    
    return self.item.taxExempt;
}

- (BOOL) isClosed {
    return [self.statusId isEqualToNumber: [NSNumber numberWithInt:ORDER_ITEM_STATUS_CLOSE]];
}

- (BOOL) isOpen {
    return ([self.statusId intValue] == ORDER_ITEM_STATUS_OPEN);
}

#pragma mark -
#pragma mark Order Item Calculations
- (NSDecimalNumber *) calcLineRetailSubTotal {
    NSDecimalNumber *retailTotal = [item.retailPricePrimary decimalNumberByMultiplyingBy:quantityPrimary];
    
    return retailTotal;
}

- (NSDecimalNumber *) calcLineSubTotal {
    NSDecimalNumber *lineTotal = [sellingPricePrimary decimalNumberByMultiplyingBy:quantityPrimary];
    
    return lineTotal;
}

- (NSDecimalNumber *) calcLineTax {
    NSDecimalNumber *lineTax = [[item.taxRate decimalNumberByMultiplyingBy:sellingPricePrimary] decimalNumberByMultiplyingBy:quantityPrimary];
    
    return lineTax;
}

-(NSDecimalNumber *) calcSellingPricePrimaryFrom:(NSDecimalNumber *)discount {
    if (quantityPrimary == nil || 
        [quantityPrimary compare:[NSDecimalNumber zero]] == NSOrderedSame ||
        [quantityPrimary compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        return sellingPricePrimary;
    }
    
    // Calculate a new selling price
    NSDecimalNumber *newSellingPrice = [sellingPricePrimary  decimalNumberBySubtracting:[discount decimalNumberByDividingBy:quantityPrimary]];
    return newSellingPrice;
}

-(NSDecimalNumber *) calcSellingPriceSecondaryFrom:(NSDecimalNumber *)discount {
    if (quantitySecondary == nil || 
        [quantitySecondary compare:[NSDecimalNumber zero]] == NSOrderedSame ||
        [quantitySecondary compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        return quantitySecondary;
    }
    
    // Calculate a new selling price
    NSDecimalNumber *newSellingPrice = [sellingPriceSecondary  decimalNumberBySubtracting:[discount decimalNumberByDividingBy:quantitySecondary]];
    return newSellingPrice;
}

- (NSDecimalNumber *) calcLineDiscount {
    NSDecimalNumber *discount = [[self calcLineRetailSubTotal] decimalNumberBySubtracting:[self calcLineSubTotal]];
    return discount;
}

- (NSDecimalNumber *) calculateExtendedCost{ //Make sure to round up to two decimal places
    return [self.quantityPrimary decimalNumberByMultiplyingBy:self.item.standardCost withBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES]];
}

-(NSDecimalNumber *)calculateExtendedPrice { //make sure to round up to two decimal places
    return [self.quantityPrimary decimalNumberByMultiplyingBy:self.sellingPricePrimary withBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES]];
}

#pragma mark -
#pragma mark UOM toggle Support
- (void) toggleUOM {
    if (item) {
        [item toggleUOM];
    }
}

- (NSString *) getUOMForDisplay {
    if (item) {
        return [item getSelectedUOMForDisplay];
    }
    
    return @"";
}
- (NSString *) getQuantityForDisplay {
    NSDecimalNumber *displayQuantity = nil;
    
    if (item.selectedUOM == UOMPrimary) {
        displayQuantity = quantityPrimary; 
    } else {
        displayQuantity = quantitySecondary;
    }
    
    NSDecimalNumberHandler *roundingUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 
                                                                                     raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                     raiseOnUnderflow:NO raiseOnDivideByZero:NO]; 
    return [NSString stringWithFormat:@"%@", [displayQuantity decimalNumberByRoundingAccordingToBehavior:roundingUp]];
}

- (NSString *) getSellingPriceForDisplay {
    NSDecimalNumber *displayPrice = nil;
    
    if (item.selectedUOM == UOMPrimary) {
        displayPrice = sellingPricePrimary; 
    } else {
        displayPrice = sellingPriceSecondary;
    }
    
    return [NSString formatDecimalNumberAsMoney: displayPrice];
}

#pragma mark -
#pragma mark Private Methods (Conversion)
- (void) convertToQuantity:(NSDecimalNumber *)productQuantity {
    NSString *selectedUOM = nil;
    NSDecimalNumber *quantityForConversion = nil;
    
    if (item.selectedUOM == UOMPrimary) {
        selectedUOM = item.primaryUnitOfMeasure;
    } else {
        selectedUOM = item.secondaryUnitOfMeasure;
    }
    
    quantityForConversion = [self adjustQuantity:productQuantity forUOM:selectedUOM];
    
    if (![self isConversionNeeded]) {
        self.quantityPrimary = quantityForConversion;
        self.quantitySecondary = quantityForConversion;
    } else if ([item.primaryUnitOfMeasure isEqualToString:UOM_EACH]){
        if (item.selectedUOM == UOMPrimary) {
            self.quantityPrimary = [self adjustQuantity:[self convertToBoxesWithPieces:quantityForConversion] forUOM:selectedUOM];
            self.quantitySecondary = [self convertToSquareFeet:quantityPrimary];
        } else {
            self.quantityPrimary = [self adjustQuantity:[self convertToPieces:quantityForConversion] forUOM:item.primaryUnitOfMeasure];
            self.quantitySecondary = [self convertToSquareFeet:quantityPrimary];
        }
    } else if ([item.primaryUnitOfMeasure isEqualToString:UOM_COVERAGE] || [item.primaryUnitOfMeasure isEqualToString:UOM_SQFT]) {
        if (item.selectedUOM == UOMPrimary) {
            self.quantityPrimary = [self convertToSquareFeet:quantityForConversion];
            self.quantitySecondary = [self adjustQuantity:[self convertToPieces:quantityForConversion] forUOM:item.secondaryUnitOfMeasure];
        } else {
            self.quantitySecondary = [self adjustQuantity:[self convertToBoxesWithPieces:quantityForConversion] forUOM:item.secondaryUnitOfMeasure];
            self.quantityPrimary = [self convertToSquareFeet:quantitySecondary];
        }
    } else {
        // Straight conversion (NOTE:  Based on feedback from The Tile Shop, this should not happen, but I am putting it here for completeness).
        if (item.selectedUOM == UOMPrimary) {
            self.quantityPrimary = quantityForConversion;
            self.quantitySecondary = [self adjustQuantity:[quantityForConversion decimalNumberByMultiplyingBy:item.conversion] forUOM:selectedUOM];
        } else {
            self.quantityPrimary = [self adjustQuantity:[quantityForConversion decimalNumberByDividingBy:item.conversion] forUOM:item.primaryUnitOfMeasure];
            self.quantitySecondary = quantityForConversion;
        }

    }
}

/**
 * Determines if initial rounding is required.  UOMs for box, each, set, carton needs to be rounded up.
 * If the uom is sq ft, cv, lf, or qy do not perform any rounding.
 */ 
- (NSDecimalNumber *) adjustQuantity: (NSDecimalNumber *) quantityToConvert forUOM: (NSString *) uom {
    
    if ([uom isEqualToString:UOM_EACH] || [uom isEqualToString:UOM_BOX] || [uom isEqualToString:UOM_CARTON] || [uom isEqualToString:UOM_SET]) {
        // Get the number of pieces needed
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        return [quantityToConvert decimalNumberByRoundingAccordingToBehavior:roundUp];
    }
         
     return [[quantityToConvert copy] autorelease];
}

- (NSDecimalNumber *) convertToBoxesWithPieces:(NSDecimalNumber *) quantityToConvert {
    BOOL isConversionNeeded = [self isConversionNeeded];
    
    if (!isConversionNeeded) {
        return quantityToConvert;
    }
    
    // Get the number of pieces needed
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    // Do we convert to full boxes or not ??
    NSDecimalNumber *piecesNeeded = [quantityToConvert decimalNumberByRoundingAccordingToBehavior:roundUp];

    if (!doConversionToFullBoxes) {
        return piecesNeeded;
    }
    
    NSDecimalNumber *piecesPerBox = [NSDecimalNumber decimalNumberWithDecimal:[item.piecesPerBox decimalValue]]; 
    NSDecimalNumber *boxesNeeded = [[piecesNeeded decimalNumberByDividingBy:piecesPerBox] decimalNumberByRoundingAccordingToBehavior:roundUp];
    return [boxesNeeded decimalNumberByMultiplyingBy:piecesPerBox];
}


- (NSDecimalNumber *) convertToPieces:(NSDecimalNumber *) quantityToConvert {
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
        return piecesNeeded;
    }
    
    NSDecimalNumber *piecesPerBox = [NSDecimalNumber decimalNumberWithDecimal:[item.piecesPerBox decimalValue]];                                                                                                                                                                  
    NSDecimalNumber *piecesNeeded = [[quantityToConvert decimalNumberByDividingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundUp];
    NSDecimalNumber *boxesNeeded = [[piecesNeeded decimalNumberByDividingBy:piecesPerBox] decimalNumberByRoundingAccordingToBehavior:roundUp];
    return [boxesNeeded decimalNumberByMultiplyingBy:piecesPerBox];
}

- (NSDecimalNumber *) convertToSquareFeet:(NSDecimalNumber *) quantityInPieces {
    BOOL isConversionNeeded = [self isConversionNeeded];
    
    if (!isConversionNeeded) {
        return quantityInPieces;
    }
    
    // Get the number of pieces needed
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    // Do we convert to full boxes or not ??
    if (!doConversionToFullBoxes) {
        NSDecimalNumber *piecesNeeded = [quantityInPieces decimalNumberByRoundingAccordingToBehavior:roundUp];
        return [piecesNeeded decimalNumberByMultiplyingBy:item.conversion];
    }
    
    NSDecimalNumber *piecesPerBox = [NSDecimalNumber decimalNumberWithDecimal:[item.piecesPerBox decimalValue]];                                                                                                                                                                  
    NSDecimalNumber *piecesNeeded = [quantityInPieces decimalNumberByRoundingAccordingToBehavior:roundUp];
    NSDecimalNumber *boxesNeeded = [[piecesNeeded decimalNumberByDividingBy:piecesPerBox] decimalNumberByRoundingAccordingToBehavior:roundUp];
    return [[boxesNeeded decimalNumberByMultiplyingBy:piecesPerBox] decimalNumberByMultiplyingBy:item.conversion];
}

@end
