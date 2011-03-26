//
//  CXMLElement+CustomExtensions.m
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CXMLElement+CustomExtensions.h"


@implementation CXMLElement (CustomExtensions)

#pragma mark -
#pragma mark Parsing Utilities
- (CXMLElement *) firstElementNamed:(NSString *)elementName {
    NSArray *nodes = [self elementsForName:elementName];
    
    if ([nodes count] == 0) {
        return nil;
    }
    
    return [nodes objectAtIndex:0];
}

- (CXMLElement *) lastElementNamed: (NSString *)elementName {
    NSArray *nodes = [self elementsForName:elementName];
  
    if ([nodes count] == 0) {
        return nil;
    }
    
    return [nodes lastObject];
}

#pragma mark -
#pragma mark Element Get Value Methods
- (NSString *) elementStringValue:(NSString *)elementName {
    NSArray *nodes = [self elementsForName:elementName];
    CXMLElement *element = [nodes lastObject];
    
    if (element) {
        return [element stringValue];
    }
    
    return nil;
}

- (BOOL) elementBoolValue:(NSString *)elementName {
    NSArray *nodes = [self elementsForName:elementName];
    CXMLElement *element = [nodes lastObject];
    
    if (element) {
        return [[element stringValue] isEqualToString: @"true"];
    }
    
    return NO;
}

- (NSNumber *) elementNumberValue:(NSString *)elementName {
    NSArray *nodes = [self elementsForName:elementName];
    CXMLElement *element = [nodes lastObject];
    
    if (element) {
        return [NSNumber numberWithInt:[[element stringValue] intValue]];
    }
    
    return nil;
}

- (NSDecimalNumber *) elementDecimalValue:(NSString *)elementName {
    NSArray *nodes = [self elementsForName:elementName];
    CXMLElement *element = [nodes lastObject];
    
    if (element) {
        return  [NSDecimalNumber decimalNumberWithString:[element stringValue]];
    }
    
    return nil;
}

@end
