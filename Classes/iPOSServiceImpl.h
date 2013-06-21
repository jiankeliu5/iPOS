//
//  POSServiceImpl.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSService.h"
#import "ASIHTTPRequest.h"

@interface iPOSServiceImpl : NSObject <iPOSService> {
    NSString *baseUrl;
    NSString *posSessionMgmtUri;
    NSString *posCustomerMgmtUri;
    NSString *posOrderMgmtUri;
    NSString *posReportMgmtUri;
}

struct orderLock
{
    NSNumber *orderID;
    NSNumber *salesPersonID;
    NSNumber *storeID;
    NSString *sysuserID;
    NSString *salesPersonName;
    NSDate *dateLogin;
};
typedef struct orderLock orderLock;

@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic,retain) NSString *ssbaseUrl;
@property(nonatomic, retain) NSString *posSessionMgmtUri;
@property(nonatomic, retain) NSString *posCustomerMgmtUri;
@property(nonatomic, retain) NSString *posOrderMgmtUri;
@property(nonatomic, retain) NSString *posReportMgmtUri;
@property(nonatomic, retain) NSString *selSheetMgmtUri;
@property(nonatomic, retain) NSString *selSheetLookupUri;
@property(nonatomic, retain) NSString *selSheetProjectUri;
@property(nonatomic, retain) NSString *selSheetReportUri;
@property(nonatomic, retain) NSString *posInventoryMgmtUri;

-(void) setToDemoMode;
-(void) setToReleaseMode;
- (ASIHTTPRequest *) startGetRequest: (NSString *) urlString withSession: (SessionInfo *) sessionInfo;

@end
