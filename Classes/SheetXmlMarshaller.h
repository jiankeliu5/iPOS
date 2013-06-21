//
//  RoomXmlMarshaller.h
//  selSheet
//
//  Created by Joshua Walker on 2/16/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "XmlMarshaller.h"

@interface SheetXmlMarshaller : NSObject <XmlMarshaller>

-(NSArray *) toObjectList:(NSString *)xmlString;
-(NSString*)getDynamicUUID;
@end
