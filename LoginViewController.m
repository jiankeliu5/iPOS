//
//  LoginViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/1/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "LoginViewController.h"
#import "DrawUtils.h"
#import "LayoutUtils.h"
#import "AlertUtils.h"
#import "MainMenuViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface LoginViewController () 
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end

#pragma mark -
@implementation LoginViewController

@synthesize empId;
@synthesize password;
@synthesize storeId;
@synthesize deviceId;

@synthesize currentFirstResponder;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	// If we come back here from another view, we are logging out.
	[[self navigationItem] setTitle:@"Logout"];
	
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];
	
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [linea disconnect];
	
	[self setCurrentFirstResponder:nil];
	[self setEmpId:nil];
	[self setPassword:nil];
	[self setStoreId:nil];
	[self setDeviceId:nil];
    
  	[super dealloc];
}

#pragma mark -
#pragma mark Accessors


#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Linea Delegate
-(void)connectionState:(int)state {
    switch (state) {
		case CONN_DISCONNECTED:	
            //[AlertUtils showModalAlertMessage: @"Linea-Pro Device is disconnected!!"];
            break;
        case CONN_CONNECTING:
            break; 
		case CONN_CONNECTED:
            //[AlertUtils showModalAlertMessage: @"Linea-Pro Device is connected!!"];
            break;
	}
    
}
#pragma mark UIViewController overrides
- (void)loadView
{
	UIView *bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self setView:bgView];
	[bgView release];
	
	UIImage *img = [UIImage imageNamed:@"iPosLogin"];
	UIImageView *iv = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	iv.contentMode = UIViewContentModeBottomLeft;
	iv.clipsToBounds = YES;
	iv.image = img;
	[self.view addSubview:iv];
	[iv release];
	
	loginTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	loginTableView.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:loginTableView];
	[loginTableView release];
}

- (void)viewDidLoad
{
	// Do this at the beginning
	[super viewDidLoad];
	
	loginTableView.dataSource = self;
	loginTableView.delegate = self;   
    
    // Get a reference to the shared Linea instance and add this controller as a delegate
    linea = [Linea sharedDevice];
    [linea addDelegate:self];
}

- (void)viewDidUnload
{	
	// Release any retained subviews of the main view
}

- (void)viewWillAppear:(BOOL)animated
{
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	// Make sure we logout and disconnect from Linea device
	[self setEmpId:nil];
	[self setPassword:nil];
    
    [facade logout]; 
    [linea disconnect];
    
	
	CGRect viewBounds = self.view.bounds;
	
	if (loginTableView) {
		[loginTableView reloadData];
		loginTableView.frame = viewBounds;
	}
	
	if (loginTableView.tableHeaderView == nil) {
		UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewBounds.size.width, floorf(viewBounds.size.height / 1.5f))];
		tableHeader.backgroundColor = [UIColor clearColor];
		[loginTableView setTableHeaderView: tableHeader];
		[tableHeader release];
	}
	
	// Do this at the end
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	// Do these at the beginning
	[loginTableView flashScrollIndicators];
	[super viewDidAppear:animated];
	
	NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
	[noteCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[noteCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	if ([self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
	
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	// Do this at the end
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// This will keep the interface locked to portrait
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	NSLog(@"called did rotate");
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.currentFirstResponder = textField;
	if ([loginTableView indexPathsForVisibleRows].count) {
		topRowBeforeKeyboardShown = (NSIndexPath *)[[loginTableView indexPathsForVisibleRows] objectAtIndex:0];
	} else {
		topRowBeforeKeyboardShown = [NSIndexPath indexPathForRow:0 inSection:0];
		[textField resignFirstResponder];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.currentFirstResponder = nil;

	// Want to set these here since if the user shifts fields
	// without dismissing the keyboard then textFieldShouldReturn
	// is not called.
	if (textField.tag == 0) {
		[self setEmpId:nil];
		[self setEmpId:textField.text];
	} else if (textField.tag == 1) {
		[self setPassword:nil];
		[self setPassword:textField.text];
	}
	
	if (self.empId != nil && self.password != nil) {
		UIAlertView *alert = [AlertUtils showProgressAlertMessage:@"Logging In"];
		if([facade login:self.empId password:self.password]) {
			[AlertUtils dismissAlertMessage: alert];
			
			MainMenuViewController *mainMenuViewController = [[MainMenuViewController alloc] init];
			[[self navigationController] pushViewController:mainMenuViewController animated:TRUE];
            [mainMenuViewController release];
			
			// This is where we would connect to the linea-pro device
            [linea connect];

		} else {
			[AlertUtils dismissAlertMessage:alert];
			[AlertUtils showModalAlertMessage:@"Login failure.  Please try again."];
		}
		
		[self setEmpId:nil];
		[self setPassword:nil];
		[loginTableView reloadData];
		
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

// These come from a StackOverflow answered question http://stackoverflow.com/questions/594181/uitableview-and-keyboard-scrolling-problem/672003#672003
// and are from the InAppSettingsKit open source project.
#pragma mark Keyboard Management
- (void)keyboardWillShow:(NSNotification*)notification {
	if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
		NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
		if (!keyboardFrameValue) {
			keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
		}
		
		// Reduce the tableView height by the part of the keyboard that actually covers the tableView
		CGRect windowRect = [[UIApplication sharedApplication] keyWindow].bounds;
		if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
			windowRect = [LayoutUtils swapRect:windowRect];
		}
		
		CGRect viewRectAbsolute = [loginTableView convertRect:loginTableView.bounds toView:[[UIApplication sharedApplication] keyWindow]];
		if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
			viewRectAbsolute = [LayoutUtils swapRect:viewRectAbsolute];
		}
		
		CGRect frame = loginTableView.frame;
		frame.size.height -= [keyboardFrameValue CGRectValue].size.height - CGRectGetMaxY(windowRect) + CGRectGetMaxY(viewRectAbsolute);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		loginTableView.frame = frame;
		[UIView commitAnimations];
		
		// Currently we just assign the UITextField to the accessoryView, at some point if we use a nested
		// view arrangement here then we would have to go up more levels to find the UITableViewCell.
		UITableViewCell *textFieldCell = (id)((UITextField *)self.currentFirstResponder).superview;
		
		NSIndexPath *textFieldIndexPath = [loginTableView indexPathForCell:textFieldCell];
		
		// iOS 3 sends hide and show notifications right after each other
		// when switching between textFields, so cancel -scrollToOldPosition requests
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
		[loginTableView scrollToRowAtIndexPath:textFieldIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}


- (void)scrollToOldPosition {
	[loginTableView scrollToRowAtIndexPath:topRowBeforeKeyboardShown atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
	if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		loginTableView.frame = self.view.bounds;
		[UIView commitAnimations];
		
		[self performSelector:@selector(scrollToOldPosition) withObject:nil afterDelay:0.1];
	}
}	

#pragma mark UITableViewDelegate
//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
//{
// Need to have the inputs, so not navigating based on row touches here.
//}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
	
	NSInteger row = indexPath.row;

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:LoginTableIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		
		UITextField *loginTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, floorf(tableView.frame.size.width / 2.0f), 21.0f)];
		loginTextField.adjustsFontSizeToFitWidth = YES;
		loginTextField.textColor = [UIColor blackColor];
		loginTextField.backgroundColor = [UIColor whiteColor];
		loginTextField.tag = row;
		loginTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		loginTextField.delegate = self;
		
		switch (row) {
			case 0:
				cell.textLabel.text = @"Employee Id";
				loginTextField.returnKeyType = UIReturnKeyDone;
				loginTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
				loginTextField.text = self.empId;
				break;
			case 1:
				cell.textLabel.text = @"Password";
				loginTextField.returnKeyType = UIReturnKeyDone;
				loginTextField.secureTextEntry = YES;
				loginTextField.text = self.password;
				break;
			default:
				break;
		}
		cell.accessoryView = loginTextField;
		[loginTextField release];
	}
	
	switch (row) {
		case 0:
			((UITextField *)cell.accessoryView).text = self.empId;
			break;
		case 1:
			((UITextField *)cell.accessoryView).text = self.password;
			break;
		default:
			break;
	}
	
	return cell;

}


@end
