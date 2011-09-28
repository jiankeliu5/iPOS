//
//  OrderSummaryXmlMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderSummaryXmlMarshaller.h"
#import "OrderSummary.h"

@implementation OrderSummaryXmlMarshaller

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) toObject:(NSString *)xmlString {
    
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];
    OrderSummary *summary = nil;
    
     for (CXMLElement *node in [root elementsForName:@"OrderList"]) {
         
         summary = [[OrderSummary alloc] init];
         
         summary.orderDate = [node elementStringValue:@"ItemDescription"];
         summary.orderId = [node elementNumberValue:@"ItemDescription"];
         summary.orderTotal =[node elementDecimalValue:@"ItemDescription"];
         summary.orderType = [node elementStringValue:@"ItemDescription"];
         
         [itemList addObject:summary];
         
         [summary release];
         summary = nil;
     }
    
    return [NSArray arrayWithArray: itemList];
    
}

- (NSString *) toXml: (id) marshalObj {
    return nil;
}

@end
