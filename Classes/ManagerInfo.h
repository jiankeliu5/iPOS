//
//  ManagerApprovalInfo.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ManagerInfo : NSObject {
    NSString *managerUserName;
    NSString *managerPassword;
}

@property (nonatomic, retain) NSString *managerUserName;
@property (nonatomic, retain) NSString *managerPassword;

@end
