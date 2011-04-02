//
//  CartItemsViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemsViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "NSString+StringFormatters.h"
#import "AlertUtils.h"
#import "LayoutUtils.h"
#import "Customer.h"
#import	"Order.h"
#import "OrderItem.h"
#import "ProductItem.h"
#import "CartItemTableCell.h"
#import "CartItemDetailViewController.h"

#define CUST_SELECTED_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define NO_CUST_SELECTED_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]

#define CUST_LABEL_HEIGHT 14.0f
#define CUST_LABEL_FONT_SIZE 12.0f
#define CUST_LABEL_END_WIDTH 106.0f
#define CUST_LABEL_MIDDLE_WIDTH 108.0f

#define ORDER_TABLE_HEIGHT 310.0f

#define ORDER_LABEL_FONT_SIZE 14.0f
#define ORDER_LABEL_WIDTH 220.0f
#define ORDER_LABEL_HEIGHT 16.0f
#define ORDER_VALUE_X 240.0f
#define ORDER_VALUE_WIDTH 80.0f
#define ORDER_VALUE_HEIGHT 16.0f
#define ORDER_TOOLBAR_HEIGHT 44.0f

#define LOOKUP_SKU_X 2.0f
#define LOOKUP_SKU_Y 7.0f
#define LOOKUP_SKU_WIDTH 140.0f
#define LOOKUP_SKU_HEIGHT 30.0f
#define LOOKUP_SKU_FONT_SIZE 15.0f

@interface CartItemsViewController()
- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment;
- (void) calculateOrder;
@end

@implementation CartItemsViewController

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Items"];
	[self setTitle:@"Items"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];
	
    return self;
}

- (void)dealloc {
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
	UIView *cartView = [[UIView alloc] initWithFrame:[self rectForNav]];
	cartView.backgroundColor = [UIColor whiteColor];
	[self setView:cartView];
	[cartView release];
	
	// Where we are in the layout.
	CGFloat cy = 0.0f;
	
	custPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, CUST_LABEL_END_WIDTH, CUST_LABEL_HEIGHT)];
	custPhoneLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custPhoneLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:custPhoneLabel];
	[custPhoneLabel release];
	
	custNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CUST_LABEL_END_WIDTH, cy, CUST_LABEL_MIDDLE_WIDTH, CUST_LABEL_HEIGHT)];
	custNameLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custNameLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:custNameLabel];
	[custNameLabel release];

	custZipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CUST_LABEL_END_WIDTH +  CUST_LABEL_MIDDLE_WIDTH, cy, CUST_LABEL_END_WIDTH, CUST_LABEL_HEIGHT)];
	custZipLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custZipLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:custZipLabel];
	[custZipLabel release];
	
	cy += CUST_LABEL_HEIGHT;
	
	orderTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.frame.size.width, ORDER_TABLE_HEIGHT) style:UITableViewStylePlain];
	orderTable.backgroundColor = [UIColor clearColor];
	orderTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	orderTable.delegate = self;
	orderTable.dataSource = self;
	[self.view addSubview:orderTable];
	[orderTable release];
	
	cy += ORDER_TABLE_HEIGHT;
	
	subTotalLabel = [self createOrderLabel:@"Subtotal:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:UITextAlignmentRight];
	[self.view addSubview:subTotalLabel];
	[subTotalLabel release];
	
	subTotalValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_VALUE_X, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:UITextAlignmentLeft];
	[self.view addSubview:subTotalValue];
	[subTotalValue release];
	
	cy += ORDER_LABEL_HEIGHT;
	
	taxLabel = [self createOrderLabel:@"Tax:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:UITextAlignmentRight];
	[self.view addSubview:taxLabel];
	[taxLabel release];
	
	taxValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_VALUE_X, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:UITextAlignmentLeft];
	[self.view addSubview:taxValue];
	[taxValue release];
	
	cy += ORDER_LABEL_HEIGHT;
	
	totalLabel = [self createOrderLabel:@"Total:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:UITextAlignmentRight];
	[self.view addSubview:totalLabel];
	[totalLabel release];
	
	totalValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_VALUE_X, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:UITextAlignmentLeft];
	[self.view addSubview:totalValue];
	[totalValue release];
	
	cy += ORDER_LABEL_HEIGHT;
	
	// Create a toolbar for the bottom of the screen
	orderToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.frame.size.width, ORDER_TOOLBAR_HEIGHT)];
	orderToolBar.barStyle = UIBarStyleBlack;

	// Create a textfile to put in the bottom toolbar to do manual sku lookup.
	lookupSkuField = [[ExtUITextField alloc] initWithFrame:CGRectMake(LOOKUP_SKU_X, LOOKUP_SKU_Y, LOOKUP_SKU_WIDTH, LOOKUP_SKU_HEIGHT)];
	lookupSkuField.textColor = [UIColor blackColor];
	lookupSkuField.borderStyle = UITextBorderStyleRoundedRect;
	lookupSkuField.textAlignment = UITextAlignmentLeft;
	lookupSkuField.font = [UIFont systemFontOfSize:LOOKUP_SKU_FONT_SIZE];
	lookupSkuField.clearsOnBeginEditing = YES;
	lookupSkuField.placeholder = @"Look Up Item";
	lookupSkuField.tagName = @"LookupItem";
	lookupSkuField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	lookupSkuField.returnKeyType = UIReturnKeyGo;
	lookupSkuField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	[self addDoneToolbarForTextField:lookupSkuField];
	
	// Load and set the spyglass icon at the left side of the text field.
	UIImageView *spyGlassView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-magnify2.png"]];
	[lookupSkuField setLeftView:spyGlassView];
	[lookupSkuField setLeftViewMode:UITextFieldViewModeAlways];
	[spyGlassView release];
	
	// Add the textfield to the bottom toolbar as a custom view
	UIBarButtonItem *fieldItem = [[[UIBarButtonItem alloc] initWithCustomView:lookupSkuField] autorelease];
	[lookupSkuField release];
	UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *tbItems = [[[NSArray alloc] initWithObjects:fieldItem, tbFlex, nil] autorelease];
	[orderToolBar setItems:tbItems];
	[self.view addSubview:orderToolBar];
	[orderToolBar release];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
    
	self.delegate = self;
	lookupSkuField.delegate = self;
	
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
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Items" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
	
	Customer *cust = [facade currentCustomer];
	if (cust == nil) {
		custPhoneLabel.backgroundColor = NO_CUST_SELECTED_COLOR;
		custNameLabel.backgroundColor = NO_CUST_SELECTED_COLOR;
		custNameLabel.text = @"No Customer";
		custZipLabel.backgroundColor = NO_CUST_SELECTED_COLOR;
	} else {
		custPhoneLabel.backgroundColor = CUST_SELECTED_COLOR;
		custPhoneLabel.text = [NSString formatAsUSPhone:cust.phoneNumber];
		custNameLabel.backgroundColor = CUST_SELECTED_COLOR;
		custNameLabel.text = (cust.lastName == nil) ? cust.firstName : cust.lastName;
		custZipLabel.backgroundColor = CUST_SELECTED_COLOR;
		custZipLabel.text = cust.address.zipPostalCode;
	}
	
	[orderTable reloadData];
	
	// Do this last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
	NSIndexPath* selection = [orderTable indexPathForSelectedRow];
	if (selection) {
		[orderTable deselectRowAtIndexPath:selection animated:YES];
	}
	[self calculateOrder];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove this controller as a linea delegate
    [linea removeDelegate: self];

    // Do this at the end
	[super viewWillDisappear:animated];
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
#pragma mark Order Methods
- (void) calculateOrder {
	BOOL custTaxExempt = NO;
	// If the customer is not set yet, we will assume that they are not tax exempt
	if ([facade currentCustomer] != nil && [[facade currentCustomer] taxExempt] == YES) {
		custTaxExempt = YES;
	}
	
	Order *order = [facade currentOrder];
	if (order != nil) {
		NSArray *orderItems = [order getOrderItems];
		
		NSDecimalNumber *subTotal = [NSDecimalNumber zero];
		NSDecimalNumber *taxTotal = [NSDecimalNumber zero];
		for (OrderItem *item in orderItems) {
			NSDecimalNumber *lineTotal = [item.sellingPrice decimalNumberByMultiplyingBy:item.quantity];
			subTotal = [lineTotal decimalNumberByAdding:subTotal];
			// If the customer is tax exempt we won't bother with checking further or calculating the tax amount for the line item
			// If the customer is not tax exempt we also need to see if the line item itself is tax exempt or not.
			// Possible concern:  We are allocating a lot of autoreleased NSDecimalNumber objects here.  Performance issue?
			if (custTaxExempt == NO && item.item.taxExempt == NO) {
				NSDecimalNumber *lineTax = [[item.item.taxRate decimalNumberByMultiplyingBy:item.sellingPrice] decimalNumberByMultiplyingBy:item.quantity];
				taxTotal = [lineTax decimalNumberByAdding:taxTotal];
			}
		}
		
		subTotalValue.text = [NSString formatDecimalNumberAsMoney:subTotal];
		taxValue.text = [NSString formatDecimalNumberAsMoney:taxTotal];
		totalValue.text = [NSString formatDecimalNumberAsMoney:[subTotal decimalNumberByAdding:taxTotal]];
    }
}

#pragma mark -
#pragma mark UITableView delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([facade currentOrder] == nil) ? 0 : [[[facade currentOrder] getOrderItems] count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	OrderItem *orderItem = [[[facade currentOrder] getOrderItems] objectAtIndex:indexPath.row];
	NSString *orderCellIdentifier = [orderItem.item.sku stringValue];
	
	CartItemTableCell *cell = (CartItemTableCell *)[tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
	
	if (cell == nil) {
		cell = [[[CartItemTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier] autorelease];
	}
	cell.orderItem = orderItem;
	return cell;
}

- (void)tableView:(UITableView *)theTableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { 
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove the item from the order
		ProductItem *pi = [[[[facade currentOrder] getOrderItems] objectAtIndex:indexPath.row] item];
        [[facade currentOrder] removeItemFromOrder:pi];
        
        [theTableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self calculateOrder];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OrderItem *orderItem = [[[facade currentOrder] getOrderItems] objectAtIndex:indexPath.row];
	if (orderItem != nil) {
		CartItemDetailViewController *cartDetail = [[CartItemDetailViewController alloc] init];
		[cartDetail setOrderItem:orderItem];
		[[self navigationController] pushViewController:cartDetail animated:YES];
		[cartDetail release];
	}
}

#pragma mark -
#pragma mark ExtUIViewController delegate

- (void)extTextFieldFinishedEditing:(ExtUITextField *)textField {
	// Set the values and do the work here
	if ([textField.tagName isEqualToString:@"LookupItem"] && [textField.text length] > 0) {
		// Call the service and display the overlay view
		ProductItem *item = [facade lookupProductItem:textField.text];
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
	}
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

#pragma mark -
#pragma mark AddItemViewDelegate
- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	Order *order = [facade currentOrder];
	if (order == nil) {
		order = [[[Order alloc] init] autorelease];
		[facade setCurrentOrder:order];
	}
	if ([facade currentCustomer] != nil) {
		[order setCustomer:[facade currentCustomer]];
	}
	ProductItem *item = [addItemView productItem];
	[order addItemToOrder:item withQuantity:quantity];
	
	[addItemView removeFromSuperview];
	
	[self addKeyboardListeners];
	[linea addDelegate:self];
	
	[orderTable reloadData];
	
	[self calculateOrder];
    
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
	[self addKeyboardListeners];
	[linea addDelegate:self];
}

#pragma mark -
#pragma mark UILabel creation
- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment {
	UILabel *label;
	label = [[UILabel alloc] initWithFrame:rect];
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = alignment;
	label.font = [UIFont boldSystemFontOfSize:ORDER_LABEL_FONT_SIZE];
	return label;
}

@end
