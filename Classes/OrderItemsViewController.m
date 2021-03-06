//
//  OrderItemsViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "OrderItemsViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIScreen+Helpers.h"

#import "NSString+StringFormatters.h"
#import "AlertUtils.h"
#import "LayoutUtils.h"
#import "Customer.h"
#import	"Order.h"
#import "OrderItem.h"
#import "ProductItem.h"
#import "CartItemDetailViewController.h"
#import "TenderPaymentViewController.h"
#import "ProfitMarginViewController.h"
#import "RefundViewController.h"
#import "PriceAdjustViewController.h"

#import "iPOSAppDelegate.h"

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

@interface OrderItemsViewController()

- (void) layoutView: (UIInterfaceOrientation) orientation;

- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment;
- (void) calculateOrder;
- (void) sendOrderAsQuote:(id)sender;
- (void) enterEditMode:(id)sender;
- (void) cancelEditMode:(id)sender;
- (void) commitEdits:(id)sender;
- (void) tenderOrder:(id)sender;
- (void) cancelOrder:(id) sender;

- (void) previousOrderChangeAlert;

- (void) searchforItem:(id)sender;
- (void) restoreDefaultToolbar;
- (void) enableToolbarItems;
- (void) updateSelectionCount;

- (void) showAddItemOverlay: (NSArray *) foundItems;
- (void) displayProfitMarginOverlay;

- (void) handleCloseLookupOrder:(id)sender;
- (void) handleDiscountButton:(id)sender;
- (void) showLTLWeight:(id)sender;
@end

@implementation OrderItemsViewController

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
	// this view controller is added to a UINavigationController.  These 
    // are defaults, values are set from the order we are currently working
    // on when the view appears.
	[[self navigationItem] setTitle:@"Order Item"];
    
	[self setTitle:@"Order Item"];
    
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
	
	// Where we are in the layout.
	CGFloat cy = 0.0f;
	
	custPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, CUST_LABEL_END_WIDTH, CUST_LABEL_HEIGHT)];
	custPhoneLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custPhoneLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:custPhoneLabel];
	[custPhoneLabel release];
	
	custNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CUST_LABEL_END_WIDTH, cy, CUST_LABEL_MIDDLE_WIDTH, CUST_LABEL_HEIGHT)];
	custNameLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custNameLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:custNameLabel];
	[custNameLabel release];

	custZipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CUST_LABEL_END_WIDTH +  CUST_LABEL_MIDDLE_WIDTH, cy, CUST_LABEL_END_WIDTH, CUST_LABEL_HEIGHT)];
	custZipLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custZipLabel.textAlignment = NSTextAlignmentCenter;
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
    
    // Add discount button
    discountButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [discountButton setupAsSmallBlackButton];
    discountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [discountButton setTitle:@"Discount" forState:UIControlStateNormal];
    [discountButton addTarget:self action:@selector(handleDiscountButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:discountButton];
    [discountButton release];
	
	subTotalLabel = [self createOrderLabel:@"Subtotal:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:NSTextAlignmentRight];
	[self.view addSubview:subTotalLabel];
	
	subTotalValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_VALUE_X, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:NSTextAlignmentLeft];
	[self.view addSubview:subTotalValue];
	
	cy += ORDER_LABEL_HEIGHT;
	
	taxLabel = [self createOrderLabel:@"Tax:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:NSTextAlignmentRight];
	[self.view addSubview:taxLabel];
	
	taxValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_VALUE_X, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:NSTextAlignmentLeft];
	[self.view addSubview:taxValue];
	
	cy += ORDER_LABEL_HEIGHT;
	
	totalLabel = [self createOrderLabel:@"Total:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:NSTextAlignmentRight];
	[self.view addSubview:totalLabel];
	
	totalValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_VALUE_X, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:NSTextAlignmentLeft];
	[self.view addSubview:totalValue];
	
	cy += ORDER_LABEL_HEIGHT;
	
	// Create a toolbar for the bottom of the screen
	orderToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.frame.size.width, ORDER_TOOLBAR_HEIGHT)];
	orderToolBar.barStyle = UIBarStyleBlack;
	searchButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] 
																	style:UIBarButtonItemStylePlain 
																   target:self 
																   action:@selector(searchforItem:)] autorelease];
	
	UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	tbFixed.width = 10.0f;
	
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
    
    cancelOrderButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop_hand.png"]
                                                     style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(cancelOrder:)] autorelease];
    
    editButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"]
                                                     style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(enterEditMode:)] autorelease];
    
    cancelEditButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_cancel.png"]
                                                   style:UIBarButtonItemStylePlain 
                                                  target:self 
                                                  action:@selector(cancelEditMode:)] autorelease];
    
    //Enning Tang Add LTL Button 2013/2/8
    LTLButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scale.png"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(showLTLWeight:)] autorelease];
    
	// Basic toolbar
    self.toolbarBasic = [[[NSArray alloc] initWithObjects:searchButton, tbFlex, editButton, tbFixed, cancelOrderButton, nil] autorelease];
	self.toolbarWithQuoteAndOrder = [[[NSArray alloc] initWithObjects:
                                      searchButton,  
                                      tbFixed,
                                      LTLButton,
                                      tbFixed,
                                      marginButton,
                                      tbFixed,
                                      quoteButton,
                                      tbFixed,
                                      orderButton,
                                      tbFixed,
                                      editButton,
                                      tbFixed,
                                      cancelOrderButton,
                                      nil] autorelease];
	
	// Edit mode toolbar
	UIView *customToolbarView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH, COMMIT_EDIT_HEIGHT)] autorelease];
	self.markDeleteLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH / 2.0f, COMMIT_EDIT_HEIGHT)] autorelease];
	self.markDeleteLabel.textAlignment = NSTextAlignmentCenter;
	self.markDeleteLabel.textColor = [UIColor whiteColor];
	self.markDeleteLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"EditConfirmDelete.png"]];
	self.markDeleteLabel.font = [UIFont systemFontOfSize:COMMIT_BUTTON_FONT_SIZE];
	self.markDeleteLabel.text = @"Delete/Cancel (0)";
	[customToolbarView addSubview:self.markDeleteLabel];

	self.markCloseLabel = [[[UILabel alloc] initWithFrame:CGRectMake(COMMIT_EDIT_BUTTON_WIDTH / 2.0f, 0.0f, COMMIT_EDIT_BUTTON_WIDTH / 2.0f, COMMIT_EDIT_HEIGHT)] autorelease];
	self.markCloseLabel.textAlignment = NSTextAlignmentCenter;
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
	deleteLabel.textAlignment = NSTextAlignmentCenter;
	deleteLabel.font = [UIFont boldSystemFontOfSize:EDIT_HEADER_FONT_SIZE];
	deleteLabel.text = @"Delete";
	[self.editHeaderView addSubview:deleteLabel];
	
	UILabel *closeLabel = [[[UILabel alloc] initWithFrame:CGRectMake((EDIT_HEADER_LABEL_X * 3.0f) + EDIT_HEADER_DELETE_LABEL_WIDTH, 0.0f, EDIT_HEADER_CLOSE_LABEL_WIDTH, EDIT_HEADER_HEIGHT)] autorelease];
	closeLabel.backgroundColor = [UIColor whiteColor];
	closeLabel.textColor = [UIColor blackColor];
	closeLabel.textAlignment = NSTextAlignmentCenter;
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
    
    Order *order = [orderCart getOrder];
	NSString *controllerTitle = (order != nil && order.orderId != nil) ? [order.orderId stringValue] : @"Order Item";
    
    [self enableToolbarItems];
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		// This is what shows up on the back button in the *next* controller.
		//self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:controllerTitle style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        [[self navigationItem] setTitle:controllerTitle];
        [self setTitle:controllerTitle];
        
        // Set up the close button to go back the new order navigation controller
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New Order"
                                                                                   style:UIBarButtonItemStyleBordered
                                                                                  target:self
                                                                                  action:@selector(handleCloseLookupOrder:)] autorelease];

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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
- (void) layoutView:(UIInterfaceOrientation)orientation {
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
- (void)handleCloseLookupOrder:(id)sender {
    // Switch the order cart back to working with a new order.
    [orderCart setNewOrder:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    Order *order = [orderCart getOrder];
    
	// Put up the Tender or Quote button if we have a customer and an order with at least one item.
	if (![order isNewOrder] 
        || ([orderCart getCustomerForOrder] != nil && [[[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled] count] > 0)) {
		[orderToolBar setItems:self.toolbarWithQuoteAndOrder];
	} else {
		[orderToolBar setItems:self.toolbarBasic];
	}
    
    [self enableToolbarItems];
}

- (void) enableToolbarItems {
    Order *order = [orderCart getOrder];
    
    editButton.enabled = YES;
    searchButton.enabled = YES;
    quoteButton.enabled = YES;
    orderButton.enabled = YES;
    marginButton.enabled = YES;
    
    // Cannot edit an order if it is returned or closed status.
    // This means no adding items, quoting, or tendering either.
    if ([order canEditDetails] == NO) {
        editButton.enabled = NO;
        searchButton.enabled = NO;
        quoteButton.enabled = NO;
        orderButton.enabled = NO;
        marginButton.enabled = NO;
    }  
    
    if ([order canCancel] == NO) {
        cancelOrderButton.enabled = NO;
    }  
    
    // Cannot change an order to a quote
    if (![order isQuote]) {
        quoteButton.enabled = NO;
    }
}

- (void) tenderOrder:(id)sender {
    Order *order = [orderCart getOrder];
    
    // Let us get existing payments for the order
    NSArray *payments = [facade getPaymentHistoryForOrderid:order.orderId];
    
    NSLog(@"Found %u payments for order Id '%@'", [payments count], order.orderId);
    
    order.previousPayments = [NSMutableArray arrayWithArray: payments];
    
    // decision point to decide if we need to do a refund, make a payment, or just save changes to the order
    TenderDecision decision = [order isRefundEligble];
    
    if (decision == REFUND) {
        //go to refund screen
        RefundViewController *refundViewController = [[[RefundViewController alloc] init] autorelease];
        UINavigationController *navController = self.navigationController;
		
        [navController pushViewController:refundViewController animated:YES];
    }
    else if (decision == TENDER) {
        //go to the tender screen
        TenderPaymentViewController *tenderViewController = [[[TenderPaymentViewController alloc] init] autorelease];
        UINavigationController *navController = self.navigationController;
		
        [navController pushViewController:tenderViewController animated:YES];
    }
    else {
        //display prompt and exit
        [self previousOrderChangeAlert];
    }
}

- (void) previousOrderChangeAlert{
    
    UIAlertView *quoteAlert = [[UIAlertView alloc] init];
	quoteAlert.title = @"Save Order?";
	quoteAlert.message = [NSString stringWithFormat: @"No tender required.  Save changes to order #%@?", [orderCart getOrder].orderId];
	quoteAlert.delegate = self;
    [quoteAlert addButtonWithTitle:@"Cancel"];
	[quoteAlert addButtonWithTitle:@"Save"];
	[quoteAlert show];
	[quoteAlert release];
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

- (void) cancelOrder:(id)sender {
    UIAlertView *logoutAlert = [[UIAlertView alloc] init];
	logoutAlert.title = @"Cancel Order?";
	logoutAlert.message = @"This will cancel all items in the order.  Are you sure you wish to do this?";
	logoutAlert.delegate = self;
	[logoutAlert addButtonWithTitle:@"No"];
	[logoutAlert addButtonWithTitle:@"Yes"];
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
	for (OrderItem *orderItem in [[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled]) {
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
    for (OrderItem *orderItem in [[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled]) {
        if ([orderItem allowEdit]) {
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
	}

	for (OrderItem *item in orderItemsToDelete) {
        if (item.isNew) {
            [orderCart removeItem:item];
        } else {
            [item setStatusToCancel];
        }
		
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
	self.markDeleteLabel.text = [NSString stringWithFormat:@"Delete/Cancel (%d)", self.countMarkDelete];
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
    if ([anAlertView.title isEqualToString:@"Cancel Order?"]) {
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Yes"]) {
            Order *order = [orderCart getOrder];
            [order cancelOrder];
            
            [orderTable reloadData];
            
            [self calculateOrder];
            
		}
	}
    
    // No order changes.
    if ([anAlertView.title isEqualToString:@"Save Order?"]) {
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Save"]) {
            
            Order *order = [orderCart getOrder];
            
            if ([orderCart saveOrder]) {
                // Go clear back to the login screen.
                [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Order %@ was successfully saved.", order.orderId] withTitle:@"iPOS"];
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
    
    int count=0;
    NSArray *items = [[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled];
    
    if (items && [items count] > 0) {
        // Filter canceled items
        for (OrderItem *item in items) {
            if (![item isCanceled]) {
                count++;
            }
        }
    }
    
    
	return count;
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
	
    static NSString *orderCellIdentifier = @"PreviousOrderItemCell";
    Order *order = [orderCart getOrder];
	OrderItem *orderItem = [[order getOrderItemsSortedByStatusFilterCanceled] objectAtIndex:indexPath.row];
	
	CartItemTableCell *cell = (CartItemTableCell *)[tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
	
	if (cell == nil) {
		cell = [[[CartItemTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier] autorelease];
	} 
    
    cell.cellDelegate = self;
	cell.orderItem = orderItem;
	
    if ([order canEditDetails] == NO) {
        cell.multiEditing = NO;
        cell.deleteChecked = NO;
        cell.closeChecked = NO;
        cell.disabledLook = YES;
    } else {
        if ([orderItem allowEdit]) {
            cell.multiEditing = self.multiEditMode;
            cell.disabledLook = NO;
        } else {
            cell.multiEditing = NO;
            cell.disabledLook = YES;
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	return cell;
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    Order *order = [orderCart getOrder];
    
    // Disable swipe delete for items in closed or returned orders
    if ([order canEditDetails] == NO) {
        return UITableViewCellEditingStyleNone;
    }

    OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled] objectAtIndex:indexPath.row];
    // Prevent swipe delete for cancelled, closed or returned line items
    if ([orderItem allowEdit] == NO) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)theTableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { 
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove the item from the order
		OrderItem *item = [[[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled] objectAtIndex:indexPath.row];
        [orderCart removeItem:item];
        
        [theTableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self calculateOrder];
    }
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Order *order = [orderCart getOrder];
    // Prevent didSelectRowAtIndexPath from being called for any order item on a closed or returned order.
    if ([order canEditDetails] == NO || self.multiEditMode) {
        return nil;
    }
    
    OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled] objectAtIndex:indexPath.row];
    // Prevent didSelectRowAtIndexPath from being called for cancelled, closed or returned line items
    if ([orderItem allowEdit] == NO) {
        return nil;
	}
    
    return indexPath;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled] objectAtIndex:indexPath.row];
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
	
    NSLog(@"OrderItemsViewController: searchItem called");
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
    
    Order *order = [orderCart getOrder];
    if ([order canCancel]) {
        cancelOrderButton.enabled = YES;
    }
    
	[self calculateOrder];
    
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
    addItemOverlay = nil;
    
    Order *order = [orderCart getOrder];
    if ([order canCancel]) {
        cancelOrderButton.enabled = YES;
    }
    
	[linea addDelegate:self];
}

#pragma mark -
#pragma mark ProfitMarginViewDelegate Methods
-(void) exit:(id)sender
{
    NSLog(@"exiting profit margin view");
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
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
        cancelOrderButton.enabled = NO;
        
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
    textLabel.textAlignment = NSTextAlignmentCenter;
    
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

-(void) showLTLWeight:(id)sender
{
    Order *order = [orderCart getOrder];
    UIAlertView *longPress = [[UIAlertView alloc] init];
    longPress.title = @"LTL Weight";
    longPress.message = [NSString stringWithFormat:@"Open Items weight is approximately %@ lbs.", [[order calcOpenItemsWeight] stringValue]];
    [longPress addButtonWithTitle:@"OK"];
    [longPress show];
    [longPress release];
}




@end
