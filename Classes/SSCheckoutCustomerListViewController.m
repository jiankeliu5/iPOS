//
//  SSCheckoutCustomerListViewController.m
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "SSCheckoutCustomerListViewController.h"
#import "CustomerListTableCell.h"

#import "SSCheckoutCustomerDetailViewController.h"

#import "UIScreen+Helpers.h"

#import "LookupOrderUtil.h"
#import "AlertUtils.h"

@interface SSCheckoutCustomerListViewController()

- (void) layoutView: (UIInterfaceOrientation) interfaceOrientation;
- (void) updateDisplayValues;

@end

@implementation SSCheckoutCustomerListViewController
@synthesize customerList;
@synthesize searchString;
@synthesize doGetOrdersOnSelection;

#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Set up the items that will appear in a navigation controller bar if
        // this view controller is added to a UINavigationController.
        [[self navigationItem] setTitle:@"Cust List"];
        [self setTitle:@"Customers"];
        
        facade = [iPOSFacade sharedInstance];
        
        doGetOrdersOnSelection = NO;
    }
    
    return self;
}

- (void) dealloc {
    
    [customerList release];
    customerList = nil;
    
    [searchString release];
    searchString = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setCustomerList:
//=========================================================== 
- (void)setCustomerList:(NSArray *)aCustomerList {
    if (customerList != aCustomerList) {
        [aCustomerList retain];
        [customerList release];
        customerList = aCustomerList;
        
        [self updateDisplayValues];
    }
}

//=========================================================== 
// - setSearchString:
//=========================================================== 
- (void)setSearchString:(NSString *)aSearchString {
    if (searchString != aSearchString) {
        [aSearchString retain];
        [searchString release];
        searchString = aSearchString;
        
        [self updateDisplayValues];
    }
}

- (void) loadView {
    [super loadView];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectZero];
    mainView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    
    
    customerListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    customerListTableView.backgroundColor = [UIColor clearColor];
    customerListTableView.delegate = self;
    customerListTableView.dataSource = self;
    
    [mainView addSubview:customerListTableView];
    [customerListTableView release];
    
    //closeBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"New Order" style:UIBarButtonItemStyleBordered target:self action:@selector(handleClose:)] autorelease];
    //[[self navigationItem] setRightBarButtonItem:closeBarButton];
    
    
    [self setView: mainView];
    [mainView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cust List" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark UITableView Datasource and Delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (customerList == nil) {
        return 0;
    }
    
    return [customerList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	return [NSString stringWithFormat:@"Customers for %@", searchString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *customerListTableIdentifier = @"CustomerListTableIdentifier";
	CustomerListTableCell *cell = (CustomerListTableCell *)[tableView dequeueReusableCellWithIdentifier:customerListTableIdentifier];
    
    NSInteger row = indexPath.row;
    Customer *customer = (Customer *)[customerList objectAtIndex:row];
    
	if (cell == nil) {
		cell = [[[CustomerListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customerListTableIdentifier] autorelease];
    }
    cell.customer = customer;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [customerListTableView deselectRowAtIndexPath:indexPath animated:YES];
	Customer *customer = (Customer *) [customerList objectAtIndex:indexPath.row];
    
	if (customer != nil) {
        
        if (doGetOrdersOnSelection) {
            [LookupOrderUtil showOrdersFrom:self withPhone:customer.phoneNumber];
        } else {
            // Load the customer details
            Customer *customerFromLookup = [facade lookupCustomerByPhone:customer.phoneNumber];
            
            if (customerFromLookup) {
                SSCheckoutCustomerDetailViewController *custDetailsController = [[SSCheckoutCustomerDetailViewController alloc] init];
                
                custDetailsController.customer = customerFromLookup;
                [self.navigationController pushViewController:custDetailsController animated:YES];
                
                [custDetailsController release];
            } else {
                [AlertUtils showModalAlertMessage:@"Problem loading customer details." withTitle:@"iPOS"];
            }
        }
	}
}

#pragma mark -
#pragma mark Private Methods
- (void) layoutView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect viewBounds = [UIScreen rectForScreenView:interfaceOrientation isNavBarVisible:YES];
    
    self.view.frame = viewBounds;
    
    // orderListTableView.frame = CGRectInset(viewBounds, 10.0f, 10.0f);
    customerListTableView.frame = viewBounds;
    [customerListTableView reloadData];
}
- (void) updateDisplayValues {
    [customerListTableView reloadData];
}


@end
