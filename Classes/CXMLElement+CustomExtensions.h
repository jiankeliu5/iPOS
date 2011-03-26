//
//  CXMLElement+CustomExtensions.h
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CXMLElement.h"

@interface CXMLElement (CustomExtensions) 

- (CXMLElement *) firstElementNamed:(NSString *) elementName;
- (CXMLElement *) lastElementNamed:(NSString *) elementName;


- (NSString *) elementStringValue:(NSString *) elementName;
- (NSNumber *) elementNumberValue:(NSString *) elementName;
- (NSDecimalNumber *) elementDecimalValue:(NSString *) elementName;
- (BOOL) elementBoolValue:(NSString *) elementName;

@end
