//
//  MainMenuViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AlertUtils.h"

#include "PlaceHolderView.h"


@interface MainMenuViewController() <UITextFieldDelegate>
- (void) customerPressed;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end


@implementation MainMenuViewController

@synthesize scanItemLabel;
@synthesize lookupItemField;
@synthesize lookupOrderField;
@synthesize customerButton;

@synthesize currentFirstResponder;

@synthesize lookupItemSku;
@synthesize scannedItemSku;
@synthesize lookupOrderNum;

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
	
	facade = [iPOSFacade sharedInstance];
	
    return self;
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	[self setCurrentFirstResponder:nil];
	 
	[self setScanItemLabel:nil];
	[self setLookupItemField:nil];
	//[self setLookupOrderField:nil];
	[self setCustomerButton:nil];
	
	[self setLookupItemSku:nil];
	[self setScannedItemSku:nil];
	[self setLookupOrderNum:nil];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView
{
	return (UIView *)[self view];
}

#pragma mark -
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    NSMutableString *status = [[[NSMutableString alloc] init] autorelease];
    [status setString:@""];
	[status appendFormat:@"Type: %d\n",type];
	[status appendFormat:@"Type text: %@\n",[linea barcodeType2Text:type]];
	[status appendFormat:@"Barcode: %@",barcode];
    
    // TODO:  This is where you will initialize and show the Item Overlay View
    [AlertUtils showModalAlertMessage: status];
}

#pragma mark -
#pragma mark UIViewController overrides

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	[self setView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	self.view.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	
	[self setScanItemLabel: [[[UILabel alloc] initWithFrame:CGRectZero] autorelease]];
	self.scanItemLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	self.scanItemLabel.textColor = [UIColor blackColor];
	self.scanItemLabel.text = @"-- SCAN ITEM --";
	self.scanItemLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:self.scanItemLabel];
	
	[self setLookupItemField:[[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease]];
	self.lookupItemField.textColor = [UIColor blackColor];
	self.lookupItemField.borderStyle = UITextBorderStyleRoundedRect;
	self.lookupItemField.textAlignment = UITextAlignmentCenter;
	self.lookupItemField.clearsOnBeginEditing = YES;
	self.lookupItemField.placeholder = @"Look Up Item";
	self.lookupItemField.tagName = @"LookupItem";
	self.lookupItemField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	[self.view addSubview:self.lookupItemField];
	
	// Look up order will be in a later release
	//[self setLookupOrderField:[[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease]];
	//self.lookupOrderField.textColor = [UIColor blackColor];
	//self.lookupOrderField.borderStyle = UITextBorderStyleRoundedRect;
	//self.lookupOrderField.textAlignment = UITextAlignmentCenter;
	//self.lookupOrderField.clearsOnBeginEditing = YES;
	//self.lookupOrderField.placeholder = @"Look Up Order";
	//self.lookupOrderField.tagName = @"LookupOrder";
	//self.lookupOrderField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	//[self.view addSubview:self.lookupOrderField];
	
	[self setCustomerButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	[self.customerButton setTitle:@"Add Customer" forState:UIControlStateNormal];
	[self.customerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.view addSubview:self.customerButton];
	 
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.lookupItemField.delegate = self;
	//self.lookupOrderField.delegate = self;
	[self.customerButton addTarget:self action:@selector(customerPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add itself as a delegate
    linea = [Linea sharedDevice];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {

    // Add this controller as a Linea Device Delegate
    [linea addDelegate:self];


	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	CGRect viewBounds = self.view.bounds;
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.20f;
	
	self.scanItemLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
	self.scanItemLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
	
	self.lookupItemField.frame = CGRectOffset(self.scanItemLabel.frame, 0.0f, labelButtonSpacing);
	
	//self.lookupOrderField.frame = CGRectOffset(self.lookupItemField.frame, 0.0f, labelButtonSpacing);
	
	// Change to work from lookupOrderField position when that is implemented
	self.customerButton.frame = CGRectOffset(self.lookupItemField.frame, 0.0f, labelButtonSpacing);
	
	// Do this last
	[super viewWillAppear:animated];
}
	 
- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
	NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
	[noteCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[noteCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {

    // Remove this controller as a linea delegate
    [linea removeDelegate: self];

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

#pragma mark -
#pragma mark UIButton callbacks

- (void)customerPressed {
}

#pragma mark -
#pragma mark ExtUITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textFieldDidEndEditing:(ExtUITextField *)textField {
	
	self.currentFirstResponder = nil;
	
	// Set the values and do the work here
	if ([textField.tagName isEqualToString:@"LookupItem"]) {
		self.lookupItemSku = textField.text;
		// Call the service and display the overlay view
	} else if ([textField.tagName isEqualToString:@"LookupOrder"]) {
		self.lookupOrderNum = textField.text;
		// Call the service and set up the order review (later revision)
	}
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Keyboard Management
- (void)keyboardWillShow:(NSNotification *)notification {
}

- (void)keyboardWillHide:(NSNotification *)notification {
}

@end
