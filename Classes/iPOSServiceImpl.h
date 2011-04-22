//
//  POSServiceImpl.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSService.h"

@interface iPOSServiceImpl : NSObject <iPOSService> {
    NSString *baseUrl;
    NSString *posSessionMgmtUri;
    NSString *posCustomerMgmtUri;
    NSString *posOrderMgmtUri;
    NSString *posReportMgmtUri;
}

@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic, retain) NSString *posSessionMgmtUri;
@property(nonatomic, retain) NSString *posCustomerMgmtUri;
@property(nonatomic, retain) NSString *posOrderMgmtUri;
@property(nonatomic, retain) NSString *posReportMgmtUri;

-(void) setToDemoMode;
-(void) setToReleaseMode;

@end
