//
//  iPOSServiceMock.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSServiceMock.h"


@implementation iPOSServiceMock

#pragma mark Constructor/Deconstructor
-(id) init {
    return [super init];
}
-(void) dealloc {
    [super dealloc];
}

-(SessionInfo *) login:(NSString *)employeeNumber withPassword:(NSString *)password {
    SessionInfo *session = [[[SessionInfo alloc] init] autorelease];
    
    session.employeeId = [NSNumber numberWithInt:123];
    session.storeId = [NSNumber numberWithInt: 1200];
    session.serverSessionId = @"1234-test-34";
    
    return session;
}

-(BOOL) logout:(SessionInfo *)sessionInfo {
    return YES;
}

- (BOOL) verifySession:(SessionInfo *)sessionInfo {
    return YES;
}

@end
