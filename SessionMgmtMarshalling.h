//
//  SessionMgmtMarshalling.h
//  iPOS
//
//  Created by Torey Lomenda on 3/16/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionInfo.h"

@interface SessionMgmtMarshalling : NSObject {

}

+ (NSString *) toLoginRequestXmlWith: (NSString *) employeeNumber password: (NSString *) password deviceId: (NSString *) deviceId;
+ (void) bindSessionInfo:(SessionInfo *) sessionInfo fromXml:(NSString *) xmlLoginResult;
+ (BOOL) isSuccessful: (NSString *) xmlResponse;

@end
