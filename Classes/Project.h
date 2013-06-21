//
//  Project.h
//  iPOS
//
//  Created by Enning Tang on 8/1/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject{
    
}

@property (nonatomic, retain) NSString *ProjectUID;
@property (nonatomic, retain) NSString *ProjectName;
@property (nonatomic, retain) NSDate *DateCreated;
@property (nonatomic, retain) NSDate *DateUpdated;
@property (nonatomic, retain) NSNumber *StoreID;
@property (nonatomic, retain) NSNumber *SalesPersonID;
@property (nonatomic, retain) NSMutableArray *Contract;
@property (assign) BOOL *Archived;
@property (nonatomic, retain) NSString *ProjectID;
@property (nonatomic, retain) NSMutableArray *Rooms;
@property (nonatomic, retain) NSMutableArray *SessionLogs;

@end
