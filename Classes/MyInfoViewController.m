//
//  MyInfoViewController.m
//  iPOS
//
//  Created by Enning Tang on 5/9/13.
//
//

#import "MyInfoViewController.h"
#import "AlertUtils.h"

#import "UIScreen+Helpers.h"
#include "iPOSAppDelegate.h"

#import "iPOSFacade.h"
#import "OrderCart.h"
#import "Order.h"

@interface MyInfoViewController ()

@end

@implementation MyInfoViewController

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"My Info"];
	[self setTitle:@"My Info"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
	
    return self;
}

- (void)loadView {
    
    NSLog(@"MyInfo loadView called");
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
	bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:bgView];
	[bgView release];
    
    salesPersonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	salesPersonLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	salesPersonLabel.textColor = [UIColor blackColor];
	salesPersonLabel.text = [NSString stringWithFormat:@"SalesPersonId: %@", [facade sessionInfo].employeeId.stringValue];
	salesPersonLabel.textAlignment = NSTextAlignmentCenter;
    
	[self.view addSubview:salesPersonLabel];
	[salesPersonLabel release];
    
    storeIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	storeIdLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	storeIdLabel.textColor = [UIColor blackColor];
	storeIdLabel.textAlignment = NSTextAlignmentCenter;
    storeIdLabel.text = [NSString stringWithFormat:@"StoreId: %@", [facade sessionInfo].storeId.stringValue];
    
	[self.view addSubview:storeIdLabel];
	[storeIdLabel release];
    
    deviceIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	deviceIdLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	deviceIdLabel.textColor = [UIColor blackColor];
	deviceIdLabel.textAlignment = NSTextAlignmentCenter;
    
	[self.view addSubview:deviceIdLabel];
	[deviceIdLabel release];
    
}

- (void) layoutView:(UIInterfaceOrientation)interfaceOrientation {
    
    NSLog(@"MyInfo layoutView called");
    CGRect viewBounds = [UIScreen rectForScreenView:interfaceOrientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
    
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
    
    salesPersonLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 200.0f, 40.0f);
    salesPersonLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        labelButtonSpacing = labelButtonSpacing + 4.0;
    }
    
    storeIdLabel.frame = CGRectOffset(salesPersonLabel.frame, 0.0f, labelButtonSpacing);
    deviceIdLabel.frame = CGRectOffset(storeIdLabel.frame, 0.0f, labelButtonSpacing);
    
    // Change to work from lookupOrderField position when that is implemented
    
}

#pragma mark -
#pragma mark UIViewController overrides

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self layoutView:[[UIApplication sharedApplication] statusBarOrientation]];
	
	// Do this last
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	// Do this at the end
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark ExtUIViewController delegate
- (void)extTextFieldFinishedEditing:(ExtUITextField *)textField {
    // Do nothing
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
	if (self.navigationController != nil)
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


@end
