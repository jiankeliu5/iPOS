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
#import "LookupOrderViewController.h"

#import "Reachability.h"
#import "InAppUpdater.h"
#import "CalendarController.h"
#import "OrderCart.h"
//#import "NSCondition+NSCondition_dealloc.h"

@interface iPOSAppDelegate : NSObject <UIApplicationDelegate, SessionVerificationViewDelegate, UIAlertViewDelegate, InAppUpdaterDelegate>
{
    UIWindow* window;
	UINavigationController* navigationController;
	LoginViewController* loginViewController;
    UINavigationController *orderNavigationController;
    LookupOrderViewController *lookupOrderViewController;
	BOOL resignedActive;
	iPOSFacade *facade;
    
	SessionVerificationView *verificationView;
    NSDate *startTime;
    NSDate *endTime;
	NSInteger verifyPasswordTries;
    
    BOOL isNotReachableDetected;
    Reachability *reachability;
    UIAlertView *reachabilityAlert;
    
    InAppUpdater *appUpdater;
	CalendarController *calendarController;
    
    OrderCart *orderCart;
    
}

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) UINavigationController* navigationController;
@property (nonatomic, retain) LoginViewController* loginViewController;
@property (nonatomic, retain) UINavigationController *orderNavigationController;
@property (nonatomic, retain) LookupOrderViewController *lookupOrderViewController;
@property (nonatomic, assign) BOOL resignedActive;
@property (nonatomic, assign) NSInteger verifyPasswordTries;

@property (nonatomic, retain) Reachability *reachability;
@property (nonatomic, retain) InAppUpdater *appUpdater;
@property (nonatomic, retain) CalendarController *calendarController;

@property (strong, nonatomic) UIViewController *viewController;

@end


