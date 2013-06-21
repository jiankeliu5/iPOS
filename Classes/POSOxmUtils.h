//
//  POSXmlUtils.h
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CXMLElement.h"

#import "AbstractModel.h"
#import "Address.h"
#import "Store.h"

@interface POSOxmUtils : NSObject 

+ (void) attachErrors: (CXMLElement *) errorXmlElement toModel: (AbstractModel *) modelObj; 
+ (Address *) toAddress: (CXMLElement *) addressXmlElement;
+ (Store *) toStore: (CXMLElement *) parentXmlElement;
+ (NSArray *) toDistributionCenterList: (CXMLElement *) parentXmlElement forItem: (ProductItem *) item;

+ (NSString *) genXmlElementWithName: (NSString *) name value: (NSString *) value;
+ (NSString *) replaceInXmlTemplate: (NSString *) template parameter: (NSString *) parameter withValue: (NSString *) value; 

+ (BOOL) isXmlResultTrue: (NSString *) xmlString;
+ (NSDecimalNumber *) parseAsDecimal: (NSString *) xmlString;

@end
