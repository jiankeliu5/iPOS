//
//  iPOSAppDelegate.h
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface iPOSAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow* window;
	UINavigationController* navigationController;
	LoginViewController* loginViewController;
}

@property (retain) UIWindow* window;
@property (retain) UINavigationController* navigationController;
@property (retain) LoginViewController* loginViewController;

@end

