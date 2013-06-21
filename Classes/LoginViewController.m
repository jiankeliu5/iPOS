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
#import "iPOSAppDelegate.h"

#pragma mark -
#pragma mark Private Interface
@interface LoginViewController () 
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) dismissKeyboard:(id)sender;
- (void) cancelAndDismissKeyboard:(id)sender;
- (void) addDoneAndCancelToolbarForTextField:(UITextField *)textField;
@end

#pragma mark -
@implementation LoginViewController

@synthesize empId;
@synthesize password;
@synthesize storeId;
@synthesize deviceId;

@synthesize currentFirstResponder;
@synthesize keyboardCancelled;
@synthesize originalCenter;

#pragma mark Constructors
- (id)init
{
    NSLog(@"lOGIN INITIALIZED");
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
	orderCart = [OrderCart sharedInstance];
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[linea disconnect];
    
    [topRowBeforeKeyboardShown release];
	
	[self setCurrentFirstResponder:nil];
	[self setEmpId:nil];
	[self setPassword:nil];
	[self setStoreId:nil];
	[self setDeviceId:nil];
    
  	[super dealloc];
}

#pragma mark -
#pragma mark Accessors
//=========================================================== 
// - setTopRowBeforeKeyboardShown:
//=========================================================== 
- (void)setTopRowBeforeKeyboardShown:(NSIndexPath *)aTopRowBeforeKeyboardShown {
    if (topRowBeforeKeyboardShown != aTopRowBeforeKeyboardShown) {
        [aTopRowBeforeKeyboardShown retain];
        [topRowBeforeKeyboardShown release];
        topRowBeforeKeyboardShown = aTopRowBeforeKeyboardShown;
    }
}




#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Linea Delegate
-(void)connectionState:(int)state {
    switch (state) {
		case CONN_DISCONNECTED:	
            break;
        case CONN_CONNECTING:
            break; 
		case CONN_CONNECTED:
            [linea msStartScan];
            [linea setMSCardDataMode:MS_PROCESSED_CARD_DATA];
            break;
	}
    
}
#pragma mark UIViewController overrides
- (void)loadView
{
    NSLog(@"LOGIN LOADVIEW");
	UIView *bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self setView:bgView];
	[bgView release];
	
	UIImage *img = [UIImage imageNamed:@"iPosLogin.png"];
	UIImageView *iv = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	iv.contentMode = UIViewContentModeBottomLeft;
	iv.clipsToBounds = YES;
	iv.image = img;
	[self.view addSubview:iv];
	[iv release];
	
    
	loginTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    //loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
	loginTableView.backgroundColor = [UIColor clearColor];
    //These two lines of code solved the ios 6 group view problem -- Enning Tang 9/28/2012
    loginTableView.opaque = NO;
    loginTableView.backgroundView = nil;
    //loginTableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"iPosLogin.png"]];
	
	//[self.view addSubview:loginTableView];
	//[loginTableView release];
     
    
    //Enning Tang Added textbox instead of using tableview 4/15/2013
    CGFloat labelButtonWidth = self.view.bounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = self.view.bounds.size.height * 0.15f;
    userName = [[ExtUITextField alloc] initWithFrame:CGRectZero];
    userName.textColor = [UIColor blackColor];
    userName.borderStyle = UITextBorderStyleRoundedRect;
    userName.textAlignment = NSTextAlignmentLeft;
    userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userName.clearsOnBeginEditing = YES;
    userName.tag = 0;
    userName.placeholder = @"Employee ID";
    userName.textAlignment = NSTextAlignmentCenter;
    [userName setKeyboardType:UIKeyboardTypeDecimalPad];
    userName.returnKeyType = UIReturnKeyDone;
    userName.delegate = self;
    userName.userInteractionEnabled = true;
    [self addDoneAndCancelToolbarForTextField:userName];
    
    [self.view addSubview:userName];
    
    passWord = [[ExtUITextField alloc] initWithFrame:CGRectZero];
    passWord.textColor = [UIColor blackColor];
    passWord.borderStyle = UITextBorderStyleRoundedRect;
    passWord.textAlignment = NSTextAlignmentLeft;
    passWord.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passWord.clearsOnBeginEditing = YES;
    passWord.tag = 1;
    passWord.placeholder = @"Password";
    passWord.textAlignment = NSTextAlignmentCenter;
    passWord.secureTextEntry = YES;
    [passWord setKeyboardType:UIKeyboardTypeDecimalPad];
    passWord.returnKeyType = UIReturnKeyDone;
    passWord.delegate = self;
    passWord.userInteractionEnabled = true;
    [self addDoneAndCancelToolbarForTextField:passWord];
    
    [self.view addSubview:passWord];
    
    userName.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 80.0f, 40.0f);
    userName.center = CGPointMake((self.view.bounds.size.width / 2.0f), 300.0f);
    
    passWord.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 80.0f, 40.0f);
    passWord.center = CGPointMake((self.view.bounds.size.width / 2.0f), 300.0f + userName.frame.size.height);
    
    //==============================================================
    
    /*
    loginButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [loginButton setupAsGreenButton];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [loginButton setTitle:@"Log on" forState:UIControlStateNormal];
    
    loginButton.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width - 100.f, self.view.bounds.size.height - 400.f);
    loginButton.center = CGPointMake((self.view.bounds.size.width / 2.0f), self.view.bounds.size.height - 150.f);
    [loginButton addTarget:self action:@selector(handleLogonButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    [loginButton release];
    */
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    versionNumber = [[UILabel alloc] initWithFrame:CGRectZero];
	versionNumber.backgroundColor = [UIColor clearColor];
	versionNumber.textColor = [UIColor whiteColor];
	versionNumber.text = [NSString stringWithFormat:@"%@%@", @"ver.", (NSString *) [bundle objectForInfoDictionaryKey:@"currentVersion"]];
	versionNumber.textAlignment = NSTextAlignmentCenter;
    
	[self.view addSubview:versionNumber];
	[versionNumber release];
    versionNumber.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 80.0f);
    versionNumber.center = CGPointMake((self.view.bounds.size.width / 2.0f), labelButtonSpacing + 330);
}

- (void)viewDidLoad
{
    NSLog(@"lOGIN DIDLOAD");
	// Do this at the beginning
	[super viewDidLoad];
	
	loginTableView.dataSource = self;
	loginTableView.delegate = self;
    
    userName.delegate = self;
    passWord.delegate = self;
    
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
    NSLog(@"lOGIN WILLAPPEAR");
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	// Make sure we logout and disconnect from Linea device
	[self setEmpId:nil];
	[self setPassword:nil];
    
    userName.delegate = self;
    passWord.delegate = self;
    
    [facade logout];
    [facade sslogout];
    
    //[linea disconnect];
    
    // Clear out all sections of the order cart
    [orderCart clearAllCart];
	
    // Not sure if I like reaching back to the app delegate all the time for the
    // order lookup navigation controller.  Add it to the facade instead?
    // Make sure when we log out that we pop the order lookup nav controller 
    // all the way back too.
    iPOSAppDelegate *app = (iPOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *orderNav = [app orderNavigationController];
    [orderNav popToRootViewControllerAnimated:YES];
    
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
	
	self.keyboardCancelled = NO;
	
	// Do this at the end
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"lOGIN DIDAPPEAR");
	// Do these at the beginning
	[loginTableView flashScrollIndicators];
	[super viewDidAppear:animated];
    
    userName.delegate = self;
    passWord.delegate = self;
	
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
    NSLog(@"Should Begin Editing");
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Begin Editing");
    self.originalCenter = self.view.center;
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 160.0f);
	self.currentFirstResponder = textField;
	//if ([loginTableView indexPathsForVisibleRows].count) {
	//	[self setTopRowBeforeKeyboardShown:(NSIndexPath *) [[loginTableView indexPathsForVisibleRows] objectAtIndex:0]];
	//} else {
    //    [self setTopRowBeforeKeyboardShown:[NSIndexPath indexPathForRow:0 inSection:0]];
	//	[textField resignFirstResponder];
	//}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"End Editing");
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
	self.currentFirstResponder = nil;

	if (self.keyboardCancelled == NO) {
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
		
		if (self.empId != nil && self.password != nil && textField.text != nil && ![self.empId isEqualToString:@""] && ![self.password isEqualToString:@""]) {
			UIAlertView *alert = [AlertUtils showProgressAlertMessage:@"Logging In"];
            if([facade login:self.empId password:self.password] && [facade sslogin:self.empId password:self.password]) {
			//if([facade login:self.empId password:self.password]) {
				[AlertUtils dismissAlertMessage: alert];
				
				MainMenuViewController *mainMenuViewController = [[MainMenuViewController alloc] init];
				[[self navigationController] pushViewController:mainMenuViewController animated:TRUE];
				[mainMenuViewController release];
                //userName.text = nil;
                //passWord.text = nil;
				
				// This is where we would connect to the linea-pro device
				//[linea connect];
				
			} else {
				[AlertUtils dismissAlertMessage:alert];
				[AlertUtils showModalAlertMessage:@"Login failure.  Please try again." withTitle:@"iPOS"];
			}
			
			[self setEmpId:nil];
			[self setPassword:nil];
			[loginTableView reloadData];
            userName.text = nil;
            passWord.text = nil;
			
		}
	} else {
		// User cancelled out
		self.keyboardCancelled = NO;
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
    NSLog(@"Keyboard will show");
	//if (self.navigationController.topViewController == self) {
		//NSDictionary* userInfo = [notification userInfo];
		
		// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
		//NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
		//if (!keyboardFrameValue) {
		//	keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
		//}
		
		// Reduce the tableView height by the part of the keyboard that actually covers the tableView
		//CGRect windowRect = [[UIApplication sharedApplication] keyWindow].bounds;
		//if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
		//	windowRect = [LayoutUtils swapRect:windowRect];
		//}
		
		//CGRect viewRectAbsolute = [loginTableView convertRect:loginTableView.bounds toView:[[UIApplication sharedApplication] keyWindow]];
		//if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
		//	viewRectAbsolute = [LayoutUtils swapRect:viewRectAbsolute];
		//}
    
        //CGRect viewRectAbsolute = [userName convertRect:userName.bounds toView:[[UIApplication sharedApplication] keyWindow]];
        //if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
        //    viewRectAbsolute = [LayoutUtils swapRect:viewRectAbsolute];
        //}
    
		/*
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
         */
	//}
}


- (void)scrollToOldPosition {
	[loginTableView scrollToRowAtIndexPath:topRowBeforeKeyboardShown atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSLog(@"keyboardWillHide");
	/*if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		//loginTableView.frame = self.view.bounds;
		[UIView commitAnimations];
		
		//[self performSelector:@selector(scrollToOldPosition) withObject:nil afterDelay:0.1];
	}*/
    NSDictionary* userInfo = [notification userInfo];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    //loginTableView.frame = self.view.bounds;
    [UIView commitAnimations];
}	

#pragma mark UITableViewDelegate
//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
//{
// Need to have the inputs, so not navigating based on row touches here.
//}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	return nil;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *EmpIDIdentifier = @"EmpIDIdentifier";
    static NSString *PasswordIdentifier = @"PasswordIdentifier";
	UITableViewCell *cell = nil;
	
	NSInteger row = indexPath.row;
    
    if (row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:EmpIDIdentifier];
    } else if (row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:PasswordIdentifier];
    }

	if (cell == nil) {
        if (row == 0) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmpIDIdentifier] autorelease];
        } else if (row == 1) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PasswordIdentifier] autorelease];
        }
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		
		UITextField *loginTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, floorf(tableView.frame.size.width / 2.0f), 21.0f)];
		loginTextField.adjustsFontSizeToFitWidth = YES;
		loginTextField.textColor = [UIColor blackColor];
		loginTextField.tag = row;
		loginTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		loginTextField.delegate = self;
        [self addDoneAndCancelToolbarForTextField:loginTextField];
		
		switch (row) {
			case 0:
				cell.textLabel.text = @"Employee Id";
				loginTextField.returnKeyType = UIReturnKeyDone;
				loginTextField.keyboardType = UIKeyboardTypeNumberPad;
				loginTextField.text = self.empId;
				break;
			case 1:
				cell.textLabel.text = @"Password";
				loginTextField.returnKeyType = UIReturnKeyDone;
				loginTextField.keyboardType = UIKeyboardTypeNumberPad;
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
 */

- (void) addDoneAndCancelToolbarForTextField:(UITextField *)textField {
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAndDismissKeyboard:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, cancelButton, nil] autorelease];
    
    [keyboardToolbar setItems:items];
	[textField setInputAccessoryView:keyboardToolbar];
}

- (void) dismissKeyboard:(id)sender {
    NSLog(@"dismissKeyboard");
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// The toolbar done button calls this.  Allows the delegate to be called.
		self.keyboardCancelled = NO;
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void) cancelAndDismissKeyboard:(id)sender {
    NSLog(@"cancelAndDismissKeyboard");
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void) handleLogonButton:(id)sender {
    NSLog(@"Logon Called");
    
    
    CGRect overlayRect = self.view.bounds;
    getlogonSubView = [[LogonSubView alloc] initWithFrame:overlayRect];
    
    [self.view addSubview:getlogonSubView];
    
    [getlogonSubView release];
    
}

@end
