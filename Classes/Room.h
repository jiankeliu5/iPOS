//
//  Room.h
//  selSheet
//
//  Created by Joshua Walker on 2/8/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "AbstractModel.h"

@interface Room : AbstractModel


@property (nonatomic, retain) NSNumber *roomId;

@property (nonatomic, retain) NSString *description;

@property (nonatomic, retain) NSMutableArray *areas;

#pragma mark Marshalling methods
+ (NSArray *) listFromXml: (NSString *) xmlString;
@end
