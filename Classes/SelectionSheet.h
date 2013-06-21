//
//  OrderCart.h
//  iPOS
//
//  Created by Torey Lomenda on 4/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Customer.h"

@class iPOSFacade;

@interface SelectionSheet : NSObject {
    iPOSFacade *facade;
    
}

@property (nonatomic, retain) NSMutableArray *rooms;
@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) Customer *contractor;

@property (nonatomic, retain) NSString *projectName;
@property (nonatomic, retain) NSString *projectId;
@property (nonatomic, retain) NSString *projectUid;
@property (nonatomic, retain) NSNumber *salesPersonId;
@property (nonatomic, retain) NSNumber *storeId;


@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSDate *dateUpdated;

@property (nonatomic, assign) BOOL archived;
@property (nonatomic, assign) BOOL newSheet;

+ (SelectionSheet *) sharedInstance;
+ (void) switchSheets;

#pragma mark -
#pragma mark Accessors
- (void) clearSheet;
#pragma mark Marshalling methods
+ (NSArray *) listFromXml: (NSString *) xmlString;
+ (SelectionSheet *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;
#pragma mark -
#pragma mark SelectionSheet methods


- (BOOL) saveSheet;
//- (BOOL) saveSheetAndEmail;

@end
