//
//  iPOSAppDelegate.m
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import "iPOSAppDelegate.h"
#import "AlertUtils.h"
#import "CalendarController.h"
#import "LineaSDK.h"

#import "MainMenuViewController.h"

#import "ViewController.h"



#define MAX_PASSWORD_RETRIES 3
#define TIMEOUT_VALUE 300.0

@interface iPOSAppDelegate()

- (void)reachabilityChanged:(NSNotification*) note;

- (NSString *) reachabilityHost;
- (void) dismissAlert;

- (void) checkAppVersion: (id) sender;

@end

#pragma mark -
@implementation iPOSAppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize loginViewController;
@synthesize orderNavigationController;
@synthesize lookupOrderViewController;
@synthesize resignedActive;
@synthesize verifyPasswordTries;
@synthesize reachability;
@synthesize appUpdater;
@synthesize calendarController;
@synthesize viewController = _viewController;

#pragma mark Constructors
- (void) applicationDidFinishLaunching:(UIApplication*)application {
    // Set the application setting defaults
    //NSLog(@"AppDelegate 1");
    isNotReachableDetected = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"enableDemoMode"];
    
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
	self.resignedActive = NO;
	self.verifyPasswordTries = 0;
	facade = [iPOSFacade sharedInstance];
	
    // Create window
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// Create the login root view controller
	loginViewController = [[LoginViewController alloc] init];
	
	// Create navigation controller with login view controller as contents
	navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	[loginViewController release];
    
    lookupOrderViewController = [[LookupOrderViewController alloc] init];
    orderNavigationController = [[UINavigationController alloc] initWithRootViewController:lookupOrderViewController];
    orderNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    [lookupOrderViewController release];
    
    //create calendar
    calendarController = [[CalendarController alloc] initWithNibName:nil bundle:nil];
	
	// Add the navigation controller view to the window
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
    
    //Enning Tang 9/28/2012
    [window setRootViewController:navigationController];
    
    // Register for reachability (Detect changes to network
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification object:nil];
    
    self.reachability = [Reachability reachabilityWithHostName:[self reachabilityHost]];
	[reachability startNotifier];
    
    // Check for new app version
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkAppVersion:) userInfo:nil repeats: NO];   
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
	// If we had a live session and resigned as the active application
	// due to inactivity or being backgrounded, we need to have the user
	// input their password and re-validate the session.
    //NSLog(@"AppDelegate 2");
    
    Linea *linea = [Linea sharedDevice];
    
    endTime = [[NSDate alloc] init];
    NSLog(@"1");
    
    NSTimeInterval interval = [endTime timeIntervalSinceDate:startTime];
    NSLog(@"2");
    //Enning Tang try switching out to other apps 11/14/2012
    @try {
        [startTime release];
        NSLog(@"3");
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: %@", exception.description);
        NSLog(@"4");
    }
    
    if (!isnan(interval) && (interval >= TIMEOUT_VALUE))
    {
        NSLog(@"5");
        if (self.resignedActive == YES && facade.sessionInfo != nil) {
            NSLog(@"6");
            verificationView = [[[SessionVerificationView alloc] initWithFrame:window.bounds] autorelease];
            NSLog(@"7");
            verificationView.delegate = self;
            NSLog(@"8");
            [window addSubview:verificationView];
            NSLog(@"9");
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            NSLog(@"10");
            
            CGFloat angle = 0.0;
            NSLog(@"11");
            CGRect newFrame = verificationView.window.bounds;
            NSLog(@"12");
            CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
            NSLog(@"12");
            
            switch (orientation) {
                case UIInterfaceOrientationPortraitUpsideDown:
                    NSLog(@"13");
                    angle = M_PI;
                    NSLog(@"14");
                    newFrame.size.height -= statusBarSize.height;
                    NSLog(@"15");
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    NSLog(@"16");
                    angle = - M_PI / 2.0f;
                    NSLog(@"17");
                    newFrame.origin.x += statusBarSize.width;
                    NSLog(@"18");
                    newFrame.size.width -= statusBarSize.width;
                    NSLog(@"19");
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    NSLog(@"20");
                    angle = M_PI / 2.0f;
                    NSLog(@"21");
                    newFrame.size.width -= statusBarSize.width;
                    NSLog(@"22");
                    break;
                default: // as UIInterfaceOrientationPortrait
                    NSLog(@"23");
                    angle = 0.0;
                    NSLog(@"24");
                    newFrame.origin.y += statusBarSize.height;
                    NSLog(@"25");
                    newFrame.size.height -= statusBarSize.height;
                    NSLog(@"26");
                    break;
            } 
            
            NSLog(@"27");
            verificationView.transform = CGAffineTransformMakeRotation(angle);
            NSLog(@"28");
            verificationView.frame = newFrame;
            NSLog(@"29");
            [verificationView makePasswordFieldFirstResponder];
            NSLog(@"30");
        }
        
    }
    NSLog(@"31");
	//self.resignedActive = NO;
    NSLog(@"32");
    [linea connect];
    
}


-(void)releaseTimer:(NSDate *)date {
    //NSLog(@"AppDelegate 3");
    [date release];
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Come in....");
}

- (void) applicationWillResignActive:(UIApplication *)application {
	// So we know to check our session when we come back.
    //NSLog(@"AppDelegate 4");
    
    Linea *linea = [Linea sharedDevice];
    
    orderCart = [OrderCart sharedInstance];
    Order *order = [orderCart getOrder];
    
    NSLog(@"Object 0: %d", [[order getOrderItems] count]);
    
    //[application should]
    
    //NSString *ItemCount = [NSNumber numberWithInteger:[order getOrderItems] count];
    
    /*
    if ([[order getOrderItems] count] > 0)
    {
        UIAlertView *saveOrderNotify = [[UIAlertView alloc] init];
        saveOrderNotify.title = @"Message";
        saveOrderNotify.message = @"Please save your order before switching out from iPOS.";
        [saveOrderNotify addButtonWithTitle:@"OK"];
        [saveOrderNotify show];
        [saveOrderNotify release];
    }*/
    
    [endTime release];
    startTime = [[NSDate alloc] init];
	self.resignedActive = YES;
    
    [linea disconnect];
}

- (void) applicationWillTerminate:(UIApplication*)application {
    //NSLog(@"AppDelegate 5");
	[navigationController release];
    [orderNavigationController release];
    [endTime release];
    //[startTime release];
    [window release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachability release];
    reachability = nil;
    
    appUpdater.delegate = nil;
    [appUpdater release];
    appUpdater = nil;
    
    [super dealloc];
}

- (void) verificationView:(SessionVerificationView *)aVerificationView submitPassword:(NSString *)password {
    //NSLog(@"AppDelegate 6");
	if ([password length] == 0) {
		[AlertUtils showModalAlertMessage:@"Please input a password." withTitle:@"iPOS"];
		[aVerificationView makePasswordFieldFirstResponder];
	} else {
		SessionStatus sessionValid = [facade verifySession:password];
        SessionStatus sssessionValid = [facade ssverifySession:password];
		switch (sessionValid) {
			case SessionOk:
				[aVerificationView removeFromSuperview];
				self.verifyPasswordTries = 0;
				break;
			case SessionBadPassword:
				self.verifyPasswordTries++;
				if (self.verifyPasswordTries >= MAX_PASSWORD_RETRIES) {
					[AlertUtils showModalAlertMessage:@"Password retry limit exceeded.  Logging out." withTitle:@"iPOS"];
					self.verifyPasswordTries = 0;
					[aVerificationView removeFromSuperview];
					[navigationController popToRootViewControllerAnimated:YES];
				} else {
					[AlertUtils showModalAlertMessage:@"Invalid Password.  Please try again." withTitle:@"iPOS"];
					[aVerificationView makePasswordFieldFirstResponder];
				}
				break;
			case SessionExpired:
				[AlertUtils showModalAlertMessage:@"Session expired, please login again." withTitle:@"iPOS"];
				self.verifyPasswordTries = 0;
				[aVerificationView removeFromSuperview];
				[navigationController popToRootViewControllerAnimated:YES];
				break;
			default:
				break;
		}
        switch (sssessionValid) {
			case SessionOk:
				[aVerificationView removeFromSuperview];
				self.verifyPasswordTries = 0;
				break;
			case SessionBadPassword:
				self.verifyPasswordTries++;
				if (self.verifyPasswordTries >= MAX_PASSWORD_RETRIES) {
					[AlertUtils showModalAlertMessage:@"Password retry limit exceeded.  Logging out." withTitle:@"iPOS"];
					self.verifyPasswordTries = 0;
					[aVerificationView removeFromSuperview];
					[navigationController popToRootViewControllerAnimated:YES];
				} else {
					[AlertUtils showModalAlertMessage:@"Invalid Password.  Please try again." withTitle:@"iPOS"];
					[aVerificationView makePasswordFieldFirstResponder];
				}
				break;
			case SessionExpired:
				[AlertUtils showModalAlertMessage:@"Session expired, please login again." withTitle:@"iPOS"];
				self.verifyPasswordTries = 0;
				[aVerificationView removeFromSuperview];
				[navigationController popToRootViewControllerAnimated:YES];
				break;
			default:
				break;
		}
	}
}

- (void) cancelVerificationView:(SessionVerificationView *)aVerificationView {
    //NSLog(@"AppDelegate 7");
	[aVerificationView removeFromSuperview];
	[navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"AppDelegate 8");
    if (reachabilityAlert) {
        reachabilityAlert = nil;
    }
    
    if ([alertView.title isEqualToString:@"Update Available"]) {
		// Check by titles rather than index since documentation suggests that different 
		// devices can set the indexes differently.
		NSString *clickedButtonTitle = [alertView buttonTitleAtIndex:buttonIndex];
		if ([clickedButtonTitle isEqualToString:@"Yes"]) {
			[appUpdater initiateAppDownload];
		}
	}
}

#pragma mark -
#pragma mark InAppUpdaterDelegate Methods
- (void) appUpdateStatus:(AppUpdateStatusType)updateStatus {
    //NSLog(@"AppDelegate 9");
    if (updateStatus == APP_UPDATE_AVAILABLE) {
        UIAlertView *questionnaireAlert = [[UIAlertView alloc] init];
        questionnaireAlert.title = @"Update Available";
        questionnaireAlert.message = @"Would you like to install the update to iPOS?";
        questionnaireAlert.delegate = self;
        [questionnaireAlert addButtonWithTitle:@"Yes"];
        [questionnaireAlert addButtonWithTitle:@"Later"];
        [questionnaireAlert show];
        [questionnaireAlert release];
    }
}

- (void) appUpdateIsInitiated:(BOOL)isInitiated {
    
}

#pragma mark -
#pragma mark Private Methods
- (void) reachabilityChanged:(NSNotification *) note {
    //NSLog(@"AppDelegate 10");
    Reachability* r = [note object];
	NetworkStatus ns = r.currentReachabilityStatus;
    
    if (ns == NotReachable && isNotReachableDetected == NO) {
        [self dismissAlert];
        
        isNotReachableDetected = YES;
        reachabilityAlert = [[UIAlertView alloc] init];
        reachabilityAlert.title = @"Lost Connection";
        reachabilityAlert.message = @"Unable to access to network.  You may have lost your WIFI connection.  Please verify and try again.";
        reachabilityAlert.delegate = self;
        [reachabilityAlert show];
        [reachabilityAlert release];
        
        [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:2];
        
    } else if (ns == ReachableViaWiFi && isNotReachableDetected) {
        [self dismissAlert];
        isNotReachableDetected = NO;
        reachabilityAlert = [[UIAlertView alloc] init];
        reachabilityAlert.title = @"Connected";
        reachabilityAlert.message = @"You are re-connected to the network via WIFI.";
        reachabilityAlert.delegate = self;
        [reachabilityAlert show];
        [reachabilityAlert release];
        [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:2];
    }
}

- (NSString *) reachabilityHost {
    //NSLog(@"AppDelegate 11");
    // Get user preference for demo mode
    NSString *hostName = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL demoEnabled = [defaults boolForKey:@"enableDemoMode"];
    
    if (demoEnabled) {
        hostName = [bundle objectForInfoDictionaryKey:@"ipos.service.demo.host"];
    } else {
        hostName = [bundle objectForInfoDictionaryKey:@"ipos.service.host"];
    }
    
    return hostName;
}

- (void) dismissAlert {
    //NSLog(@"AppDelegate 12");
    if (reachabilityAlert != nil) {
        [reachabilityAlert dismissWithClickedButtonIndex:0 animated:NO];
        reachabilityAlert = nil;
    }
}

- (void) checkAppVersion:(id)sender {
    //NSLog(@"AppDelegate 13");
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    if (appUpdater == nil) {
        appUpdater = [[InAppUpdater alloc] initWithAppInstallUrl:[bundle objectForInfoDictionaryKey:@"ipos.app.update.url"]];
        
        appUpdater.username = [bundle objectForInfoDictionaryKey:@"ipos.app.update.user"];
        appUpdater.password = [bundle objectForInfoDictionaryKey:@"ipos.app.update.password"];
        appUpdater.delegate = self;
    }
    
    [appUpdater checkForUpdate];

}

//Enning Tang implement Preserve & Restore 11/20/2012
/*
-(BOOL) application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL) application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}
*/

@end
