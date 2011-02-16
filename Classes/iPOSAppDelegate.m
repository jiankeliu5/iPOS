//
//  iPOSAppDelegate.m
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import "iPOSAppDelegate.h"

#pragma mark -
@implementation iPOSAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize loginViewController;
@synthesize scannerReaderDelegate;

#pragma mark Constructors
- (void) applicationDidFinishLaunching:(UIApplication*)application 
{   
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
    
    // Create the barcode scanner/reader & Connect
    scannerReaderDelegate = [[BarcodeScannerCardReaderDelegate alloc] init];
    
    // Connecting to the device will happen upon successful login.  Successful logout (Navigating back to login page) will disconnect.
    loginViewController.scannerReaderDelegate = scannerReaderDelegate;
    scannerReaderDelegate.navigationController = navigationController;
}

- (void) applicationWillTerminate:(UIApplication*)application {
    [scannerReaderDelegate release];
	[navigationController release];
    [window release];
    
    [super dealloc];
}

@end
