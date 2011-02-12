//
//  MainMenuViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "MainMenuViewController.h"
#include "PlaceHolderView.h"

@interface MainMenuViewController()
	
- (void) lookupItemPressed;
- (void) lookupOrderPressed;
- (void) customerPressed;

@end


@implementation MainMenuViewController

@synthesize scanItemLabel;
@synthesize lookupItemButton;
@synthesize lookupOrderButton;
@synthesize customerButton;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"iPOS"];

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	[self setView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	self.view.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	
	[self setScanItemLabel: [[[UILabel alloc] initWithFrame:CGRectZero] autorelease]];
	self.scanItemLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	self.scanItemLabel.textColor = [UIColor blackColor];
	self.scanItemLabel.text = @"-- SCAN ITEM --";
	self.scanItemLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:self.scanItemLabel];
	
	[self setLookupItemButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	//self.lookupItemButton.backgroundColor = [UIColor whiteColor];
	//self.lookupItemButton.titleLabel.textColor = [UIColor blackColor];
	//self.lookupItemButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[self.lookupItemButton setTitle:@"Look Up Item" forState:UIControlStateNormal];
	[self.lookupItemButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[self.view addSubview:self.lookupItemButton];
	
	// Lookup Order will be in a later version
	//[self setLookupOrderButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	//[self.view addSubview:self.lookupOrderButton];
	//self.lookupOrderButton.buttonType = UIButtonTypeRoundedRect;
	//[self.lookupOrderButton setTitle:@"Look Up Order" forState:UIControlStateNormal];
	//[self.lookupOrderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[self setCustomerButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	[self.customerButton setTitle:@"Add Customer" forState:UIControlStateNormal];
	[self.customerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.view addSubview:self.customerButton];
	 
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	[self.lookupItemButton addTarget:self action:@selector(lookupItemPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.lookupOrderButton addTarget:self action:@selector(lookupOrderPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.customerButton addTarget:self action:@selector(customerPressed) forControlEvents:UIControlEventTouchUpInside];
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {

	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	CGRect viewBounds = self.view.bounds;
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.20f;
	
	self.scanItemLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
	self.scanItemLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
	
	self.lookupItemButton.frame = CGRectOffset(self.scanItemLabel.frame, 0.0f, labelButtonSpacing);
	
	//self.lookupOrderButton.frame = CGRectOffset(self.lookupItemButton.frame, 0.0f, labelButtonSpacing);
	
	// Change to work from lookupOrderButton position when that is implemented
	self.customerButton.frame = CGRectOffset(self.lookupItemButton.frame, 0.0f, labelButtonSpacing);
	
	// Do this last
	[super viewWillAppear:animated];
}


#pragma mark -
#pragma mark UIButton callbacks
- (void)lookupItemPressed {
}

- (void)lookupOrderPressed {
}

- (void)customerPressed {
}


@end
