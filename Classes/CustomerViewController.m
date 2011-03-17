//
//  CustomerViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"

@interface CustomerViewController()
- (void) handleSearchButton:(id)sender;
- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect;
- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect;
- (void) updateViewLayout;
@end

@implementation CustomerViewController

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Customer"];

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	UIView *custView = [[UIView alloc] initWithFrame:CGRectZero];
	custView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:custView];
	[custView release];
	
	custPhoneField = [[ExtUITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT)];
	custPhoneField.textColor = [UIColor blackColor];
	custPhoneField.borderStyle = UITextBorderStyleRoundedRect;
	custPhoneField.textAlignment = UITextAlignmentCenter;
	custPhoneField.clearsOnBeginEditing = YES;
	custPhoneField.placeholder = @"Phone Number";
	custPhoneField.tagName = @"CustPhone";
	custPhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	custPhoneField.returnKeyType = UIReturnKeyGo;
	custPhoneField.keyboardType = UIKeyboardTypeNumberPad;
	[self.view addSubview:custPhoneField];
	[custPhoneField release];
	
	custSearchButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custSearchButton setupAsSmallBlackButton];
	custSearchButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custSearchButton setTitle:@"Search" forState:UIControlStateNormal];
	[self.view addSubview:custSearchButton];
	[custSearchButton release];
	
	// Set up the detail view for showing customer summary information when fetched by the search.
	detailView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT)];
	
	CGFloat dy = LABEL_SPACING;
	firstLabel = [self createNormalLabel:@"First Name" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstLabel];
	[firstLabel release];
	firstName = [self createBoldLabel:@"Megan" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstName];
	[firstName release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	lastLabel = [self createNormalLabel:@"Last Name" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastLabel];
	[lastLabel release];
	lastName = [self createBoldLabel:@"Hoy" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastName];
	[lastName release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	emailLabel = [self createNormalLabel:@"Email Address" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:emailLabel];
	[emailLabel release];
	email = [self createBoldLabel:@"Mhoy@tileshop.com" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:email];
	[email release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	zipLabel = [self createNormalLabel:@"Zip Code" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zipLabel];
	[zipLabel release];
	zip = [self createBoldLabel:@"55441" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zip];
	[zip release];
	
	detailView.hidden = YES;
	[self.view addSubview:detailView];
	[detailView release];
	
	custNewButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custNewButton setupAsSmallBlackButton];
	custNewButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custNewButton setTitle:@"Enter New" forState:UIControlStateNormal];
	custNewButton.hidden = YES;
	[self.view addSubview:custNewButton];
	[custNewButton release];
	
	custEditButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custEditButton setupAsSmallBlackButton];
	custEditButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custEditButton setTitle:@"Edit" forState:UIControlStateNormal];
	custEditButton.hidden = YES;
	[self.view addSubview:custEditButton];
	[custEditButton release];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	[custSearchButton addTarget:self action:@selector(handleSearchButton:) forControlEvents:UIControlEventTouchUpInside];
	
}

- (void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	[self updateViewLayout];
	
	// Do this last
	[super viewWillAppear:animated];
	
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	// Do this at the end
	[super viewDidDisappear:animated];
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
#pragma mark UIButton callbacks
- (void)handleSearchButton:(id)sender {
	NSLog(@"Got search button press");
	if (custDetailsOpen == NO) {
		custDetailsOpen = YES;
	} else {
		custDetailsOpen = NO;
	}
	[self updateViewLayout];
}

#pragma mark -
#pragma mark UILabel creation
- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label;
	label = [[UILabel alloc] initWithFrame:rect];
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = UITextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label = [self createNormalLabel:text withRect:rect];
	label.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

#pragma mark -
#pragma mark UIView update
- (void) updateViewLayout {
	CGFloat width = self.view.bounds.size.width;
	
	CGFloat cy = START_Y;
	custPhoneField.center = [self.view centerAt:cy];
	
	if (custDetailsOpen == NO) {
		cy += TEXT_FIELD_HEIGHT + SPACING;
		detailView.hidden = YES;
		custNewButton.hidden = YES;
		custEditButton.hidden = YES;
		custSearchButton.center = [self.view centerAt:cy];
	} else {
		cy += TEXT_FIELD_HEIGHT;
		detailView.frame = CGRectMake(DETAIL_VIEW_X, cy, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT);
		detailView.hidden = NO;
		cy += DETAIL_VIEW_HEIGHT + SPACING;
		CGFloat buttonSpace = floorf((width - BUTTON_WIDTH * 3.0f) / 4.0f);
		custEditButton.frame = CGRectMake(buttonSpace, cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		custEditButton.hidden = NO;
		custSearchButton.frame = CGRectMake(((buttonSpace * 2.0f) + BUTTON_WIDTH), cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		custNewButton.frame = CGRectMake((buttonSpace * 3.0f) + (BUTTON_WIDTH * 2.0f), cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		custNewButton.hidden = NO;
	}
}

@end
