//
//  iPOSAppDelegate.m
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import "iPOSAppDelegate.h"
#import "AlertUtils.h"
#import "UINavigationController+Rotation.h"

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

@synthesize window;
@synthesize navigationController;
@synthesize loginViewController;
@synthesize orderNavigationController;
@synthesize lookupOrderViewController;
@synthesize resignedActive;
@synthesize verifyPasswordTries;
@synthesize reachability;
@synthesize appUpdater;


#pragma mark Constructors
- (void) applicationDidFinishLaunching:(UIApplication*)application {   
    // Set the application setting defaults
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
	
	// Add the navigation controller view to the window
	//[window addSubview:[navigationController view]];
    [self.window setRootViewController:navigationController];
	
    [window makeKeyAndVisible];
    
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
    
    linea = [DTDevices sharedDevice];
    [linea connect];
    
	// If we had a live session and resigned as the active application
	// due to inactivity or being backgrounded, we need to have the user
	// input their password and re-validate the session.
    endTime = [[NSDate alloc] init];
    
    NSTimeInterval interval = [endTime timeIntervalSinceDate:startTime];
    [startTime release];
    
    if (!isnan(interval) && (interval >= TIMEOUT_VALUE))
    {
        
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
        
    }
	self.resignedActive = NO;
}


-(void)releaseTimer:(NSDate *)date {
    [date release];
}

- (void) applicationWillResignActive:(UIApplication *)application {
	// So we know to check our session when we come back.
    [endTime release];
    startTime = [[NSDate alloc] init];
	self.resignedActive = YES;
    
    linea = [DTDevices sharedDevice];
    [linea disconnect];
}

- (void) applicationWillTerminate:(UIApplication*)application {	
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
	if ([password length] == 0) {
		[AlertUtils showModalAlertMessage:@"Please input a password." withTitle:@"iPOS"];
		[aVerificationView makePasswordFieldFirstResponder];
	} else {
		SessionStatus sessionValid = [facade verifySession:password];
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
	}
}

- (void) cancelVerificationView:(SessionVerificationView *)aVerificationView {
	[aVerificationView removeFromSuperview];
	[navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
    if (reachabilityAlert != nil) {
        [reachabilityAlert dismissWithClickedButtonIndex:0 animated:NO];
        reachabilityAlert = nil;
    }
}

- (void) checkAppVersion:(id)sender {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    if (appUpdater == nil) {
        appUpdater = [[InAppUpdater alloc] initWithAppInstallUrl:[bundle objectForInfoDictionaryKey:@"ipos.app.update.url"]];
        
        appUpdater.username = [bundle objectForInfoDictionaryKey:@"ipos.app.update.user"];
        appUpdater.password = [bundle objectForInfoDictionaryKey:@"ipos.app.update.password"];
        appUpdater.delegate = self;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL demoEnabled = [defaults boolForKey:@"enableDemoMode"];
    
    // Only check for updates if we are not in demo mode.
    if (demoEnabled == NO) {
        [appUpdater checkForUpdate];
    }

}


@end
