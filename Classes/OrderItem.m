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

// Private interface
@interface OrderItem()
    - (NSDecimalNumber *) convertQuantity: (NSDecimalNumber *) quantity;
@end

@implementation OrderItem

@synthesize lineNumber, statusId, sellingPrice, quantity, managerApprover, item, shouldDelete, shouldClose;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

-(id) initWithItem:(ProductItem *) productItem AndQuantity:(NSDecimalNumber *) productQuantity {
    self = [self init];
    
    if (self == nil) {
        return nil;
    }
    
    // Default the status to open
    statusId = [[NSNumber numberWithInt:STATUS_OPEN] retain];
    
    item = [productItem retain];
    quantity = [[self convertQuantity:productQuantity] retain];
    return self;
}

-(void) dealloc {
    [lineNumber release];
    [statusId release];
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
	}
}

- (void) setQuantity:(NSDecimalNumber *) newQuantity {
    if (quantity != newQuantity) {
		[quantity release];
		quantity = [[self convertQuantity:newQuantity] retain];
	}
}

#pragma mark -
#pragma mark Method implementations
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
        NSDecimalNumber *piecesNeeded = [[quantity decimalNumberByDividingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundUp];
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

- (BOOL) isClosed {
    return [self.statusId isEqualToNumber: [NSNumber numberWithInt:STATUS_CLOSE]];
}

#pragma mark -
#pragma mark Private Methods
-(NSDecimalNumber *) convertQuantity: (NSDecimalNumber *) quantityToConvert {
    BOOL isConversionNeeded = NO;
    
    if (item && 
        item.conversion && 
        item.piecesPerBox && 
        [item.conversion compare: [NSDecimalNumber decimalNumberWithString:@"1.0"]] != NSOrderedSame) {
        isConversionNeeded = YES;
    }
    
    if (!isConversionNeeded) {
        return quantityToConvert;
    }
    
    // Get the number of pieces needed
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                       raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                       raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *roundPlainTo2Places = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 
                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
        
    NSDecimalNumber *piecesPerBox = [NSDecimalNumber decimalNumberWithDecimal:[item.piecesPerBox decimalValue]];                                                                                                                                                                  
    NSDecimalNumber *piecesNeeded = [[quantityToConvert decimalNumberByDividingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundUp];
    NSDecimalNumber *boxesNeeded = [[piecesNeeded decimalNumberByDividingBy:piecesPerBox] decimalNumberByRoundingAccordingToBehavior:roundUp];
    
    return [[[boxesNeeded decimalNumberByMultiplyingBy:piecesPerBox] decimalNumberByMultiplyingBy:item.conversion] decimalNumberByRoundingAccordingToBehavior:roundPlainTo2Places];
}

@end
