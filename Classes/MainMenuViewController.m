//
//  MainMenuViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AlertUtils.h"
#import "ProductItem.h"
#import "LayoutUtils.h"

#include "AddItemView.h"
#include "CustomerViewController.h"

#include "SignatureViewController.h"


@interface MainMenuViewController()
- (void) addKeyboardListeners;
- (void) removeKeyboardListeners;
- (void) customerPressed:(id)sender;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end


@implementation MainMenuViewController

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
    ProductItem *item = [facade lookupProductItem:barcode];
    
    if (item == nil) {
        [AlertUtils showModalAlertMessage: @"Item not found"];
    } else {
		[linea removeDelegate:self];
		[self removeKeyboardListeners];
		AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
		[overlay setViewDelegate:self];
		[self.view addSubview:overlay];
		[overlay setProductItem:item];
		[overlay release];
    }
}

-(void) magneticCardRawData:(NSData *)tracks {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *demoCardReader = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.demo.enableSignature"];

    if (demoCardReader != nil && [demoCardReader isEqualToString: @"YES"]) {
        // [AlertUtils showModalAlertMessage: @"Card Data received!!"];
        
        // [linea removeDelegate:self];
        // [self removeKeyboardListeners];
        
        // Add the modal view
        SignatureViewController *modalController = [[[SignatureViewController alloc] init] autorelease];        
        
        modalController.delegate = self;
        [self presentModalViewController:modalController animated:YES]; 
       
    }
}

#pragma mark -
#pragma mark SignatureDelegate methods
//TODO:This will be moved to another controller
- (void) signatureController:(SignatureViewController *)signatureController signatureAsBase64:(NSString *)signature savePressed:(id)sender {
    // This is where the image would be sent as a base64EncodedString to the payment services
    [self dismissModalViewControllerAnimated:YES];
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
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
	bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:bgView];
	[bgView release];
	
	scanItemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	scanItemLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	scanItemLabel.textColor = [UIColor blackColor];
	scanItemLabel.text = @"-- SCAN ITEM --";
	scanItemLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:scanItemLabel];
	[scanItemLabel release];
	
	lookupItemField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupItemField.textColor = [UIColor blackColor];
	lookupItemField.borderStyle = UITextBorderStyleRoundedRect;
	lookupItemField.textAlignment = UITextAlignmentCenter;
	lookupItemField.clearsOnBeginEditing = YES;
	lookupItemField.placeholder = @"Look Up Item";
	lookupItemField.tagName = @"LookupItem";
	lookupItemField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	lookupItemField.returnKeyType = UIReturnKeyGo;
	lookupItemField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	[self.view addSubview:lookupItemField];
	[lookupItemField release];
	
	// Look up order will be in a later release
	//lookupOrderField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	//lookupOrderField.textColor = [UIColor blackColor];
	//lookupOrderField.borderStyle = UITextBorderStyleRoundedRect;
	//lookupOrderField.textAlignment = UITextAlignmentCenter;
	//lookupOrderField.clearsOnBeginEditing = YES;
	//lookupOrderField.placeholder = @"Look Up Order";
	//lookupOrderField.tagName = @"LookupOrder";
	//lookupOrderField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//[self.view addSubview:lookupOrderField];
	//[lookupOrderField release];
	
	customerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[customerButton setTitle:@"Customer" forState:UIControlStateNormal];
	[customerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.view addSubview:customerButton];
	 
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	lookupItemField.delegate = self;
	//lookupOrderField.delegate = self;
	[customerButton addTarget:self action:@selector(customerPressed:) forControlEvents:UIControlEventTouchUpInside];
    
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
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}
	
	CGRect viewBounds = self.view.bounds;
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.20f;
	
	scanItemLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
	scanItemLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
	
	lookupItemField.frame = CGRectOffset(scanItemLabel.frame, 0.0f, labelButtonSpacing);
	
	//lookupOrderField.frame = CGRectOffset(lookupItemField.frame, 0.0f, labelButtonSpacing);
	
	// Change to work from lookupOrderField position when that is implemented
	customerButton.frame = CGRectOffset(lookupItemField.frame, 0.0f, labelButtonSpacing);
	
	// Do this last
	[super viewWillAppear:animated];
}
	 
- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
	[self addKeyboardListeners];
}

- (void)viewWillDisappear:(BOOL)animated {

    // Remove this controller as a linea delegate
    [linea removeDelegate: self];

	[self removeKeyboardListeners];
	
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	// Do this at the end
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UIButton callbacks

- (void)customerPressed:(id)sender {
	[linea removeDelegate:self];
	[self removeKeyboardListeners];
    CustomerViewController *customerViewController = [[CustomerViewController alloc] init];
	[[self navigationController] pushViewController:customerViewController animated:TRUE];
	[customerViewController release];
}

- (void)addKeyboardListeners {
	NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
	[noteCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[noteCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeKeyboardListeners {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
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
		[self setLookupItemSku: nil];
		[self setLookupItemSku: textField.text];
		// Call the service and display the overlay view
		ProductItem *item = [facade lookupProductItem:self.lookupItemSku];
		if (item == nil) {
			[AlertUtils showModalAlertMessage: @"Item not found"];
		} else {
			[linea removeDelegate:self];
			[self removeKeyboardListeners];
			AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
			[overlay setViewDelegate:self];
			[self.view addSubview:overlay];
			[overlay setProductItem:item];
			[overlay release];
			textField.text = nil;
		}
		
	} else if ([textField.tagName isEqualToString:@"LookupOrder"]) {
		[self setLookupOrderNum:nil];
		[self setLookupOrderNum:textField.text];
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
	if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
		NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
		if (!keyboardFrameValue) {
			keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
		}
		
		// Find out how much of the keyboard overlaps the textfield and move the view up out of the way
		CGRect windowRect = [[UIApplication sharedApplication] keyWindow].bounds;
		if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
			windowRect = [LayoutUtils swapRect:windowRect];
		}
		
		UITextField *tf = (UITextField *)self.currentFirstResponder;
		
		CGRect viewRectAbsolute = [tf convertRect:tf.bounds toView:[[UIApplication sharedApplication] keyWindow]];
		if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
			viewRectAbsolute = [LayoutUtils swapRect:viewRectAbsolute];
		}
		
		CGRect frame = self.view.frame;
		CGRect keyboardRect = [keyboardFrameValue CGRectValue];
		
		previousViewOriginY = frame.origin.y;
		CGFloat adjustUpBy = (windowRect.size.height - keyboardRect.size.height) - (CGRectGetMaxY(viewRectAbsolute) + 10.0f);
		
		if (adjustUpBy < 0) {
			frame.origin.y = adjustUpBy;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
			self.view.frame = frame;
			[UIView commitAnimations];
		}
		// iOS 3 sends hide and show notifications right after each other
		// when switching between textFields, so cancel -scrollToOldPosition requests
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		

		CGRect frame = self.view.frame;
		if (frame.origin.y != previousViewOriginY) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
			frame.origin.y = previousViewOriginY;
			self.view.frame = frame;
			[UIView commitAnimations];
			previousViewOriginY = 0.0f;
		}
	}
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
	[linea addDelegate:self];
	[self addKeyboardListeners];
}

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	// TODO: set up the order and push to the cart view
	NSMutableString *status = [[NSMutableString alloc] init];
	[status setString:@""];
	[status appendFormat:@"Would Order:  %.2f\n", [quantity doubleValue]];
	[status appendFormat:@"Units:  %@\n", unitOfMeasure];
	
	[addItemView removeFromSuperview];
	[linea addDelegate:self];
	[self addKeyboardListeners];
		 
	[AlertUtils showModalAlertMessage: status];
	[status release];
		 
}

@end
