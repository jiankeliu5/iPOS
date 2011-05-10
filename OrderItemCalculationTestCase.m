//
//  OrderItemCalculationTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 4/12/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "OrderItem.h"

@interface OrderItemCalculationTestCase : SenTestCase 

-(void) testQuantityNeedsConversion;
-(void) testQuantityNoConversion;

@end

@implementation OrderItemCalculationTestCase

-(void) testQuantityNeedsConversion {
    OrderItem *orderItem = nil;
    ProductItem *item = [[[ProductItem alloc] init] autorelease];
    
    item.defaultToBox = YES;
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"2.2579095"];
    item.piecesPerBox = [NSNumber numberWithInt:6];
    item.primaryUnitOfMeasure = @"CV";
    item.secondaryUnitOfMeasure = @"EA";
    
    orderItem = [[[OrderItem alloc] initWithItem:item AndQuantity:[NSDecimalNumber decimalNumberWithString:@"200"]] autorelease];
    
    NSString *quantityAsStr = [NSString stringWithFormat:@"Expected to be equal to:  %@", orderItem.quantity];
    STAssertTrue ([orderItem.quantity compare:[NSDecimalNumber decimalNumberWithString:@"203.211855"]] == NSOrderedSame, quantityAsStr);
}

- (void) testQuantityNoConversion {
    OrderItem *orderItem = nil;
    ProductItem *item = [[[ProductItem alloc] init] autorelease];
    
    item.conversion = [NSDecimalNumber decimalNumberWithString:@"1.0000000"];
    item.piecesPerBox = [NSNumber numberWithInt:6];
    item.primaryUnitOfMeasure = @"CV";
    item.secondaryUnitOfMeasure = @"EA";
    
    orderItem = [[[OrderItem alloc] initWithItem:item AndQuantity:[NSDecimalNumber decimalNumberWithString:@"200"]] autorelease];
    
    NSString *quantityAsStr = [NSString stringWithFormat:@"Expected to be equal to:  %@", orderItem.quantity];
    STAssertTrue ([orderItem.quantity compare:[NSDecimalNumber decimalNumberWithString:@"200"]] == NSOrderedSame, quantityAsStr);
    
}

@end
