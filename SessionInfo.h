//
//  SessionInfo.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SessionInfo : NSObject {
    NSString *deviceId;
}

@property (nonatomic, retain) NSString *deviceId;

@end
