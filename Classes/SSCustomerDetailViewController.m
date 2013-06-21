//
//  CustomerDetailViewController.m
//  iPOS
//
//  Created by Torey Lomenda on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SSCustomerDetailViewController.h"

#import "SSCustomerEditViewController.h"
#import "CustomerFormDataSource.h"

#import "RoomsViewController.h"
#import "SSCustomerListViewController.h"
#import "SSCustomerViewController.h"

#import "UIScreen+Helpers.h"
#import "NSString+StringFormatters.h"
#import "UIViewController+Helpers.h"

#import "AlertUtils.h"

#define MARGIN_TOP 20.0f

#define LABEL_FONT_SIZE 12.0f
#define LABEL_HEIGHT 12.0f
#define LABEL_SPACING 7.0f

#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 100.0f

#define DETAIL_VIEW_WIDTH 280.0f
#define DETAIL_VIEW_HEIGHT 102.0f
#define DETAIL_LABEL_X 0.0f
#define DETAIL_LABEL_WIDTH 40.0f
#define DETAIL_DATA_X 40.0f
#define DETAIL_DATA_WIDTH 260.0f
#define CONFIRM_BUTTON_X 180.0f

@interface SSCustomerDetailViewController()

- (void) layoutView: (UIInterfaceOrientation) orientation;

- (void) layoutButtons;
- (void) updateDisplayValues;

- (void) handleEditButton:(id)sender;
- (void) handleConfirmButton:(id)sender;

- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect;
- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect;

@end

@implementation SSCustomerDetailViewController
@synthesize customer, contractor;

#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configuration here
        // Set up the items that will appear in a navigation controller bar if
        // this view controller is added to a UINavigationController.
        [[self navigationItem] setTitle:@"Customer Detail"];
        [self setTitle:@"Cust Detail"];
    }
    
    return self;
}

- (void) dealloc {
    [customer release];
    customer = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void) loadView {
    [super loadView];
    
    CGRect appFrame = [[UIScreen mainScreen]applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:appFrame];
    
    mainView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    
	// Set up the detail view for showing customer summary information when fetched by the search.
    detailView = [[UIView alloc] initWithFrame:CGRectZero];
    
    firstLabel = [self createNormalLabel:@"First" withRect:CGRectZero];
    [detailView addSubview:firstLabel];
    
    firstName = [self createBoldLabel:nil withRect:CGRectZero];
    [detailView addSubview:firstName];
    
    lastLabel = [self createNormalLabel:@"Last" withRect:CGRectZero];
    [detailView addSubview:lastLabel];
    
    lastName = [self createBoldLabel:nil withRect:CGRectZero];
    [detailView addSubview:lastName];
    
    emailLabel = [self createNormalLabel:@"Email" withRect:CGRectZero];
    [detailView addSubview:emailLabel];
    
    email = [self createBoldLabel:nil withRect:CGRectZero];
    [detailView addSubview:email];
    
    zipLabel = [self createNormalLabel:@"Zip" withRect:CGRectZero];
    [detailView addSubview:zipLabel];
    
    zip = [self createBoldLabel:nil withRect:CGRectZero];
    [detailView addSubview:zip];
    
    holdStatusLabel = [self createNormalLabel:@"Status" withRect:CGRectZero];
    holdStatus = [self createBoldLabel:nil withRect:CGRectZero];
    
    [detailView addSubview:holdStatusLabel];
    [detailView addSubview:holdStatus];
    
    [mainView addSubview:detailView];
    [detailView release];
    
    confirmButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [confirmButton setupAsSmallBlackButton];
    confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [mainView addSubview:confirmButton];
    [confirmButton release];
    
    editButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [editButton setupAsSmallBlackButton];
    editButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    
    [confirmButton addTarget:self action:@selector(handleConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [editButton addTarget:self action:@selector(handleEditButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [mainView addSubview:editButton];
    
    [editButton release];
    
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
    [self updateDisplayValues];
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Private Methods
- (void) layoutView:(UIInterfaceOrientation)orientation {
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    CGFloat cy = MARGIN_TOP;
    
    self.view.frame = viewBounds;
    
    // detailView (firstLabel, firstName, lastLabel, lastName, emailLabel, email, zipLabel, zip, holdStatusLabel, holdStatus)
    detailView.frame = CGRectMake((viewBounds.size.width - DETAIL_VIEW_WIDTH)/2, cy, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT);
    
    CGFloat labelY = LABEL_SPACING;
    firstLabel.frame = CGRectMake(0, labelY, DETAIL_LABEL_WIDTH, LABEL_HEIGHT);
    firstName.frame = CGRectMake(DETAIL_LABEL_WIDTH, labelY, DETAIL_DATA_WIDTH, LABEL_HEIGHT);
    
    labelY += LABEL_HEIGHT + LABEL_SPACING;
    lastLabel.frame = CGRectMake(0, labelY, DETAIL_LABEL_WIDTH, LABEL_HEIGHT);
    lastName.frame = CGRectMake(DETAIL_LABEL_WIDTH, labelY, DETAIL_DATA_WIDTH, LABEL_HEIGHT);
    
    labelY += LABEL_HEIGHT + LABEL_SPACING;
    emailLabel.frame = CGRectMake(0, labelY, DETAIL_LABEL_WIDTH, LABEL_HEIGHT);
    email.frame = CGRectMake(DETAIL_LABEL_WIDTH, labelY, DETAIL_DATA_WIDTH, LABEL_HEIGHT);
    
    labelY += LABEL_HEIGHT + LABEL_SPACING;
    zipLabel.frame = CGRectMake(0, labelY, DETAIL_LABEL_WIDTH, LABEL_HEIGHT);
    zip.frame = CGRectMake(DETAIL_LABEL_WIDTH, labelY, DETAIL_DATA_WIDTH, LABEL_HEIGHT);
    
    labelY += LABEL_HEIGHT + LABEL_SPACING;
    holdStatusLabel.frame = CGRectMake(0, labelY, DETAIL_LABEL_WIDTH, LABEL_HEIGHT);
    holdStatus.frame = CGRectMake(DETAIL_LABEL_WIDTH, labelY, DETAIL_DATA_WIDTH, LABEL_HEIGHT);
    
    [self layoutButtons];
}

- (void) layoutButtons {
    CGFloat cy = MARGIN_TOP;
    CGFloat width = self.view.bounds.size.width;
    
    
    cy = MARGIN_TOP*2 + DETAIL_VIEW_HEIGHT;
    
    CGFloat buttonSpace = floorf((width - BUTTON_WIDTH * 2.0f) / 3.0f);
    confirmButton.frame = CGRectMake(buttonSpace, cy, BUTTON_WIDTH, BUTTON_HEIGHT);
    editButton.frame = CGRectMake(((buttonSpace * 2.0f) + BUTTON_WIDTH), cy, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    if (![customer isOnHold]) {
        [confirmButton setEnabled:YES];
        [editButton setEnabled:YES];
        holdStatus.textColor = [UIColor blackColor];
    }
    else {
        [confirmButton setEnabled:NO];
        [editButton setEnabled:NO];
        holdStatus.textColor = [UIColor redColor];
    }
}

- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label;
	label = [[UILabel alloc] initWithFrame:rect];
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	return [label autorelease];
}

- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label = [self createNormalLabel:text withRect:rect];
	label.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

- (void) updateDisplayValues {
	if (customer != nil) {
		firstName.text = customer.firstName;
		lastName.text = customer.lastName;
		email.text = customer.emailAddress;
		zip.text = customer.address.zipPostalCode;
        holdStatus.text = customer.holdStatusText;
        
        self.title = [NSString formatAsUSPhone:customer.phoneNumber];
        
	} else {
        firstName.text = @"";
		lastName.text = @"";
		email.text = @"";
		zip.text = @"";
        holdStatus.text = @"";
    }
}

- (void) handleEditButton:(id)sender {
	if (customer != nil) {
		NSMutableDictionary *customerFormModel = [self.customer modelFromCustomer];
		CustomerFormDataSource *customerFormDataSource = [[[CustomerFormDataSource alloc] initWithModel:customerFormModel] autorelease];
		SSCustomerEditViewController *customerEditViewController = [[[SSCustomerEditViewController alloc] initWithNibName:nil bundle:nil formDataSource:customerFormDataSource] autorelease];
		[customerEditViewController setTitle:@"Customer Edit"];
		[[self navigationController] pushViewController:customerEditViewController animated:TRUE];
	} else {
		NSLog(@"Should not be trying to edit if customer is nil");
	}
}

- (void) handleConfirmButton:(id)sender {
	NSLog(@"Got confirm button press");
	if (self.customer != nil) {
		NSMutableDictionary *cpy = [self.customer modelFromCustomer];
		Customer *custCpy = [[[Customer alloc] initWithModel:cpy] autorelease];
        
        if (self.contractor) {
            [SelectionSheet sharedInstance].contractor = custCpy;
            [SelectionSheet sharedInstance].storeId = custCpy.store.storeId;
            
        } else {
            [SelectionSheet sharedInstance].customer = custCpy;
            [SelectionSheet sharedInstance].storeId = custCpy.store.storeId;
        }
        [self setCustomer:nil];
        
        // There may have been issues binding the customer
        if (custCpy.errorList && [custCpy.errorList count] > 0) {
            [AlertUtils showModalAlertForErrors:custCpy.errorList withTitle:@"iPOS"];
            return;
        }
        
        // This is where you pop to the order cart or pop the customer controllers and push the order cart
        UIViewController *cartItemsController = [self getOnNavStackByType:[RoomsViewController class]];
        
        if (cartItemsController) {
            [self.navigationController popToViewController:cartItemsController animated:YES];
        } else {
            // Pop all relevant customer controllers including self
            UINavigationController *navController = self.navigationController;
            UIViewController *custListController = [self getOnNavStackByType:[SSCustomerListViewController class]];
            UIViewController *custController = [self getOnNavStackByType:[SSCustomerViewController class]];
            
            
            [[self retain] autorelease];
            
            [navController popViewControllerAnimated:NO];
            
            if (custListController) {
                [navController popViewControllerAnimated:NO];
            }
            if (custController) {
                [navController popViewControllerAnimated:NO];
            }
            
            // Push the cart items controller
            RoomsViewController *cartItemsController = [[RoomsViewController alloc] init];
            [navController pushViewController:cartItemsController animated:YES];
            [cartItemsController release];
        }
	}
}


@end
