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
#import "CartItemDetailViewController.h"
#import "CustomerViewController.h"
#import "TenderPaymentViewController.h"

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

#define COMMIT_EDIT_BUTTON_WIDTH 240.0f
#define COMMIT_EDIT_HEIGHT 22.0f
#define COMMIT_BUTTON_FONT_SIZE 14.0f

#define EDIT_HEADER_HEIGHT 22.0f
#define EDIT_HEADER_CLOSE_LABEL_WIDTH 30.0f
#define EDIT_HEADER_DELETE_LABEL_WIDTH 35.0f
#define EDIT_HEADER_LABEL_X 5.0f
#define EDIT_HEADER_FONT_SIZE 11.0f

@interface CartItemsViewController()
- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment;
- (void) calculateOrder;
- (void) sendOrderAsQuote:(id)sender;
- (void) enterEditMode:(id)sender;
- (void) cancelEditMode:(id)sender;
- (void) commitEdits:(id)sender;
- (void) addOrEditCustomer:(id)sender;
- (void) tenderOrder:(id)sender;

- (void) handleLogout:(id) sender;

- (CustomerViewController *)findCustomerViewController;

- (void) searchforSku:(id)sender;
- (void) restoreDefaultToolbar;
- (void) updateSelectionCount;
@end

@implementation CartItemsViewController

@synthesize toolbarBasic;
@synthesize toolbarWithQuoteAndOrder;
@synthesize toolbarEditMode;

@synthesize editBarButton;
@synthesize logoutBarButton;
@synthesize cancelBarButton;
@synthesize commitEditsButton;
@synthesize markDeleteLabel;
@synthesize markCloseLabel;
@synthesize editHeaderView;

@synthesize multiEditMode;
@synthesize countMarkDelete;
@synthesize countMarkClose;

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
	orderCart = [OrderCart sharedInstance];
	
    return self;
}

- (void)dealloc {
	[self setToolbarBasic:nil];
	[self setToolbarWithQuoteAndOrder:nil];
	[self setToolbarEditMode:nil];
	
	[self setEditBarButton:nil];
    [self setLogoutBarButton:nil];
	[self setCancelBarButton:nil];
	[self setCommitEditsButton:nil];
	[self setMarkCloseLabel:nil];
	[self setMarkDeleteLabel:nil];
	[self setEditHeaderView:nil];
	
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
	UIBarButtonItem *searchButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] 
																	style:UIBarButtonItemStylePlain 
																   target:self 
																   action:@selector(searchforSku:)] autorelease];
	
	UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	tbFixed.width = 10.0f;
	
	UIBarButtonItem *custButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"customer.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(addOrEditCustomer:)] autorelease];
    // The quote button is displayed when we have a customer and an order with at least one item.
	UIBarButtonItem *quoteButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"quotes-black.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(sendOrderAsQuote:)] autorelease];
    
    // The quote button is displayed when we have a customer and an order with at least one item.
	UIBarButtonItem *orderButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Cash.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(tenderOrder:)] autorelease];
                                                                    
	// Basic toolbar
    self.toolbarBasic = [[[NSArray alloc] initWithObjects:searchButton, tbFixed, custButton, tbFlex, nil] autorelease];
	self.toolbarWithQuoteAndOrder = [[[NSArray alloc] initWithObjects:searchButton, tbFixed, custButton, tbFixed, quoteButton, tbFlex, orderButton, nil] autorelease];
	
	// Edit mode toolbar
	UIView *customToolbarView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH, COMMIT_EDIT_HEIGHT)] autorelease];
	self.markDeleteLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH / 2.0f, COMMIT_EDIT_HEIGHT)] autorelease];
	self.markDeleteLabel.textAlignment = UITextAlignmentCenter;
	self.markDeleteLabel.textColor = [UIColor whiteColor];
	self.markDeleteLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"EditConfirmDelete.png"]];
	self.markDeleteLabel.font = [UIFont systemFontOfSize:COMMIT_BUTTON_FONT_SIZE];
	self.markDeleteLabel.text = @"Delete (0)";
	[customToolbarView addSubview:self.markDeleteLabel];

	self.markCloseLabel = [[[UILabel alloc] initWithFrame:CGRectMake(COMMIT_EDIT_BUTTON_WIDTH / 2.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH / 2.0f, COMMIT_EDIT_HEIGHT)] autorelease];
	self.markCloseLabel.textAlignment = UITextAlignmentCenter;
	self.markCloseLabel.textColor = [UIColor whiteColor];
	self.markCloseLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"EditConfirmClose.png"]];
	self.markCloseLabel.font = [UIFont systemFontOfSize:COMMIT_BUTTON_FONT_SIZE];
	self.markCloseLabel.text = @"Close (0)";
	[customToolbarView addSubview:self.markCloseLabel];
	
	self.commitEditsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.commitEditsButton.frame = CGRectMake(0.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH, COMMIT_EDIT_HEIGHT);
	[self.commitEditsButton addTarget:self action:@selector(commitEdits:) forControlEvents:UIControlEventTouchUpInside];
	[customToolbarView addSubview:self.commitEditsButton];
	
	UIBarButtonItem *customBarButton = [[[UIBarButtonItem alloc] initWithCustomView:customToolbarView] autorelease];
	
	self.toolbarEditMode = [[[NSArray alloc] initWithObjects:tbFlex, customBarButton, tbFlex, nil] autorelease];
	
	// Start with the basic toolbar.
	[orderToolBar setItems:self.toolbarBasic];
	[self.view addSubview:orderToolBar];
	[orderToolBar release];
	
	// Keep reference to these buttons as we have to switch them in and out when we enter or exit edit mode.
	// Button to put us into edit mode.
	self.editBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(enterEditMode:)] autorelease];
    self.logoutBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Suspend" style:UIBarButtonItemStyleBordered target:self action:@selector(handleLogout:)] autorelease];
	// Button to cancel edit mode.
	self.cancelBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditMode:)] autorelease];
	
	self.editHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, EDIT_HEADER_HEIGHT)] autorelease];
	UILabel *deleteLabel = [[[UILabel alloc] initWithFrame:CGRectMake(EDIT_HEADER_LABEL_X, 0.0f, EDIT_HEADER_DELETE_LABEL_WIDTH, EDIT_HEADER_HEIGHT)] autorelease];
	deleteLabel.backgroundColor = [UIColor whiteColor];
	deleteLabel.textColor = [UIColor blackColor];
	deleteLabel.textAlignment = UITextAlignmentCenter;
	deleteLabel.font = [UIFont boldSystemFontOfSize:EDIT_HEADER_FONT_SIZE];
	deleteLabel.text = @"Delete";
	[self.editHeaderView addSubview:deleteLabel];
	
	UILabel *closeLabel = [[[UILabel alloc] initWithFrame:CGRectMake((EDIT_HEADER_LABEL_X * 3.0f) + EDIT_HEADER_DELETE_LABEL_WIDTH, 0.0f, EDIT_HEADER_CLOSE_LABEL_WIDTH, EDIT_HEADER_HEIGHT)] autorelease];
	closeLabel.backgroundColor = [UIColor whiteColor];
	closeLabel.textColor = [UIColor blackColor];
	closeLabel.textAlignment = UITextAlignmentCenter;
	closeLabel.font = [UIFont boldSystemFontOfSize:EDIT_HEADER_FONT_SIZE];
	closeLabel.text = @"Close";
	[self.editHeaderView addSubview:closeLabel];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
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
   
	// Reset multi edit mode
	self.multiEditMode = NO;
	self.countMarkDelete = 0;
	self.countMarkClose = 0;
	
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		// This is what shows up on the back button in the *next* controller.
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Items" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
		// We're going to put up an edit button on the left and a logout button on the right.
		self.navigationItem.leftBarButtonItem = self.editBarButton;
        self.navigationItem.rightBarButtonItem = self.logoutBarButton;
	}
	
	Customer *cust = [orderCart getCustomerForOrder];
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
	Customer *customer = [orderCart getCustomerForOrder];
    
	// If the customer is not set yet, we will assume that they are not tax exempt
	if (customer != nil && [customer taxExempt] == YES) {
		custTaxExempt = YES;
	}
	
	Order *order = [orderCart getOrder];
    
    if (order != nil) {
        NSDecimalNumber *subTotal = [order calcOrderSubTotal];
        NSDecimalNumber *taxTotal = [order calcOrderTax];
        
        subTotalValue.text = [NSString formatDecimalNumberAsMoney:subTotal];
        taxValue.text = [NSString formatDecimalNumberAsMoney:taxTotal];
        totalValue.text = [NSString formatDecimalNumberAsMoney:[subTotal decimalNumberByAdding:taxTotal]];
		
        [self restoreDefaultToolbar];        
    }
}

- (void) restoreDefaultToolbar {
	// Put up the Tender or Quote button if we have a customer and an order with at least one item.
	if ([orderCart getCustomerForOrder] != nil && [[[orderCart getOrder] getOrderItems] count] > 0) {
		[orderToolBar setItems:self.toolbarWithQuoteAndOrder];
	} else {
		[orderToolBar setItems:self.toolbarBasic];
	}
}

- (void) addOrEditCustomer:(id)sender {
	CustomerViewController *custViewController = [self findCustomerViewController];
	if (custViewController == nil) {
		// Pop ourselves and push to the customer view controller.
		// When the customer is confirmed we get pushed back here.
		
		// Locally store the navigation controller since
		// self.navigationController will be nil once we are popped
		UINavigationController *navController = self.navigationController;
		
		// retain ourselves so that the controller will still exist once it's popped off
		[[self retain] autorelease];
		
		custViewController = [[[CustomerViewController alloc] init] autorelease];
		
		// Pop this controller and replace with another
		[navController popViewControllerAnimated:NO];
		[navController pushViewController:custViewController animated:YES];
	} else {
		// Go back to the customer controller, when we confirm we end up back at the cart.
		[self.navigationController popToViewController:custViewController animated:YES];
	}

}

- (void) tenderOrder:(id)sender {
	TenderPaymentViewController *tenderViewController = [[[TenderPaymentViewController alloc] init] autorelease];
    UINavigationController *navController = self.navigationController;
		
    [navController pushViewController:tenderViewController animated:YES];
}

- (CustomerViewController *)findCustomerViewController {
	if ([self navigationController] != nil) {
		NSArray *controllers = [[self navigationController] viewControllers];
		for (UIViewController *vc in controllers) {
			if ([vc title] != nil && [[vc title] isEqualToString:@"Customer"] && [vc isKindOfClass:[CustomerViewController class]]) {
				return (CustomerViewController*)vc;
			}
		}
	}
	return nil;
}

- (void) sendOrderAsQuote:(id)sender {
	UIAlertView *quoteAlert = [[UIAlertView alloc] init];
	quoteAlert.title = @"Send Quote?";
	quoteAlert.message = @"This will send the order as a quote and return to the login screen.  Are you sure you wish to do this?";
	quoteAlert.delegate = self;
	[quoteAlert addButtonWithTitle:@"Cancel"];
	[quoteAlert addButtonWithTitle:@"Send Quote"];
	[quoteAlert show];
	[quoteAlert release];
}

- (void) handleLogout: (id) sender {
    // Cancel the order and completely Logoff
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) enterEditMode:(id)sender {
	//[AlertUtils showModalAlertMessage:@"Edit functionality is not implemented yet.  Please use swipe to delete rows."];
	// Fire up the edit mode on the table.
	
	[orderToolBar setItems:self.toolbarEditMode];
	[self.navigationItem setLeftBarButtonItem:self.cancelBarButton animated:NO];
	[self updateSelectionCount];
	[self setMultiEditMode:YES];
	[orderTable reloadData];
	 
}

- (void) cancelEditMode:(id)sender {
	// Clear the flags on the order items.
	// TODO: this should go into the Order or a Cart class
	for (OrderItem *orderItem in [[orderCart getOrder] getOrderItems]) {
		orderItem.shouldClose = NO;
		orderItem.shouldDelete = NO;
	}
	[self setMultiEditMode:NO];
	self.countMarkDelete = 0;
	self.countMarkClose = 0;
	[orderTable reloadData];
	[self restoreDefaultToolbar];
	[self.navigationItem setLeftBarButtonItem:self.editBarButton animated:NO];
	
}

- (void) commitEdits:(id)sender {
	NSMutableArray *orderItemsToDelete = [NSMutableArray arrayWithCapacity:5];
	// Iterate over the items in the order first to see which ones need to be deleted and closed.
	// Must do this for delete because we cannot change the array while iterating over it.
	// TODO: what do we need to close the line?  OrderItem?
	for (OrderItem *orderItem in [[orderCart getOrder] getOrderItems]) {
		if (orderItem.shouldDelete) {
			[orderItemsToDelete addObject:orderItem];
		}
		if (orderItem.shouldClose && [orderItem isClosed] == NO) {
			if (![orderCart closeItem:orderItem]) {
				[AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot close line for sku %@.  Stock not available.", orderItem.item.sku]];
			}
		} else if ([orderItem isClosed] && orderItem.shouldClose == NO) {
			[orderItem setStatusToOpen];
		}
	}
	
	// TODO: need a bulk way to delete multiple order items from the order at one time??
	for (OrderItem *item in orderItemsToDelete) {
		[orderCart removeItem:item];
	}
	[self setMultiEditMode:NO];
	self.countMarkDelete = 0;
	self.countMarkClose = 0;
	[orderTable reloadData];
	[self restoreDefaultToolbar];
	[self updateSelectionCount];
	[self.navigationItem setLeftBarButtonItem:self.editBarButton animated:NO];
}

- (void) updateSelectionCount {
	self.markDeleteLabel.text = [NSString stringWithFormat:@"Delete (%d)", self.countMarkDelete];
	self.markCloseLabel.text = [NSString stringWithFormat:@"Close (%d)", self.countMarkClose];
}

#pragma mark -
#pragma mark CartItemCellDelegate
- (void) cartItemCell:(CartItemTableCell *)aCartItemCell markForDelete:(BOOL)shouldDelete {
	NSInteger oldDeleteCount = self.countMarkDelete;
	self.countMarkDelete = (shouldDelete) ? ++oldDeleteCount : --oldDeleteCount;
	[self updateSelectionCount];
}

- (void) cartItemCell:(CartItemTableCell *)aCartItemCell markForClose:(BOOL)shouldClose {
	NSInteger oldCloseCount = self.countMarkClose;
	self.countMarkClose = (shouldClose) ? ++oldCloseCount : --oldCloseCount;
	[self updateSelectionCount];
}

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex {
	if ([anAlertView.title isEqualToString:@"Send Quote?"]) {
		// Check by titles rather than index since documentation suggests that different 
		// devices can set the indexes differently.
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Send Quote"]) {
			Order *order = [orderCart getOrder];
            
			// Send off the order as a quote.
			[facade newQuote:order];
			if (order.errorList != nil && [order.errorList count] > 0) {
                [AlertUtils showModalAlertForErrors:order.errorList];
			} else {
				// Go clear back to the login screen.
                [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Quote %@ was successfully created.", order.orderId]];
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
		}
	}
	// Other generic alerts will just fall through and dismiss with no other actions.
}


#pragma mark -
#pragma mark UITableView delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([orderCart getOrder] == nil) ? 0 : [[[orderCart getOrder] getOrderItems] count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (self.multiEditMode && section == 0) {
		return self.editHeaderView;
	}
	return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (self.multiEditMode && section == 0) {
		return EDIT_HEADER_HEIGHT;
	}
	return 0.0f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	OrderItem *orderItem = [[[orderCart getOrder] getOrderItems] objectAtIndex:indexPath.row];
	NSString *orderCellIdentifier = [orderItem.item.sku stringValue];
	
	CartItemTableCell *cell = (CartItemTableCell *)[tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
	
	if (cell == nil) {
		cell = [[[CartItemTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier] autorelease];
	}
	cell.orderItem = orderItem;
	cell.multiEditing = self.multiEditMode;
	cell.deleteChecked = orderItem.shouldDelete;
	cell.closeChecked = orderItem.shouldClose = [orderItem isClosed];
	cell.cellDelegate = self;
	if (self.multiEditMode == NO) {
		cell.accessoryType = ([orderItem isClosed]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	return cell;
}

/*
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}
*/

- (void)tableView:(UITableView *)theTableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { 
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove the item from the order
		OrderItem *item = [[[orderCart getOrder] getOrderItems] objectAtIndex:indexPath.row];
        [orderCart removeItem:item];
        
        [theTableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self calculateOrder];
    }
	
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OrderItem *orderItem = [[[orderCart getOrder] getOrderItems] objectAtIndex:indexPath.row];
	if (orderItem != nil) {
		CartItemDetailViewController *cartDetail = [[CartItemDetailViewController alloc] init];
		[cartDetail setOrderItem:orderItem];
		[[self navigationController] pushViewController:cartDetail animated:YES];
		[cartDetail release];
	}
}

#pragma mark -
#pragma mark SearchItemView delegate
- (void) searchforSku:(id)sender {
	[linea removeDelegate:self];
	SearchItemView *searchOverlay = [[SearchItemView alloc] initWithFrame:self.view.bounds];
	[searchOverlay setDelegate:self];
	[self.view addSubview:searchOverlay];
	[searchOverlay release];
}

- (void) searchItem:(SearchItemView *)aSearchItemView withSku:(NSString *)aSku {
	
	NSString *s = [NSString stringWithString:aSku];
	[aSearchItemView removeFromSuperview];
	
	[linea addDelegate:self];
	
	// Set the values and do the work here
	if ([s length] > 0) {
		// Call the service and display the overlay view
		ProductItem *item = [facade lookupProductItem:s];
		// TODO: Do we have to check inside ProductItem because of the test service at OPI?
		if(item != nil && [item.sku isEqualToNumber:[NSNumber numberWithInt:0]] == NO) {
			[linea removeDelegate:self];
			AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
			[overlay setViewDelegate:self];
			[self.view addSubview:overlay];
			[overlay setProductItem:item];
			[overlay release];
		} else {
			[AlertUtils showModalAlertMessage: @"Item not found"];
		}

	}
}

- (void) cancelSearchItem:(SearchItemView *)aSearchItemView {
	[aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
}

#pragma mark -
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    ProductItem *item = [facade lookupProductItem:barcode];
    
    if(item != nil && [item.sku isEqualToNumber:[NSNumber numberWithInt:0]] == NO) {
		[linea removeDelegate:self];
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
#pragma mark AddItemViewDelegate
- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	ProductItem *item = [addItemView productItem];
	
    [orderCart addItem:item withQuantity:quantity];
    if ([orderCart getOrder].errorList && [[orderCart getOrder].errorList count] > 0) {
        [AlertUtils showModalAlertForErrors:[orderCart getOrder].errorList];
        return;
    }
	
	[addItemView removeFromSuperview];
	
	[linea addDelegate:self];
	
	[orderTable reloadData];
    
	[self calculateOrder];
    
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
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
