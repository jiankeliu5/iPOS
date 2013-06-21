//
//  XmlMarshaller.h
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "CXMLElement+CustomExtensions.h"

@protocol XmlMarshaller

@required 
- (id) toObject:(NSString *) xmlString;
- (NSString *) toXml: (id) marshalObj;

@end
