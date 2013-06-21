//
//  Room.m
//  selSheet
//
//  Created by Joshua Walker on 2/8/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "Room.h"

@implementation Room

@synthesize roomId, description, areas;

- (id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.areas = [[NSMutableArray alloc] init];
    
    return self;
}

/*#pragma mark -
 #pragma mark Room XML Marshalling
 + (NSArray *) listFromXml:(NSString *)xmlString {
 RoomXmlMarshaller *marshaller = [[[RoomXmlMarshaller alloc] init] autorelease];
 return (NSArray *) [marshaller toObject:xmlString];    
 }
 */

@end
