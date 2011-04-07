//
//  CartItemDetailViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemDetailViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "NSString+StringFormatters.h"

#define LABEL_FONT_SIZE 16.0f
#define LABEL_HEIGHT 18.0f
#define TEXT_FIELD_HEIGHT 40.0f
#define TEXT_FIELD_START_X 20.0f
#define TEXT_FIELD_WIDTH 70.0f
#define UOM_LABEL_START_X 100.0f
#define UOM_LABEL_WIDTH 60.0f
#define ITEM_TOTAL_START_X 160.0f
#define ITEM_TOTAL_WIDTH 160.0f
#define BUTTON_HEIGHT 40.0f
#define BUTTON_WIDTH 212.0f

@interface CartItemDetailViewController()
- (void) handleDeleteButton:(id)sender;
- (void) handleCloseButton:(id)sender;
- (void) handlePriceButton:(id)sender;
- (void) updateViewLayout;
@end

@implementation CartItemDetailViewController

@synthesize orderItem;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	// [[self navigationItem] setTitle:@"Item Number Here"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];

    return self;
}

- (id) initWithOrderItem:(OrderItem *)editOrderItem {
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	facade = [iPOSFacade sharedInstance];
	[self setOrderItem:editOrderItem];
	
	[[self navigationItem] setTitle:[editOrderItem.item.sku stringValue]];
	
	return self;
}

- (void)dealloc {
	//[self setOrderItem:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView
{
	return (UIView *)[self view];
}

#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *bgView = [[UIView alloc] initWithFrame:[self rectForNav]];
	bgView.backgroundColor = [UIColor whiteColor];
	[self setView:bgView];
	[bgView release];
	
	CGFloat cy = 0.0f;
	
	productItemView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.bounds.size.width, LABEL_HEIGHT * 4.0f)];
	productItemView.backgroundColor = [UIColor colorWithWhite:0.70f alpha:1.0f];
	
	// Where we are in the productItem view 
	CGFloat vy = LABEL_HEIGHT / 2.0f;
	skuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, vy, productItemView.bounds.size.width, LABEL_HEIGHT)];
	skuLabel.backgroundColor = [UIColor clearColor];
	skuLabel.textColor = [UIColor blackColor];
	skuLabel.textAlignment = UITextAlignmentCenter;
	skuLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	[productItemView addSubview:skuLabel];
	[skuLabel release];
	
	vy += LABEL_HEIGHT;
	descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, vy, productItemView.bounds.size.width, LABEL_HEIGHT)];
	descLabel.backgroundColor = [UIColor clearColor];
	descLabel.textColor = [UIColor blackColor];
	descLabel.textAlignment = UITextAlignmentCenter;
	descLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	[productItemView addSubview:descLabel];
	[descLabel release];
	
	vy += LABEL_HEIGHT;
	priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, vy, productItemView.bounds.size.width, LABEL_HEIGHT)];
	priceLabel.backgroundColor = [UIColor clearColor];
	priceLabel.textColor = [UIColor blackColor];
	priceLabel.textAlignment = UITextAlignmentCenter;
	priceLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	[productItemView addSubview:priceLabel];
	[priceLabel release];
	
	[self.view addSubview:productItemView];
	[productItemView release];
	
	cy += (LABEL_HEIGHT * 4.0f);
	
	orderItemView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.bounds.size.width, TEXT_FIELD_HEIGHT * 3.0f)];
	orderItemView.backgroundColor = [UIColor colorWithWhite:0.50f alpha:1.0f];
	
	vy = TEXT_FIELD_HEIGHT;
	quantityField = [[ExtUITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_START_X, vy, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT)];
	quantityField.textColor = [UIColor blackColor];
	quantityField.borderStyle = UITextBorderStyleRoundedRect;
	quantityField.textAlignment = UITextAlignmentCenter;
	quantityField.clearsOnBeginEditing = NO;
	quantityField.tagName = @"ItemQuantity";
	quantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	quantityField.returnKeyType = UIReturnKeyGo;
	quantityField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	[self addDoneToolbarForTextField:quantityField];
	// Set auxiliary view for keyboard when it is displayed for this text field.
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *kbToolbarFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *kbToolbarItems = [[[NSArray alloc] initWithObjects:doneButton, kbToolbarFlex, nil] autorelease];
	[keyboardToolbar setItems:kbToolbarItems];
	[quantityField setInputAccessoryView:keyboardToolbar];
	[orderItemView addSubview:quantityField];
	[quantityField release];
	
	CGFloat centerToText = floorf((TEXT_FIELD_HEIGHT - LABEL_HEIGHT) / 2.0f);
	unitOfMeasureLabel = [[UILabel alloc] initWithFrame:CGRectMake(UOM_LABEL_START_X, vy+centerToText, UOM_LABEL_WIDTH, LABEL_HEIGHT)];
	unitOfMeasureLabel.backgroundColor = [UIColor clearColor];
	unitOfMeasureLabel.textColor = [UIColor blackColor];
	unitOfMeasureLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	[orderItemView addSubview:unitOfMeasureLabel];
	[unitOfMeasureLabel release];
	
	itemTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(ITEM_TOTAL_START_X, vy+centerToText, ITEM_TOTAL_WIDTH, LABEL_HEIGHT)];
	itemTotalLabel.backgroundColor = [UIColor clearColor];
	itemTotalLabel.textColor = [UIColor blackColor];
	itemTotalLabel.textAlignment = UITextAlignmentCenter;
	itemTotalLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	[orderItemView addSubview:itemTotalLabel];
	[itemTotalLabel release];
	
	[self.view addSubview:orderItemView];
	[orderItemView release];
	
	cy += (TEXT_FIELD_HEIGHT * 3.0f) + BUTTON_HEIGHT;
	
	deleteButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - BUTTON_WIDTH) / 2.0f), cy, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[deleteButton setupAsRedButton];
	deleteButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
	[self.view addSubview:deleteButton];
	[deleteButton release];
	
	// TODO: add close line and price button when we support them
	
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	quantityField.delegate = self;
	[deleteButton addTarget:self action:@selector(handleDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self updateViewLayout];
	
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}


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

#pragma mark -
#pragma mark ExtUIViewController delegates

- (void) extTextFieldFinishedEditing:(ExtUITextField *) textField {
	if (textField.text != nil) {
		NSDecimalNumber *newQuantity = [NSDecimalNumber decimalNumberWithString:textField.text];
		if (newQuantity != nil) {
			self.orderItem.quantity = newQuantity;
			[self updateViewLayout];
		}
	}
}

#pragma mark -
#pragma mark UIButton handlers
- (void) handleCloseButton:(id)sender {

}

- (void) handleDeleteButton:(id)sender {
	ProductItem *pi = self.orderItem.item;
	Order *order = [facade currentOrder];
	[order removeItemFromOrder:pi];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) handlePriceButton:(id)sender {
}

#pragma mark -
#pragma mark View Update methods
- (void) updateViewLayout {
	if (self.orderItem != nil) {
		skuLabel.text = [self.orderItem.item.sku stringValue];
		descLabel.text = self.orderItem.item.description;
		priceLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString formatDecimalNumberAsMoney:self.orderItem.sellingPrice], self.orderItem.item.primaryUnitOfMeasure];
		quantityField.text = [self.orderItem.quantity stringValue];
		unitOfMeasureLabel.text = self.orderItem.item.primaryUnitOfMeasure;
		NSDecimalNumber *lineTotal = [self.orderItem.sellingPrice decimalNumberByMultiplyingBy:self.orderItem.quantity];
		itemTotalLabel.text = [NSString formatDecimalNumberAsMoney:lineTotal];
	}
}

@end
