//
//  LTLWeightViewController.m
//  iPOS
//
//  Created by Enning Tang on 1/24/13.
//
//

#import "LTLWeightViewController.h"
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

#define CUST_LABEL_HEIGHT 0.0f
#define CUST_LABEL_FONT_SIZE 12.0f

#define ORDER_TOOLBAR_HEIGHT 0.0f//44.0f

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

@interface LTLWeightViewController()

- (void) layoutView: (UIInterfaceOrientation) orientation;

- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment;
- (void) calculateOrder;
- (void) sendOrderAsQuote:(id)sender;
- (void) enterEditMode:(id)sender;
- (void) commitEdits:(id)sender;
- (void) addOrEditCustomer:(id)sender;
- (void) tenderOrder:(id)sender;

- (void) handleLogout:(id) sender;

- (void) restoreDefaultToolbar;
- (void) updateSelectionCount;

- (void) displayProfitMarginOverlay;

- (void)handleLookupOrder:(id)sender;
- (void) handleDiscountButton: (id) sender;
@end

@implementation LTLWeightViewController

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
@synthesize totalLTLWeight;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"LTL Weight"];
	[self setTitle:@"LTL Weight"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
	facade = [iPOSFacade sharedInstance];
    orderCart = [OrderCart sharedInstance];
    totalLTLWeight = [[NSNumber alloc]initWithInt:0];
    
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
	
    // Add the Order Items table
	orderTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	orderTable.backgroundColor = [UIColor clearColor];
	orderTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	orderTable.delegate = self;
	orderTable.dataSource = self;
	[self.view addSubview:orderTable];
	[orderTable release];
    
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
    
    NSLog(@"CartItemsViewController viewWillAppear called");
    
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
	}
	//Enning Tang check for TaxExempt for customer 11/1/2012
        /*
         if (cust.taxExempt == TRUE)
         {
         NSLog(@"Add Items Check for TaxExempt called, set item taxrate to zero");
         for (OrderItem *item in [[orderCart getOrder] getOrderItems]) {
         item.item.taxRate = [NSDecimalNumber zero];
         }
         }*/
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
    
    CGRectDivide(orderTableRect, &orderTableRect, &subTotalRect, orderTableRect.size.height, CGRectMinYEdge);
    CGRectDivide(subTotalRect, &subTotalRect, &taxRect, ORDER_LABEL_HEIGHT, CGRectMinYEdge);
    CGRectDivide(taxRect, &taxRect, &totalRect, ORDER_LABEL_HEIGHT, CGRectMinYEdge);
    CGRectDivide(totalRect, &totalRect, &toolbarRect, ORDER_LABEL_HEIGHT, CGRectMinYEdge);
    
    orderTable.frame = orderTableRect;
    
    subTotalLabel.frame = CGRectMake(0, subTotalRect.origin.y, subTotalRect.size.width - LABEL_SPACING - ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	subTotalValue.frame = CGRectMake(subTotalRect.size.width - ORDER_VALUE_WIDTH, subTotalRect.origin.y, ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	taxLabel.frame = CGRectMake(0, taxRect.origin.y, taxRect.size.width - LABEL_SPACING - ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	taxValue.frame = CGRectMake(taxRect.size.width - ORDER_VALUE_WIDTH, taxRect.origin.y, ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	totalLabel.frame = CGRectMake(0, totalRect.origin.y, totalRect.size.width - LABEL_SPACING - ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
	totalValue.frame = CGRectMake(totalRect.size.width - ORDER_VALUE_WIDTH, totalRect.origin.y, ORDER_VALUE_WIDTH, ORDER_LABEL_HEIGHT);
    
    //Enning Tang Add totalWeight frame
    // Add total weight into view Enning Tang 2013/02/06
    /*
    totalWeight = [[UILabel alloc]initWithFrame:CGRectZero];
    totalWeight.backgroundColor = [UIColor clearColor];
	totalWeight.textColor = [UIColor blackColor];
	totalWeight.font = [UIFont boldSystemFontOfSize:ORDER_LABEL_FONT_SIZE];
    totalLabel.text = @"Weight is Approximately: lbs.";
    totalWeight.frame = CGRectMake(20, subTotalRect.origin.y, 80, 26);
    [self.view addSubview:totalLabel];*/
    
    /*
    totalWeight = [[UILabel alloc] initWithFrame:CGRectZero];
	totalWeight.backgroundColor = [UIColor whiteColor];
	totalWeight.textColor = [UIColor blackColor];
    totalWeight.font = [UIFont boldSystemFontOfSize:ORDER_LABEL_FONT_SIZE];
	totalWeight.text = [NSString stringWithFormat:@"Weight is Approximately: %@ lbs.", [totalLTLWeight stringValue]];
	totalWeight.textAlignment = NSTextAlignmentCenter;
    
    totalWeight.frame = CGRectMake(0.0f, 0.0f, ORDER_VALUE_WIDTH + 500, 40.0f);
    CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
    totalWeight.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing + 300.f);
    
	[self.view addSubview:totalWeight];
	[totalWeight release];
     
     */
    
    discountButton.frame = CGRectMake(20, subTotalRect.origin.y, 80, 26);
    
    orderToolBar.frame = toolbarRect;
    
    if (searchOverlay) {
        searchOverlay.frame = self.view.bounds;
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
    [self presentViewController:orderNav animated:YES completion:nil];
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
- (void) cartItemCell:(LTLTableCell *)aCartItemCell markForDelete:(BOOL)shouldDelete {
	NSInteger oldDeleteCount = self.countMarkDelete;
	self.countMarkDelete = (shouldDelete) ? ++oldDeleteCount : --oldDeleteCount;
	[self updateSelectionCount];
}

- (void) cartItemCell:(LTLTableCell *)aCartItemCell markForClose:(BOOL)shouldClose {
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
    
    NSLog(@"cellForRowAtIndexPath called");
	
    static NSString *orderCellIdentifier = @"NewOrderItemCell";
	OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatus] objectAtIndex:indexPath.row];
	
	LTLTableCell *cell = (LTLTableCell *)[tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (cell == nil) {
		cell = [[[LTLTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier] autorelease];
	}
    
    //Enning Tang: only display open items
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *itemQty = [formatter numberFromString:[orderItem getQuantityForDisplay]];
    [formatter release];
    orderItem.item.itemLTLWeight = [facade getLTLWeight:orderItem.item.itemId withQuantity:itemQty];
    NSLog(@"Item Status: %d", [orderItem.statusId intValue]);
    
    cell.cellDelegate = self;
	cell.orderItem = orderItem;
	cell.multiEditing = self.multiEditMode;
	
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Prevent didSelectRowAtIndexPath from being called in multi edit mode
    if (self.multiEditMode) {
        return nil;
    }
    
    OrderItem *orderItem = [[[orderCart getOrder] getOrderItemsSortedByStatusFilterCanceled] objectAtIndex:indexPath.row];
    // Prevent didSelectRowAtIndexPath from being called for cancelled, closed or returned line items
    if ([orderItem allowEdit] == NO) {
        return nil;
	}
    
    return indexPath;
}

//Enable multiple selection
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    //add your own code to set the cell accesory type.
    return UITableViewCellAccessoryNone;
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

@end

