//
//  iPOSAppDelegate.h
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "iPOSFacade.h"
#import "SessionVerificationView.h"

@interface iPOSAppDelegate : NSObject <UIApplicationDelegate, SessionVerificationViewDelegate> 
{
    UIWindow* window;
	UINavigationController* navigationController;
	LoginViewController* loginViewController;
	BOOL resignedActive;
	iPOSFacade *facade;
	SessionVerificationView *verificationView;
    NSDate *startTime;
    NSDate *endTime;
	NSInteger verifyPasswordTries;
}

@property (retain) UIWindow* window;
@property (retain) UINavigationController* navigationController;
@property (retain) LoginViewController* loginViewController;
@property (nonatomic, assign) BOOL resignedActive;
@property (nonatomic, assign) NSInteger verifyPasswordTries;
@end

