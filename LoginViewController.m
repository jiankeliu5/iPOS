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
#import "PlaceholderView.h"

#pragma mark -
#pragma mark Private Interface
@interface LoginViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end

#pragma mark -
@implementation LoginViewController

@synthesize empId;
@synthesize password;
@synthesize storeId;
@synthesize deviceId;

@synthesize loginTableView;
@synthesize currentFirstResponder;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"iPOS"];
	
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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

#pragma mark UIViewController overrides
- (void)loadView
{
	
	[self setView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	
	[self setLoginTableView:[[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease]];
	
	[self.view addSubview:self.loginTableView];
	
}

- (void)viewDidLoad
{
	// Do this at the beginning
	[super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	self.view.backgroundColor = [UIColor blackColor];
	
	self.loginTableView.backgroundColor = [UIColor clearColor];
	self.loginTableView.dataSource = self;
	self.loginTableView.delegate = self;
	
}

- (void)viewDidUnload
{	
	// Release any retained subviews of the main view
}

- (void)viewWillAppear:(BOOL)animated
{
	CGRect viewBounds = self.view.bounds;
	
	if (self.loginTableView) {
		[self.loginTableView reloadData];
		self.loginTableView.frame = viewBounds;
	}
	
	if (self.loginTableView.tableHeaderView == nil) {
		PlaceHolderView *tableHeader = [[[PlaceHolderView alloc] initWithFrame:CGRectMake(0, 0, viewBounds.size.width, floorf(viewBounds.size.height / 2.0f))] autorelease];
		tableHeader.placeHolderLabel.text = @"iPOS Logo";
		tableHeader.placeHolderLabel.backgroundColor = [UIColor blackColor];
		tableHeader.placeHolderLabel.textColor = [UIColor whiteColor];
		tableHeader.bgColor = [UIColor blackColor];
		//tableHeader.strokeColor = [UIColor whiteColor];
		self.loginTableView.tableHeaderView = tableHeader;
	}
	
	if (self.loginTableView.tableFooterView == nil) {
		PlaceHolderView *tableFooter = [[[PlaceHolderView alloc] initWithFrame:CGRectMake(0, 0, viewBounds.size.width, 80.0f)] autorelease];
		tableFooter.placeHolderLabel.text = @"TileShop Logo";
		tableFooter.placeHolderLabel.backgroundColor = [UIColor blackColor];
		tableFooter.placeHolderLabel.textColor = [UIColor whiteColor];
		tableFooter.bgColor = [UIColor blackColor];
		//tableHeader.strokeColor = [UIColor whiteColor];
		self.loginTableView.tableFooterView = tableFooter;
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

- (BOOL) houldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// This will keep the interface locked to portrait
	//return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
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
		self.empId = textField.text;
	} else if (textField.tag == 1) {
		self.password = textField.text;
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
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:LoginTableIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		NSInteger row = indexPath.row;
		
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
				loginTextField.returnKeyType = UIReturnKeyNext;
				break;
			case 1:
				cell.textLabel.text = @"Password";
				loginTextField.returnKeyType = UIReturnKeyGo;
				loginTextField.secureTextEntry = YES;
				break;
			default:
				break;
		}
		cell.accessoryView = loginTextField;
		[loginTextField release];
	}
	
	return cell;

}


@end
