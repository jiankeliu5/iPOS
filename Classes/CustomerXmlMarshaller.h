//
//  CustomerXmlMarshaller.h
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlMarshaller.h"

@interface CustomerXmlMarshaller : NSObject <XmlMarshaller> {

}

- (id) toObjectFromXmlElement: (CXMLElement *) root;

@end
