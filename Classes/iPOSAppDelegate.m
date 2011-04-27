//
//  iPOSAppDelegate.m
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import "iPOSAppDelegate.h"
#import "AlertUtils.h"

#pragma mark -
@implementation iPOSAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize loginViewController;
@synthesize resignedActive;

#pragma mark Constructors
- (void) applicationDidFinishLaunching:(UIApplication*)application 
{   
    // Set the application setting defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"enableDemoMode"];
    
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
	self.resignedActive = NO;
	facade = [iPOSFacade sharedInstance];
	
    // Create window
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// Create the login root view controller
	loginViewController = [[LoginViewController alloc] init];
	
	// Create navigation controller with login view controller as contents
	navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	[loginViewController release];
	
	// Add the navigation controller view to the window
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
   }

- (void) applicationDidBecomeActive:(UIApplication *)application {
	// If we had a live session and resigned as the active application
	// due to inactivity or being backgrounded, we need to have the user
	// input their password and re-validate the session.
	if (self.resignedActive == YES && facade.sessionInfo != nil) {
		verificationView = [[[SessionVerificationView alloc] initWithFrame:window.bounds] autorelease];
		verificationView.delegate = self;
		[window addSubview:verificationView];
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		
		CGFloat angle = 0.0;
		CGRect newFrame = verificationView.window.bounds;
		CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
		
		switch (orientation) { 
			case UIInterfaceOrientationPortraitUpsideDown:
				angle = M_PI; 
				newFrame.size.height -= statusBarSize.height;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				angle = - M_PI / 2.0f;
				newFrame.origin.x += statusBarSize.width;
				newFrame.size.width -= statusBarSize.width; 
				break;
			case UIInterfaceOrientationLandscapeRight:
				angle = M_PI / 2.0f;
				newFrame.size.width -= statusBarSize.width;
				break;
			default: // as UIInterfaceOrientationPortrait
				angle = 0.0;
				newFrame.origin.y += statusBarSize.height;
				newFrame.size.height -= statusBarSize.height;
				break;
		} 
		
		verificationView.transform = CGAffineTransformMakeRotation(angle);
		verificationView.frame = newFrame;
		[verificationView makePasswordFieldFirstResponder];
	}
	self.resignedActive = NO;
}

- (void) applicationWillResignActive:(UIApplication *)application {
	// So we know to check our session when we come back.
	self.resignedActive = YES;
}

- (void) applicationWillTerminate:(UIApplication*)application {	
	[navigationController release];
    [window release];
    [super dealloc];
}

- (void) verificationView:(SessionVerificationView *)aVerificationView submitPassword:(NSString *)password {
	if ([password length] == 0) {
		[AlertUtils showModalAlertMessage:@"Please input a password."];
	} else {
		BOOL sessionValid = [facade verifySession:password];
		if (sessionValid) {
			[aVerificationView removeFromSuperview];
		} else {
			[AlertUtils showModalAlertMessage:@"Session expired, please login again."];
			[aVerificationView removeFromSuperview];
			[navigationController popToRootViewControllerAnimated:YES];
		}
	}
}

- (void) cancelVerificationView:(SessionVerificationView *)aVerificationView {
	[aVerificationView removeFromSuperview];
	[navigationController popToRootViewControllerAnimated:YES];
}

@end
