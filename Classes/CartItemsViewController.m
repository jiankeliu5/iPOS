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
#import "ProfitMarginViewController.h"
#import "PriceAdjustViewController.h"
#import "iPOSAppDelegate.h"

#import "UIScreen+Helpers.h"

#define CUST_SELECTED_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define NO_CUST_SELECTED_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]

#define CUST_LABEL_HEIGHT 14.0f
#define CUST_LABEL_FONT_SIZE 12.0f

#define ORDER_TOOLBAR_HEIGHT 44.0f

#define ORDER_LABEL_FONT_SIZE 14.0f
#define ORDER_LABEL_HEIGHT 16.0f
#define ORDER_VALUE_WIDTH 80.0f
#define LABEL_SPACING 20.0f

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

- (void) layoutView: (UIInterfaceOrientation) orientation;

- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment;
- (void) calculateOrder;
- (void) sendOrderAsQuote:(id)sender;
- (void) enterEditMode:(id)sender;
- (void) cancelEditMode:(id)sender;
- (void) commitEdits:(id)sender;
- (void) addOrEditCustomer:(id)sender;
- (void) tenderOrder:(id)sender;

- (void) handleLogout:(id) sender;

- (void) searchforItem:(id)sender;
- (void) restoreDefaultToolbar;
- (void) updateSelectionCount;

- (void) showAddItemOverlay: (NSArray *) foundItems;
- (void) displayProfitMarginOverlay;

- (void)handleLookupOrder:(id)sender;
- (void) handleDiscountButton: (id) sender;
@end

@implementation CartItemsViewController

@synthesize toolbarBasic;
@synthesize toolbarWithQuoteAndOrder;
@synthesize toolbarEditMode;

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
	
	[self setCommitEditsButton:nil];
	[self setMarkCloseLabel:nil];
	[self setMarkDeleteLabel:nil];
	[self setEditHeaderView:nil];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView {
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
	
    // Add the customer info
	custPhoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	custPhoneLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custPhoneLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:custPhoneLabel];
	[custPhoneLabel release];
	
	custNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	custNameLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custNameLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:custNameLabel];
	[custNameLabel release];

	custZipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	custZipLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custZipLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:custZipLabel];
	[custZipLabel release];
	
	
    // Add the Order Items table
	orderTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	orderTable.backgroundColor = [UIColor clearColor];
	orderTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	orderTable.delegate = self;
	orderTable.dataSource = self;
	[self.view addSubview:orderTable];
	[orderTable release];
	
    // Add discount button
    discountButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [discountButton setupAsSmallBlackButton];
    discountButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [discountButton setTitle:@"Discount" forState:UIControlStateNormal];
    [discountButton addTarget:self action:@selector(handleDiscountButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:discountButton];
    [discountButton release];
    
    // Add the labels
	subTotalLabel = [self createOrderLabel:@"Subtotal:" withRect:CGRectZero andAlignment:UITextAlignmentRight];
	[self.view addSubview:subTotalLabel];
	
	subTotalValue = [self createOrderLabel:@"$0.00" withRect:CGRectZero andAlignment:UITextAlignmentLeft];
	[self.view addSubview:subTotalValue];
	
	taxLabel = [self createOrderLabel:@"Tax:" withRect:CGRectZero andAlignment:UITextAlignmentRight];
	[self.view addSubview:taxLabel];
	
	taxValue = [self createOrderLabel:@"$0.00" withRect:CGRectZero andAlignment:UITextAlignmentLeft];
	[self.view addSubview:taxValue];
	
	totalLabel = [self createOrderLabel:@"Total:" withRect:CGRectZero andAlignment:UITextAlignmentRight];
	[self.view addSubview:totalLabel];
	
	totalValue = [self createOrderLabel:@"$0.00" withRect:CGRectZero andAlignment:UITextAlignmentLeft];
	[self.view addSubview:totalValue];
	
	// Create a toolbar for the bottom of the screen
	orderToolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	orderToolBar.barStyle = UIBarStyleBlack;
	searchButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] 
																	style:UIBarButtonItemStylePlain 
																   target:self 
																   action:@selector(searchforItem:)] autorelease];
	
	UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	tbFixed.width = 10.0f;
	
	custButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"customer.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(addOrEditCustomer:)] autorelease];
    // The quote button is displayed when we have a customer and an order with at least one item.
	quoteButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"quotes-black.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(sendOrderAsQuote:)] autorelease];
    
    // The order button is displayed when we have a customer and an order with at least one item.
	orderButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Cash.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(tenderOrder:)] autorelease];
    
    marginButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stats.png"] 
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(calculateProfitMargin:)] autorelease];
    
    logoutButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop_hand.png"]
                                                     style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(handleLogout:)] autorelease];
    
    editButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"]
                                                     style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(enterEditMode:)] autorelease];
    
    cancelEditButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_cancel.png"]
                                                   style:UIBarButtonItemStylePlain 
                                                  target:self 
                                                  action:@selector(cancelEditMode:)] autorelease];
    
	// Basic toolbar
    self.toolbarBasic = [[[NSArray alloc] initWithObjects:searchButton, tbFixed, custButton, tbFlex, editButton, tbFixed, logoutButton, nil] autorelease];
	self.toolbarWithQuoteAndOrder = [[[NSArray alloc] initWithObjects:
                                      searchButton, 
                                      tbFixed, 
                                      custButton, 
                                      tbFlex,
                                      marginButton,
                                      tbFixed,
                                      quoteButton,
                                      tbFixed,
                                      orderButton,
                                      tbFixed,
                                      editButton,
                                      tbFixed,
                                      logoutButton,
                                      nil] autorelease];
	
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
	
	self.toolbarEditMode = [[[NSArray alloc] initWithObjects:tbFlex, customBarButton, tbFlex, cancelEditButton, nil] autorelease];
	
	// Start with the basic toolbar.
	[orderToolBar setItems:self.toolbarBasic];
	[self.view addSubview:orderToolBar];
	[orderToolBar release];
	
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
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
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
		// Be able to switch into the previous order navigation flow.
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Orders" 
                                                                                   style:UIBarButtonItemStyleBordered 
                                                                                  target:self 
                                                                                  action:@selector(handleLookupOrder:)] autorelease];
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
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {

    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
    
    CGRect custInfoRect = CGRectZero;
    CGRect orderTableRect = CGRectZero;
    CGRect subTotalRect = CGRectZero;
    CGRect taxRect = CGRectZero;
    CGRect totalRect = CGRectZero;
    CGRect toolbarRect = CGRectZero;
    
    CGRect custPhoneRect = CGRectZero;
    CGRect custNameRect = CGRectZero;
    CGRect custZipRect = CGRectZero;
    
    // Calculate the layout rects (rows and cols)
    CGRectDivide(viewBounds, &custInfoRect, &orderTableRect, CUST_LABEL_HEIGHT, CGRectMinYEdge);
    
    CGRectDivide(custInfoRect, &custPhoneRect, &custNameRect, custInfoRect.size.width * 0.3, CGRectMinXEdge);
    CGRectDivide(custNameRect, &custNameRect, &custZipRect, custNameRect.size.width * 0.5, CGRectMinXEdge);
    
    CGRectDivide(orderTableRect, &orderTableRect, &subTotalRect, orderTableRect.size.height - ORDER_LABEL_HEIGHT*3 - ORDER_TOOLBAR_HEIGHT, CGRectMinYEdge);
    CGRectDivide(subTotalRect, &subTotalRect, &taxRect, ORDER_LABEL_HEIGHT, CGRectMinYEdge);
    CGRectDivide(taxRect, &taxRect, &totalRect, ORDER_LABEL_HEIGHT, CGRectMinYEdge);
    CGRectDivide(totalRect, &totalRect, &toolbarRect, ORDER_LABEL_HEIGHT, CGRectMinYEdge);
    
    // Set the layout frames for customer, order table, totals, and toolbar
    custPhoneLabel.frame = custPhoneRect;
    custNameLabel.frame = custNameRect;
    custZipLabel.frame = custZipRect;
    
    orderTable.frame = orderTableRect;
    
    subTotalLabel.frame = CGRectMake(0, subTotalRect.origin.y, subTotalRect.size.width - LABEL_SPACING - ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	subTotalValue.frame = CGRectMake(subTotalRect.size.width - ORDER_VALUE_WIDTH, subTotalRect.origin.y, ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	taxLabel.frame = CGRectMake(0, taxRect.origin.y, taxRect.size.width - LABEL_SPACING - ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	taxValue.frame = CGRectMake(taxRect.size.width - ORDER_VALUE_WIDTH, taxRect.origin.y, ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	totalLabel.frame = CGRectMake(0, totalRect.origin.y, totalRect.size.width - LABEL_SPACING - ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	totalValue.frame = CGRectMake(totalRect.size.width - ORDER_VALUE_WIDTH, totalRect.origin.y, ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
    
    discountButton.frame = CGRectMake(20, subTotalRect.origin.y, 80, 26);
    
    orderToolBar.frame = toolbarRect;
    
    if (searchOverlay) {
        searchOverlay.frame = self.view.bounds;
    }
    
    // Layout add item overlay (adjusting frame triggers a layoutSubviews of add item overlay)
    if (addItemOverlay) {
        addItemOverlay.frame = viewBounds;
    }
}

#pragma mark -
#pragma mark Button Event Methods
- (void)handleLookupOrder:(id)sender {
    // Switch the order cart over to looking at existing orders rather than a new order.
    [orderCart setNewOrder:NO];
    iPOSAppDelegate *app = (iPOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *orderNav = [app orderNavigationController];
    [orderNav setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:orderNav animated:YES];
}

- (void) handleDiscountButton:(id)sender {
    PriceAdjustViewController *priceAdjust = [[[PriceAdjustViewController alloc] initWithOrder:[orderCart getOrder]] autorelease];
	[self.navigationController pushViewController:priceAdjust animated:YES];
}

#pragma mark -
#pragma mark Order Methods
- (void) calculateOrder {
	Order *order = [orderCart getOrder];
    
    if (order != nil) {
        NSDecimalNumber *subTotal = [order calcOrderSubTotal];
        NSDecimalNumber *taxTotal = [order calcOrderTax];
        NSDecimalNumber *total = [order calcOrderTotal];
        
        subTotalValue.text = [NSString formatDecimalNumberAsMoney:subTotal];
        taxValue.text = [NSString formatDecimalNumberAsMoney:taxTotal];
        totalValue.text = [NSString formatDecimalNumberAsMoney:total];
		
        [self restoreDefaultToolbar];    
        
        // Is the discount button enabled or not:
        if ([[order getOrderItems:LINE_ORDERSTATUS_OPEN] count] > 0) {
            discountButton.enabled = YES;
        } else {
            discountButton.enabled = NO;
        }
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
    CustomerViewController *custViewController = [[CustomerViewController alloc] init];
    [self.navigationController pushViewController:custViewController animated:YES];
    
    [custViewController release];
}

- (void) tenderOrder:(id)sender {
	TenderPaymentViewController *tenderViewController = [[[TenderPaymentViewController alloc] init] autorelease];
    UINavigationController *navController = self.navigationController;
		
    [navController pushViewController:tenderViewController animated:YES];
}


- (void)calculateProfitMargin:(id) sender{
    [self displayProfitMarginOverlay];
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
    UIAlertView *logoutAlert = [[UIAlertView alloc] init];
	logoutAlert.title = @"Cancel and Logout?";
	logoutAlert.message = @"This will cancel the order and return to the login screen.  Are you sure you wish to do this?";
	logoutAlert.delegate = self;
	[logoutAlert addButtonWithTitle:@"Cancel"];
	[logoutAlert addButtonWithTitle:@"Logout"];
	[logoutAlert show];
	[logoutAlert release];
}

- (void) enterEditMode:(id)sender {
	// Fire up the edit mode on the table.
	
	[orderToolBar setItems:self.toolbarEditMode];
	[self updateSelectionCount];
	[self setMultiEditMode:YES];
	[orderTable reloadData];
	 
}

- (void) cancelEditMode:(id)sender {
	// Clear the flags on the order items.
	for (OrderItem *orderItem in [[orderCart getOrder] getOrderItems]) {
		orderItem.shouldClose = NO;
		orderItem.shouldDelete = NO;
	}
	[self setMultiEditMode:NO];
	self.countMarkDelete = 0;
	self.countMarkClose = 0;
	[orderTable reloadData];
	[self restoreDefaultToolbar];
	
}

- (void) commitEdits:(id)sender {
	NSMutableArray *orderItemsToDelete = [NSMutableArray arrayWithCapacity:5];
	// Iterate over the items in the order first to see which ones need to be deleted and closed.
	// Must do this for delete because we cannot change the array while iterating over it.
    for (OrderItem *orderItem in [[orderCart getOrder] getOrderItems]) {
		if (orderItem.shouldDelete) {
			[orderItemsToDelete addObject:orderItem];
		}
		if (orderItem.shouldClose && [orderItem isClosed] == NO) {
			if (![orderCart closeItem:orderItem]) {
				[AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot close line for sku %@.  Stock not available.", orderItem.item.sku] withTitle:@"iPOS"];
			}
		} else if ([orderItem isClosed] && orderItem.shouldClose == NO) {
			[orderItem setStatusToOpen];
		}
	}

	for (OrderItem *item in orderItemsToDelete) {
		[orderCart removeItem:item];
	}
	[self setMultiEditMode:NO];
	self.countMarkDelete = 0;
	self.countMarkClose = 0;
	[orderTable reloadData];
	[self restoreDefaultToolbar];
	[self updateSelectionCount];
    
    // Recalculate order labels
    [self calculateOrder];
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
	
    // Send quote modal.
    if ([anAlertView.title isEqualToString:@"Send Quote?"]) {
		// Check by titles rather than index since documentation suggests that different 
		// devices can set the indexes differently.
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Send Quote"]) {
			Order *order = [orderCart getOrder];
            
            // Send off the order as a quote.
			if ([orderCart saveOrderAsQuote]) {
				// Go clear back to the login screen.
                [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Quote %@ was successfully created.", order.orderId] withTitle:@"iPOS"];
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
		}
	}

    // Cancel and logout modal.
    if ([anAlertView.title isEqualToString:@"Cancel and Logout?"]) {
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Logout"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
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
	
	OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatus] objectAtIndex:indexPath.row];
	NSString *orderCellIdentifier = orderItem.item.sku;
	
	CartItemTableCell *cell = (CartItemTableCell *)[tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
	
	if (cell == nil) {
		cell = [[[CartItemTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier] autorelease];
	}
	cell.orderItem = orderItem;
	cell.multiEditing = self.multiEditMode;
	cell.deleteChecked = orderItem.shouldDelete;
	cell.closeChecked = orderItem.shouldClose = [orderItem isClosed];
	cell.cellDelegate = self;
	
    cell.accessoryType = UITableViewCellAccessoryNone;

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
		OrderItem *item = [[[orderCart getOrder] getOrderItemsSortedByStatus] objectAtIndex:indexPath.row];
        [orderCart removeItem:item];
        
        [theTableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self calculateOrder];
    }
	
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatus] objectAtIndex:indexPath.row];
	if (orderItem != nil) {
		CartItemDetailViewController *cartDetail = [[CartItemDetailViewController alloc] init];
		[cartDetail setOrderItem:orderItem];
		[[self navigationController] pushViewController:cartDetail animated:YES];
		[cartDetail release];
	}
}

#pragma mark -
#pragma mark SearchItemView delegate
- (void) searchforItem:(id)sender {
	[linea removeDelegate:self];
	 
    searchOverlay = [[SearchItemView alloc] initWithFrame:self.view.bounds];
	[searchOverlay setDelegate:self];
	[self.view addSubview:searchOverlay];
	[searchOverlay release];
}

- (void) searchItem:(SearchItemView *)aSearchItemView withSku:(NSString *)aSku {
	
	[aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
    
    searchOverlay = nil;
	
	// Set the values and do the work here
	if (aSku && [aSku length] > 0) {
		ProductItem *item = [facade lookupProductItem:aSku];
        NSArray *foundItems = nil;
        
        if(item != nil && (![item.itemId isEqualToNumber:[NSNumber numberWithInt:0]] || ![item.sku isEqualToString:@""])) {
            foundItems = [NSArray arrayWithObject:item];
        }
        
        [self showAddItemOverlay:foundItems];        
	}
}

- (void) searchItem:(SearchItemView *)aSearchItemView withName: (NSString *) aName {
    [aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
    
    searchOverlay = nil;
	
	// Set the values and do the work here
	if (aName && [aName length] > 0) {
		NSArray *foundItems = [facade lookupProductItemByName:aName];
        
        // If one item is returned, load the details for the item
        if (foundItems && [foundItems count] == 1) {
            ProductItem *foundItem = [facade lookupProductItem:((ProductItem *) [foundItems objectAtIndex:0]).sku];
            foundItems = [NSArray arrayWithObjects:foundItem, nil];
        }

        [self showAddItemOverlay:foundItems];        
	}
}

- (void) cancelSearchItem:(SearchItemView *)aSearchItemView {
	[aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
    
    searchOverlay = nil;
}

#pragma mark -
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    ProductItem *item = [facade lookupProductItem:barcode];
    NSArray *foundItems = nil;
    
    if(item != nil && (![item.itemId isEqualToNumber:[NSNumber numberWithInt:0]] || ![item.sku isEqualToString:@""])) {
		foundItems = [NSArray arrayWithObject:item];
	}
    
    [self showAddItemOverlay:foundItems];
}

#pragma mark -
#pragma mark AddItemViewDelegate
- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	ProductItem *item = addItemView.itemToAdd;
	
    [orderCart addItem:item withQuantity:quantity];
    if ([orderCart getOrder].errorList && [[orderCart getOrder].errorList count] > 0) {
        [AlertUtils showModalAlertForErrors:[orderCart getOrder].errorList withTitle:@"iPOS"];
        return;
    }
	
	[addItemView removeFromSuperview];
    addItemOverlay = nil;
	
	[linea addDelegate:self];
	
	[orderTable reloadData];
    
    logoutButton.enabled = YES;
    
	[self calculateOrder];
    
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
    addItemOverlay = nil;
    
    logoutButton.enabled = YES;
    
	[linea addDelegate:self];
}

#pragma mark -
#pragma mark ProfitMarginViewDelegate Methods
-(void) exit:(id)sender
{
    NSLog(@"exiting profit margin view");
    [self dismissModalViewControllerAnimated:YES];
    
    
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
	return [label autorelease];
}

#pragma mark -
#pragma mark Show Add Item Overlay
- (void) showAddItemOverlay: (NSArray *) foundItems {
    if (foundItems && [foundItems count] > 0) {
        [linea removeDelegate:self];
        
        addItemOverlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
        [addItemOverlay setViewDelegate:self];
        
        [self.view addSubview:addItemOverlay];
        
        if ([foundItems count] == 1) {
            [addItemOverlay setItemToAdd:(ProductItem *) [foundItems objectAtIndex:0]];
        } else {
            [addItemOverlay setProductItemList:foundItems];
        }
        
        // Disable the suspend button
        logoutButton.enabled = NO;
        
        [addItemOverlay release];
    } else {
        [AlertUtils showModalAlertMessage:@"No item(s) found" withTitle:@"iPOS"];
    }
    
}

#pragma mark -
#pragma mark ProfitMargin Overlay
-(void)displayProfitMarginOverlay
{
    
    UILabel *textLabel = [[UILabel alloc ]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - 95, self.view.frame.size.width, 50.0f)];
    textLabel.textColor = [UIColor whiteColor];
    //textLabel.layer.cornerRadius = 5.0f;
    textLabel.text = [NSString stringWithFormat:@"PM %@", [[orderCart getOrder] calculateProfitMargin]];
    textLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    textLabel.textAlignment = UITextAlignmentCenter;
    
	[UIView beginAnimations: @"Fade Out" context:nil];
	
	// wait for time before begin
	[UIView setAnimationDelay:0.0];
	[self.view addSubview:textLabel];
    [textLabel release];
	// druation of animation
	[UIView setAnimationDuration:2.0];
	textLabel.alpha = 0.0;
	[UIView commitAnimations];
}


@end
