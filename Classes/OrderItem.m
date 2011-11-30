//
//  OrderItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "OrderItem.h"
#import "NSString+StringFormatters.h"

#import "NSString+Extensions.h"

// Private interface
@interface OrderItem()
- (void) convertToQuantity: (NSDecimalNumber *) productQuantity;

- (NSDecimalNumber *) adjustQuantity: (NSDecimalNumber *) quantityToConvert forUOM: (NSString *) uom;
- (NSDecimalNumber *) convertToPieces: (NSDecimalNumber *) quantityToConvert;
- (NSDecimalNumber *) convertToBoxesWithPieces: (NSDecimalNumber *) quantityToConvert;
- (NSDecimalNumber *) convertToSquareFeet: (NSDecimalNumber *) quantityInPieces;

- (void) markAsModified;

@end

@implementation OrderItem

@synthesize lineNumber;
@synthesize statusId;
@synthesize salesPersonEmployeeId;
@synthesize priceAuthorizationId;
@synthesize sellingPricePrimary;
@synthesize sellingPriceSecondary;
@synthesize quantityPrimary;
@synthesize quantitySecondary;
@synthesize requestDate;
@synthesize returnReferenceId;
@synthesize orderId;
@synthesize split;
@synthesize spiff;
@synthesize locn;
@synthesize lotn;
@synthesize lttr;
@synthesize mcu;
@synthesize nxtr;
@synthesize urrf;
@synthesize openItemStatus;
@synthesize managerApprover;
@synthesize item;
@synthesize doConversionToFullBoxes;
@synthesize shouldDelete;
@synthesize shouldClose;
@synthesize isNew;
@synthesize isModified;

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
    statusId = [[NSNumber numberWithInt:LINE_ORDERSTATUS_OPEN] retain];
    
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
    lineNumber = nil;
    [statusId release];
    statusId = nil;
    [salesPersonEmployeeId release];
    salesPersonEmployeeId = nil;
    [priceAuthorizationId release];
    priceAuthorizationId = nil;
    [sellingPricePrimary release];
    sellingPricePrimary = nil;
    [sellingPriceSecondary release];
    sellingPriceSecondary = nil;
    [quantityPrimary release];
    quantityPrimary = nil;
    [quantitySecondary release];
    quantitySecondary = nil;
    [requestDate release];
    requestDate = nil;
    [returnReferenceId release];
    returnReferenceId = nil;
    [orderId release];
    orderId = nil;
    [spiff release];
    spiff = nil;
    [locn release];
    locn = nil;
    [lotn release];
    lotn = nil;
    [lttr release];
    lttr = nil;
    [mcu release];
    mcu = nil;
    [nxtr release];
    nxtr = nil;
    [urrf release];
    urrf = nil;
    [openItemStatus release];
    openItemStatus = nil;
    [managerApprover release];
    managerApprover = nil;
    [item release];
    item = nil;
    
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

- (LineStatus) getLineStatus {
    if (isNew) {
        return LineStatusAdd;
    }
    
    if (isModified && [self.statusId intValue] == LINE_ORDERSTATUS_CANCEL) {
        return LineStatusCancel;
    }
    
    if (isModified) {
        return LineStatusModify;
    }
    
    return LineStatusNone;
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
        
        [self markAsModified];
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
    self.statusId = [NSNumber numberWithInt: LINE_ORDERSTATUS_OPEN];
    
    // Mark as modified
    [self markAsModified];
}

- (void) setStatusToClosed {
    self.statusId = [NSNumber numberWithInt: LINE_ORDERSTATUS_CLOSED];
    
    // Mark as modified
    [self markAsModified];
}

- (void) setStatusToCancel {
    self.statusId = [NSNumber numberWithInt: LINE_ORDERSTATUS_CANCEL];
    
    // Mark as modified
    [self markAsModified];
}

- (BOOL) allowClose {
    BOOL canClose = NO;
    NSString *storeIdAsStr = @""; 
    NSDecimalNumber *onHandInStore = [NSDecimalNumber zero];
    NSDecimalNumber *numberAvailableInStore= [NSDecimalNumber zero];
    
    if (!item || !item.store || !item.store.availability) {
        return NO;
    }
    
    onHandInStore = item.store.availability.onHandPrimary;
    numberAvailableInStore = item.store.availability.availablePrimary;
    storeIdAsStr = [NSString stringWithFormat:@"%@", item.store.storeId];
    
    NSComparisonResult onHandGreaterOrEqualToQuantity = [onHandInStore compare:quantityPrimary];
    NSComparisonResult availableGreaterOrEqualToQuantity = [numberAvailableInStore compare:quantityPrimary];
    NSComparisonResult onHandGreaterOrEqualAvailable = [onHandInStore compare:numberAvailableInStore];
    if (isNew) {
        if ((onHandGreaterOrEqualToQuantity == NSOrderedDescending || onHandGreaterOrEqualToQuantity == NSOrderedSame) 
            && (availableGreaterOrEqualToQuantity == NSOrderedDescending || availableGreaterOrEqualToQuantity == NSOrderedSame) 
            && (onHandGreaterOrEqualAvailable == NSOrderedDescending || onHandGreaterOrEqualAvailable == NSOrderedSame)){
            canClose = YES;
        } 
    } else {
        if (openItemStatus && [openItemStatus compare:OPEN_STATUS_STORE_RECEIVED] == NSOrderedSame) {
            canClose = YES;
        } else if ([item.statusCode compare:ITEM_STATUS_NON_STOCK] == NSOrderedSame ||
                   [item.statusCode compare:ITEM_STATUS_FREIGHT] == NSOrderedSame) {
            canClose = YES;
        } else {
            if ([lotn isEmpty] || ![mcu isEqualToString:storeIdAsStr] || ![locn isEqualToString:@"STORE"]) {
                if ((onHandGreaterOrEqualToQuantity == NSOrderedDescending || onHandGreaterOrEqualToQuantity == NSOrderedSame) 
                    && (availableGreaterOrEqualToQuantity == NSOrderedDescending || availableGreaterOrEqualToQuantity == NSOrderedSame) 
                    && (onHandGreaterOrEqualAvailable == NSOrderedDescending || onHandGreaterOrEqualAvailable == NSOrderedSame)) {
                    canClose = YES;
                } 
            } else { 
                if (onHandGreaterOrEqualAvailable == NSOrderedDescending || onHandGreaterOrEqualAvailable == NSOrderedSame) {
                    canClose = YES;
                }
            }
        }
    }
    
    return canClose;
}

- (BOOL) allowEdit {
    return ([self.statusId intValue] == LINE_ORDERSTATUS_OPEN || isModified);
}

- (BOOL) allowQuantityChange {
    return ([self.statusId intValue] == LINE_ORDERSTATUS_OPEN && isNew);
}

- (BOOL) isTaxExempt {
    if (item == nil) {
        return NO;
    }
    
    return self.item.taxExempt;
}

- (BOOL) isClosed {
    return ([self.statusId intValue] == LINE_ORDERSTATUS_CLOSED);
}

- (BOOL) isOpen {
    return ([self.statusId intValue] == LINE_ORDERSTATUS_OPEN);
}

- (BOOL) isCanceled {
    return ([self.statusId intValue] == LINE_ORDERSTATUS_CANCEL);
}

- (BOOL) isReturned {
    return ([self.statusId intValue] == LINE_ORDERSTATUS_RETURN);
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

- (NSDecimalNumber *) calcDiscountFromPrimarySellingPrice:(NSDecimalNumber *) newSellingPrice {
    NSDecimalNumber *actualTotal = [self calcLineSubTotal];
    NSDecimalNumber *discountedTotal = [newSellingPrice decimalNumberByMultiplyingBy:quantityPrimary];
    
    return [actualTotal decimalNumberBySubtracting:discountedTotal];
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

- (void) markAsModified {
    // Mark as modified
    if (!isNew && !isModified) {
        isModified = YES;
    }
}

@end
