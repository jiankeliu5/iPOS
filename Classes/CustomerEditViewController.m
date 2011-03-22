//
//  CustomerEditViewController.m
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerEditViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "Customer.h"

#pragma mark -
#pragma mark Private Interface
@interface CustomerEditViewController ()
- (void) saveCustomer:(id)sender;
@end

#pragma mark -
@implementation CustomerEditViewController

#pragma mark Constructors

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark UIViewController overrides

- (void) loadView {
	[super loadView];
	
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
	}
}	

- (void) viewWillAppear:(BOOL)animated {
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cust Edit" style:UIBarButtonItemStyleBordered target:nil action:nil];
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] init];
		saveButton.title = @"Save";
		saveButton.target = self;
		[saveButton setAction:@selector(saveCustomer:)];
		[self.navigationItem setRightBarButtonItem:saveButton];
		[saveButton release];
	}
	[super viewWillAppear:animated];
}

- (void) saveCustomer:(id)sender {
	NSLog(@"Got save customer button press");
	NSMutableDictionary *custModel = [[self formDataSource] model];
	NSLog(@"Current customer model:");
	NSLog(@"%@", [custModel description]);
	Customer *editedCust = [[[Customer alloc] initWithModel:custModel] autorelease];
	if ([editedCust customerId] == nil) {
		// new customer
		[facade newCustomer:editedCust];
	} else {
		[facade updateCustomer:editedCust];
	}

	if ( ([editedCust errorList] != nil) && ([[editedCust errorList] count] > 0) ) {
		for (Error *e in [editedCust errorList]) {
			NSLog(@"Error Id: %d %@", [e errorId], [e message]);
		}
	} else {
		NSLog(@"No errors from new or update customer call");
		NSMutableDictionary *updatedModel = [editedCust modelFromCustomer];
		NSLog(@"updated model:");
		NSLog(@"%@", [updatedModel description]);
		[updatedModel enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			NSLog(@"Enumerating Key %@ and Value %@",key,obj);
			[[self formDataSource] setModelValue:obj forKeyPath:key];
		}];
		[[self tableView] reloadData];
	}

	
}

@end
