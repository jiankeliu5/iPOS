//
//  CheckoutXMLParser.m
//  iPOS
//
//  Created by Enning Tang on 8/2/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "CheckoutXMLParser.h"
#import "Items.h"
#import "GDataXMLNode.h"

@implementation CheckoutXMLParser{
    
}

-(CheckoutXMLParser *)loadXML:(NSString *)XMLString{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:XMLString options:0 error:nil];
    if (doc == nil){
        return nil;
    }
    NSLog(@"%@", doc.rootElement);
    [doc release];
    return nil;
}

@end
