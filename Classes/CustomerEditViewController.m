//
//  CustomerEditViewController.m
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerEditViewController.h"
#import "UIViewController+ViewControllerLayout.h"

#pragma mark -
#pragma mark Private Interface
@interface CustomerEditViewController ()
- (void) saveCustomer:(id)sender;
@end

#pragma mark -
@implementation CustomerEditViewController

#pragma mark Constructors
- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	facade = [iPOSFacade sharedInstance];
	
	[[self navigationItem] setTitle:@"Edit Customer"];
	
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark UIViewController overrides

- (void) loadView {
	[super loadView];
	
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
}

- (void) saveCustomer:(id)sender {
	NSLog(@"Got save customer button press");
	NSMutableDictionary *custModel = [[self formDataSource] model];
	NSLog(@"Current customer model:");
	NSLog(@"%@", [custModel description]);
}

@end
