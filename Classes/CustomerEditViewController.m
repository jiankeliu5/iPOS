//
//  CustomerEditViewController.m
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerEditViewController.h"
#import "IBAInputManager.h"
#import "UIViewController+ViewControllerLayout.h"
#import "AlertUtils.h"

#import "Customer.h"
#import "CartItemsViewController.h"
#import "CustomerViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface CustomerEditViewController ()
- (void) saveCustomer:(id)sender;
- (void) confirmCustomer:(id)sender;
- (CustomerViewController *)findCustomerViewController;
@end

#pragma mark -
@implementation CustomerEditViewController

@synthesize lastSavedCustomer;

#pragma mark Constructors

- (void) dealloc {
	[self setLastSavedCustomer:nil];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark UIViewController overrides

- (void) loadView {
	[super loadView];
	
	orderCart = [OrderCart sharedInstance];
    facade = [iPOSFacade sharedInstance];
	
	UITableView *formTableView = [[[UITableView alloc] initWithFrame:[self rectForNav] style:UITableViewStyleGrouped] autorelease];
	[formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	formTableView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	
	[self setTableView:formTableView];
	[self setView:formTableView];
}

- (void) viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
		[[self navigationItem] setTitle:@"Edit Customer"];
		[self setTitle:@"Edit Customer"];
	}
}	

- (void) viewWillAppear:(BOOL)animated {
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cust Edit" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
		NSMutableDictionary *custModel = [[self formDataSource] model];
		NSNumber *custId = [custModel objectForKey:@"customerId"];
		if (custId != nil && ![custId isEqualToNumber:[NSNumber numberWithInt:0]]) {
			UIBarButtonItem *confirmButton = [[[UIBarButtonItem alloc] init] autorelease];
			confirmButton.title = @"Confirm";
			confirmButton.target = self;
			[confirmButton setAction:@selector(confirmCustomer:)];
			[self.navigationItem setRightBarButtonItem:confirmButton];
			// save the initial state of the customer so we can tell if we changed it before committing
			[self setLastSavedCustomer:[[custModel copy] autorelease]];
		
		} else {
			UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] init] autorelease];
			saveButton.title = @"Save";
			saveButton.target = self;
			[saveButton setAction:@selector(saveCustomer:)];
			[self.navigationItem setRightBarButtonItem:saveButton];
		}
    }
	[super viewWillAppear:animated];
}

- (void) saveCustomer:(id)sender {
	NSLog(@"Got save customer button press");
	
	// If we have an active input requestor that means there is a keyboard or
	// some other form component up.  This should dismiss it like the Done
	// button on the toolbar had been pressed.
	IBAInputManager *ibaInputManager = [IBAInputManager sharedIBAInputManager];
	if ([ibaInputManager activeInputRequestor] != nil) {
		[ibaInputManager setActiveInputRequestor:nil];
	}
	
	NSMutableDictionary *custModel = [[self formDataSource] model];
	NSLog(@"Current customer model:");
	NSLog(@"%@", [custModel description]);
	Customer *editedCust = [[[Customer alloc] initWithModel:custModel] autorelease];
    
	[facade newCustomer:editedCust];

	if ( ([editedCust errorList] != nil) && ([[editedCust errorList] count] > 0) ) {
		NSMutableString *errMsg = [[[NSMutableString alloc] init] autorelease];
		[errMsg appendString:@"Error in customer save"];
		for (Error *e in [editedCust errorList]) {
			NSLog(@"Error Id: %d %@", [e errorId], [e message]);
			[errMsg appendFormat:@"\nError (%d): %@", [e errorId], [e message]];
		}
		[AlertUtils showModalAlertMessage:errMsg];
	} else {
		NSLog(@"No errors from new customer call");
		NSMutableDictionary *updatedModel = [editedCust modelFromCustomer];
		[self setLastSavedCustomer:updatedModel];
		NSLog(@"updated model:");
		NSLog(@"%@", [updatedModel description]);
		[updatedModel enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			NSLog(@"Enumerating Key %@ and Value %@",key,obj);
			[[self formDataSource] setModelValue:obj forKeyPath:key];
		}];
		
		[[self tableView] reloadData];
		
		// Switch over to a confirm button now.
		[self.navigationItem setRightBarButtonItem:nil];
		UIBarButtonItem *confirmButton = [[[UIBarButtonItem alloc] init] autorelease];
		confirmButton.title = @"Confirm";
		confirmButton.target = self;
		[confirmButton setAction:@selector(confirmCustomer:)];
		[self.navigationItem setRightBarButtonItem:confirmButton];
	}
	
}

- (void) confirmCustomer:(id)sender {
	NSLog(@"Got confirm customer button press");
	
	// If we have an active input requestor that means there is a keyboard or
	// some other form component up.  This should dismiss it like the Done
	// button on the toolbar had been pressed.
	IBAInputManager *ibaInputManager = [IBAInputManager sharedIBAInputManager];
	if ([ibaInputManager activeInputRequestor] != nil) {
		[ibaInputManager setActiveInputRequestor:nil];
	}
	
	NSMutableDictionary *custModel = [[self formDataSource] model];
	NSLog(@"Current customer model:");
	NSLog(@"%@", [custModel description]);
	if ([self lastSavedCustomer] != nil) {
		NSLog(@"Last Saved Customer model:");
		NSLog(@"%@", [[self lastSavedCustomer] description]);
	}
	
	Customer *editedCust = [[[Customer alloc] initWithModel:custModel] autorelease];
	
	if ([self lastSavedCustomer] == nil || ([[self lastSavedCustomer] isEqualToDictionary:custModel] == NO)) {
		NSLog(@"Updating customer on commit because it changed.");
		[facade updateCustomer:editedCust];
	}
	
	if ( ([editedCust errorList] != nil) && ([[editedCust errorList] count] > 0) ) {
		NSMutableString *errMsg = [[[NSMutableString alloc] init] autorelease];
		[errMsg appendString:@"Error in customer update!"];
		for (Error *e in [editedCust errorList]) {
			NSLog(@"Error Id: %d %@", [e errorId], [e message]);
			[errMsg appendFormat:@"\nError (%d): %@", [e errorId], [e message]];
		}
		[AlertUtils showModalAlertMessage:errMsg];
	} else {
		NSLog(@"No errors in customer");
		NSMutableDictionary *updatedModel = [editedCust modelFromCustomer];
		Customer *custCopy = [[[Customer alloc] initWithModel:updatedModel] autorelease];
        
        // Bind the customer to the order cart
		[orderCart bindCustomerToOrder:custCopy];
        // Clear the saved customer entry in the search customer view controller to keep it
		// from showing if we navigate back.
		CustomerViewController *custViewController = [self findCustomerViewController];
		if (custViewController != nil) {
			[custViewController setCustomer:nil];
		}
        
        if (custCopy.errorList && [custCopy.errorList count] > 0) {
            [AlertUtils showModalAlertForErrors:custCopy.errorList];
            return;
        }
		
		// Going to pop this controller while pushing to the cart view.
		// This should allow us to go back to the initial customer search
		// screen from the cart view.
		
		// Locally store the navigation controller since
		// self.navigationController will be nil once we are popped
		UINavigationController *navController = self.navigationController;
		
		// retain ourselves so that the controller will still exist once it's popped off
		[[self retain] autorelease];
		
		CartItemsViewController *cart = [[[CartItemsViewController alloc] init] autorelease];
		
		// Pop this controller and replace with another
		[navController popViewControllerAnimated:NO];
		[navController pushViewController:cart animated:YES];
		
	}
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (CustomerViewController *)findCustomerViewController {
	if ([self navigationController] != nil) {
		NSArray *controllers = [[self navigationController] viewControllers];
		for (UIViewController *vc in controllers) {
			if ([vc title] != nil && [[vc title] isEqualToString:@"Customer"]) {
				return (CustomerViewController*)vc;
			}
		}
	}
	return nil;
}

@end
