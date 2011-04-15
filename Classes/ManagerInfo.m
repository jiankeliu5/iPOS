//
//  ManagerApprovalInfo.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ManagerInfo.h"


@implementation ManagerInfo

@synthesize managerUserName, managerPassword;

#pragma mark -
#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    return self;
}

- (void) dealloc {
    [managerUserName release];
    [managerPassword release];
    
    [super dealloc];
}
@end
