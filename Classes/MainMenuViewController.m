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

#include "AddItemView.h"
#include "CustomerViewController.h"
#include "CartItemsViewController.h"

#include "Order.h"

@interface MainMenuViewController()
- (void) customerPressed:(id)sender;
@end


@implementation MainMenuViewController

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
	[self setTitle:@"iPOS"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
	
    return self;
}

- (void)dealloc {
	
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
    
    if(item != nil && [item.sku isEqualToNumber:[NSNumber numberWithInt:0]] == NO) {
		[linea removeDelegate:self];
		[self removeKeyboardListeners];
		AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
		[overlay setViewDelegate:self];
		[self.view addSubview:overlay];
		[overlay setProductItem:item];
		[overlay release];
    } else {
		[AlertUtils showModalAlertMessage: @"Item not found"];
	}

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
	lookupItemField.returnKeyType = UIReturnKeySearch;
	lookupItemField.keyboardType = UIKeyboardTypeNumberPad;
	[super addDoneAndCancelToolbarForTextField:lookupItemField];
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
	
	customerButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[customerButton setTitle:@"Customer" forState:UIControlStateNormal];
	[customerButton setupAsBlackButton];
	[self.view addSubview:customerButton];
	
	cartButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[cartButton setTitle:@"Order" forState:UIControlStateNormal];
	[cartButton setupAsBlackButton];
	[self.view addSubview:cartButton];
	 
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	lookupItemField.delegate = self;
	//lookupOrderField.delegate = self;
	[customerButton addTarget:self action:@selector(customerPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartButton addTarget:self action:@selector(cartPressed:) forControlEvents:UIControlEventTouchUpInside];
	
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
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
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
	
	cartButton.frame = CGRectOffset(customerButton.frame, 0.0f, labelButtonSpacing);
	
	// Do this last
	[super viewWillAppear:animated];
}
	 
- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    // Remove this controller as a linea delegate
    [linea removeDelegate: self];
	
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
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

- (void)cartPressed:(id)sender {
	[linea removeDelegate:self];
	[self removeKeyboardListeners];
    CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
}

#pragma mark -
#pragma mark ExtUIViewController delegate

- (void)extTextFieldFinishedEditing:(ExtUITextField *)textField {
	if ([textField.tagName isEqualToString:@"LookupItem"] && [textField.text length] > 0) {
		[self setLookupItemSku: nil];
		[self setLookupItemSku: textField.text];
		// Call the service and display the overlay view
		ProductItem *item = [facade lookupProductItem:self.lookupItemSku];
		// TODO: do we have to do the additional check on sku because of the OPI test service?
		if(item != nil && [item.sku isEqualToNumber:[NSNumber numberWithInt:0]] == NO) {
			[linea removeDelegate:self];
			[self removeKeyboardListeners];
			AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
			[overlay setViewDelegate:self];
			[self.view addSubview:overlay];
			[overlay setProductItem:item];
			[overlay release];
			textField.text = nil;
		} else {
			[AlertUtils showModalAlertMessage: @"Item not found"];
		}

		
	} else if ([textField.tagName isEqualToString:@"LookupOrder"] && [textField.text length] > 0) {
		[self setLookupOrderNum:nil];
		[self setLookupOrderNum:textField.text];
		// Call the service and set up the order review (later revision)
	}
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
	[linea addDelegate:self];
	[self addKeyboardListeners];
}

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	ProductItem *item = [addItemView productItem];
    
    [orderCart addItem:item withQuantity:quantity];
    if ([orderCart getOrder].errorList && [[orderCart getOrder].errorList count] > 0) {
        [AlertUtils showModalAlertForErrors:[orderCart getOrder].errorList];
        return;
    }
    
    [addItemView removeFromSuperview];

    CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
		 
}

@end
