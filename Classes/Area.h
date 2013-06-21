//
//  Area.h
//  selSheet
//
//  Created by Joshua Walker on 2/10/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "AbstractModel.h"

@interface Area : AbstractModel


@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *note;

@property (nonatomic, retain) NSMutableArray *items;

@end
