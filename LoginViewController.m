//
//  LoginViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/1/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "LoginViewController.h"
#import "PlaceHolderView.h"
#import "DrawUtils.h"
#import "LayoutUtils.h"

#pragma mark -
#pragma mark Private Interface
@interface LoginViewController ()
@end

#pragma mark -
@implementation LoginViewController

@synthesize iPosLogo;
@synthesize tileShopLogo;

@synthesize loginEntryView;
@synthesize empIdField;
@synthesize passwordField;

@synthesize containerView;

@synthesize empId;
@synthesize password;
@synthesize storeId;

#pragma mark Constructors
- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"iPOS"];
	
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	self.empIdField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
	empIdField.borderStyle = UITextBorderStyleRoundedRect;
	empIdField.returnKeyType = UIReturnKeyDone;
	empIdField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	empIdField.delegate = self;
	
	self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
	passwordField.borderStyle = UITextBorderStyleRoundedRect;
	passwordField.returnKeyType = UIReturnKeyDone;
	passwordField.secureTextEntry = YES;
	passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	passwordField.delegate = self;
	
    return self;
}

- (void) dealloc
{
	[self setEmpIdField:nil];
	[self setPasswordField:nil];
	[self setLoginEntryView:nil];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Methods

#pragma mark UIViewController overrides
- (void) loadView
{
	UIView *localContainerView  = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
	self.containerView = localContainerView;
	[localContainerView release];
	
	containerView.backgroundColor = [UIColor blackColor];
	
	self.view = containerView;
	
	// Put iPos logo on the screen
	
	// Login entry
	CGRect loginFrame = [LayoutUtils rectPercent:[containerView frame] startX:0.0f startY:60.0f percentWidth:100.0f percentHeight:25.0f];
	
	self.loginEntryView = [[UITableView alloc] initWithFrame:loginFrame style:UITableViewStyleGrouped];
	loginEntryView.delegate = self;
	loginEntryView.dataSource = self;
	loginEntryView.backgroundColor = [UIColor clearColor];
	
	[containerView addSubview:loginEntryView];
	
	// Put TileShop logo on the screen
	
}

- (void) viewDidLoad
{
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:YES];
	}
}

- (void) viewDidUnload
{
	
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// This would keep the interface locked to portrait
	// return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	NSLog(@"called did rotate");
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	// Need to have the inputs, so not navigating based on row touches here.
}

#pragma mark UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *LoginTableIdentifier = @"LoginTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoginTableIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:LoginTableIdentifier] autorelease];
	}
	
	NSInteger row = indexPath.row;
	CGRect tableFrame = tableView.frame;
	CGRect textFieldFrame = CGRectMake(0.0f, 0.0f, floorf(tableFrame.size.width / 2.0f), 30.0f);
	
	switch (row) {
		case 0:
			cell.textLabel.text = @"Employee Id";
			[self empIdField].frame = textFieldFrame;
			cell.accessoryView = [self empIdField];
			break;
		case 1:
			cell.textLabel.text = @"Password";
			[self passwordField].frame = textFieldFrame;
			cell.accessoryView = [self passwordField];
			break;
		default:
			break;
	}
	return cell;
}

@end
