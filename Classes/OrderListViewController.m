//
//  OrderListViewController.m
//  iPOS
//
//  Created by Steven McCoole on 10/6/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "OrderListViewController.h"
#import "PreviousOrder.h"
#import "NSString+StringFormatters.h"
#import "OrderListTableCell.h"
#import "AlertUtils.h"
#import "CartItemsViewController.h"

@interface OrderListViewController()
- (void)layoutView;
- (void)handleClose:(id)sender;
@end

@implementation OrderListViewController

@synthesize searchPhone;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Order List"];
	[self setTitle:@"Order List"];
    
	facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
    
    return self;
}

- (void)dealloc
{
    if (searchPhone != nil) {
        [searchPhone release];
        searchPhone = nil;
    }
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView {
	return (UIView *)[self view];
}

#pragma mark -
#pragma mark UIViewController overrides

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation) || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView];
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
    
    orderListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    orderListTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:orderListTableView];
    [orderListTableView release];
    
    closeBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(handleClose:)] autorelease];
    [[self navigationItem] setRightBarButtonItem:closeBarButton];
}

- (void)layoutView {
    CGRect viewBounds = self.view.bounds;
    // orderListTableView.frame = CGRectInset(viewBounds, 10.0f, 10.0f);
    orderListTableView.frame = viewBounds;
    [orderListTableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
    
    orderListTableView.delegate = self;
    orderListTableView.dataSource = self;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Order List" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
    [self layoutView];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	// Do this at the end
	[super viewDidDisappear:animated];
}

- (void)handleClose:(id)sender {
    // Switch the order cart back to working with a new order;
    [orderCart setNewOrder:YES];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((orderCart.previousOrderList == nil) ? 0 : [orderCart.previousOrderList count]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section
{
	return [NSString stringWithFormat:@"Orders for: %@", (searchPhone == nil) ? @"unset" : searchPhone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *orderListTableIdentifier = @"OrderListTableIdentifier";
	OrderListTableCell *cell = (OrderListTableCell *)[tableView dequeueReusableCellWithIdentifier:orderListTableIdentifier];
	
	NSInteger row = indexPath.row;
    PreviousOrder *pOrder = (PreviousOrder *)[orderCart.previousOrderList objectAtIndex:row];
    
	if (cell == nil) {
		cell = [[[OrderListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderListTableIdentifier] autorelease];
    }
    cell.previousOrder = pOrder;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [orderListTableView deselectRowAtIndexPath:indexPath animated:YES];
	PreviousOrder *pOrder = (PreviousOrder *)[orderCart.previousOrderList objectAtIndex:indexPath.row];
	if (pOrder != nil) {
        NSLog(@"Selected Order Number: %@ to edit.", [NSString formatNumber:pOrder.orderId toScale:0]);
        Order *order = [facade lookupOrderByOrderId:pOrder.orderId];
        if (order != nil) {
            [orderCart setPreviousOrder:order];
            CartItemsViewController *cartItemViewController = [[CartItemsViewController alloc] init];
            [cartItemViewController setNewOrderMode:NO];
            [[self navigationController] pushViewController:cartItemViewController animated:TRUE];
            [cartItemViewController release];
        } else {
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Could not retrieve previous order.  Order Id: %@", pOrder.orderId]];
        }
	}
}

@end