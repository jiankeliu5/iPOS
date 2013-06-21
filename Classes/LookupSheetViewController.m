//
//  LookupOrderViewController.m
//  iPOS
//
//  Created by Steven McCoole on 10/5/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "LookupSheetViewController.h"

#import "AlertUtils.h"
#import "LookupOrderUtil.h"

#import "OrderListViewController.h"
#import "OrderItemsViewController.h"
#import "CustomerListViewController.h"

#import "LookupSheetListViewController.h"

#import "UIScreen+Helpers.h"

#define TEXT_FIELD_HEIGHT 40.0f

@interface LookupSheetViewController()
- (void)layoutView: (UIInterfaceOrientation) interfaceOrientation;
- (void)performSearch:(ExtUITextField *) textField;
- (void)handleClose:(id)sender;
@end

@implementation LookupSheetViewController

@synthesize closeBarButton, lookupProjectField, lookupCustomerField, lookupContractorField, archivedSwitch, archiveLabel, searchButton;

#pragma mark Constructors
- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    // Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Search"];
	[self setTitle:@"Selection"];
	
    facade = [iPOSFacade sharedInstance];
	selSheet = [SelectionSheet sharedInstance];
    
    
    return self;
    
}

- (void)dealloc {
    [self setCloseBarButton:nil];
    
    [super dealloc];
}

#pragma mark - 
#pragma mark Accessors
- (UIView *)contentView {
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
    [self layoutView:toInterfaceOrientation];
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
    
    self.lookupCustomerField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	self.lookupCustomerField.textColor = [UIColor blackColor];
	self.lookupCustomerField.borderStyle = UITextBorderStyleRoundedRect;
	self.lookupCustomerField.textAlignment = NSTextAlignmentCenter;
	self.lookupCustomerField.clearsOnBeginEditing = NO;
	self.lookupCustomerField.placeholder = @"Client Name";
	self.lookupCustomerField.tagName = @"LookupCustomerName";
    self.lookupCustomerField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.lookupCustomerField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.lookupCustomerField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [super addDoneAndCancelToolbarForTextField:self.lookupCustomerField];
	[self.view addSubview:self.lookupCustomerField];
	//[lookupCustomerField release];
    
    self.lookupContractorField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	self.lookupContractorField.textColor = [UIColor blackColor];
	self.lookupContractorField.borderStyle = UITextBorderStyleRoundedRect;
	self.lookupContractorField.textAlignment = NSTextAlignmentCenter;
	self.lookupContractorField.clearsOnBeginEditing = NO;
	self.lookupContractorField.placeholder = @"Contractor Name";
	self.lookupContractorField.tagName = @"LookupContractorName";
	self.lookupContractorField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lookupContractorField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.lookupContractorField.autocorrectionType = UITextAutocorrectionTypeNo;
	[super addDoneAndCancelToolbarForTextField:self.lookupContractorField];
	[self.view addSubview:self.lookupContractorField];
	//[lookupContractorField release];
    
    self.lookupProjectField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	self.lookupProjectField.textColor = [UIColor blackColor];
	self.lookupProjectField.borderStyle = UITextBorderStyleRoundedRect;
	self.lookupProjectField.textAlignment = NSTextAlignmentCenter;
	self.lookupProjectField.clearsOnBeginEditing = NO;
	self.lookupProjectField.placeholder = @"Project Name";
	self.lookupProjectField.tagName = @"LookupProjectName";
	self.lookupProjectField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lookupProjectField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.lookupProjectField.autocorrectionType = UITextAutocorrectionTypeNo;
	[super addCancelToolbarForTextField:self.lookupProjectField];
    [super addDoneAndCancelToolbarForTextField:self.lookupProjectField];
	[self.view addSubview:self.lookupProjectField];
	//[lookupProjectField release];
    
    self.archiveLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.archiveLabel.text = @"Archived";
    self.archiveLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    [self.view addSubview:self.archiveLabel];
    
    self.archivedSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.archivedSwitch.on = NO;
    [self.view addSubview:self.archivedSwitch];
    
    
    self.searchButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
	[self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
	[self.searchButton setupAsBlackButton];
	[self.view addSubview:self.searchButton];
    
    //self.closeBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"New Sheet" style:UIBarButtonItemStyleBordered target:self action:@selector//(handleClose:)] autorelease];
    //[[self navigationItem] setRightBarButtonItem:self.closeBarButton];
}

- (void)layoutView: (UIInterfaceOrientation) interfaceOrientation {
    CGRect viewBounds = [UIScreen rectForScreenView: interfaceOrientation isNavBarVisible:YES];
    CGFloat textFieldWidth = viewBounds.size.width * 0.60f;
	CGFloat	textFieldSpacing = viewBounds.size.height * 0.10f;
    
    self.view.frame = viewBounds;
	
    self.lookupCustomerField.frame = CGRectMake(0.0f, 0.0f, textFieldWidth, TEXT_FIELD_HEIGHT);
	self.lookupCustomerField.center = CGPointMake((viewBounds.size.width / 2.0f), textFieldSpacing);
    
	self.lookupContractorField.frame = CGRectOffset(self.lookupCustomerField.frame, 0.0f, textFieldSpacing + (TEXT_FIELD_HEIGHT / 2.0f));
	
	self.lookupProjectField.frame = CGRectOffset(self.lookupContractorField.frame, 0.0f, textFieldSpacing + (TEXT_FIELD_HEIGHT / 2.0f));
    
    // self.archiveLabel.frame = CGRectOffset(self.lookupContractorField.frame, 0.0f, textFieldSpacing + (TEXT_FIELD_HEIGHT / 2.0f));
    
    self.archiveLabel.frame = CGRectMake(0.0f, 0.0f, (textFieldWidth / 2.0f), TEXT_FIELD_HEIGHT);
	self.archiveLabel.center = CGPointMake((viewBounds.size.width * 0.40f), self.lookupProjectField.center.y + TEXT_FIELD_HEIGHT * 1.5f);
    
    self.archivedSwitch.frame = CGRectMake(0.0f, 0.0f, (textFieldWidth / 2.0f), TEXT_FIELD_HEIGHT);
	self.archivedSwitch.center = CGPointMake((viewBounds.size.width * 0.65f), self.lookupProjectField.center.y + TEXT_FIELD_HEIGHT * 1.5f);
    
    self.searchButton.frame = CGRectOffset(self.lookupProjectField.frame, 0.0f, textFieldSpacing + (TEXT_FIELD_HEIGHT * 2.0f));
    
    // UIKit bug.  Need to do this to re-center the placeholder text.
    /*   lookupOrderIdField.textAlignment = NSTextAlignmentLeft;
     lookupOrderIdField.textAlignment = NSTextAlignmentCenter;
     
     // UIKit bug.  Need to do this to re-center the placeholder text.
     lookupOrderPhoneField.textAlignment = NSTextAlignmentLeft;
     lookupOrderPhoneField.textAlignment = NSTextAlignmentCenter;
     
     // UIKit bug.  Need to do this to re-center the placeholder text.
     lookupCustomerField.textAlignment = NSTextAlignmentLeft;
     lookupCustomerField.textAlignment = NSTextAlignmentCenter;
     
     */
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	self.lookupContractorField.delegate = self;
    self.lookupCustomerField.delegate = self;
    self.lookupProjectField.delegate = self;
    [searchButton addTarget:self action:@selector(searchPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    // Clear out all sections of the order cart
    //[selSheet clearSheet];
    
    if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Lookup Sheet" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
    [self layoutView: [UIApplication sharedApplication].statusBarOrientation];
    
    self.lookupCustomerField.text = @"";;
    self.lookupContractorField.text = @"";
    self.lookupProjectField.text = @"";
    
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

#pragma mark -
#pragma mark ExtUIViewController delegate
- (void)extTextFieldFinishedEditing:(ExtUITextField *)textField {
    // Do nothing
}

- (void) dismissKeyboard:(id)sender {
    //  ExtUITextField *textField = (ExtUITextField *) self.currentFirstResponder;
    
    [super dismissKeyboard:sender];
    
    //   [self performSearch:textField];
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
    
    // [self performSearch:textField];
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
    /*if ([textField.tagName isEqualToString:@"LookupCustomerName"]) {
     lookupOrderPhoneField.text = nil;
     lookupOrderIdField.text = nil;
     } else if ([textField.tagName isEqualToString:@"LookupOrderPhone"]) {
     lookupOrderIdField.text = nil;
     lookupCustomerField.text = nil;
     } else if ([textField.tagName isEqualToString:@"LookupOrderId"]) {
     lookupOrderPhoneField.text = nil;
     lookupCustomerField.text = nil;
     }*/
}

#pragma mark -
#pragma mark UIButton callbacks
- (void)searchPressed:(id)sender {
    if ([self.lookupContractorField.text length] == 0 && [self.lookupProjectField.text length] == 0 && [self.lookupCustomerField.text length] == 0  ) {
        [AlertUtils showModalAlertMessage:@"You must enter at least one search criteria." withTitle:@"iPOS"];
    } else {
        NSArray *sheets = [facade lookupSheetByProduct:self.lookupProjectField.text andCustomer:self.lookupCustomerField.text andContractor:self.lookupContractorField.text andArchived:[self.archivedSwitch isOn]];
        NSLog(@"sheets is %@",sheets);
        LookupSheetListViewController *listVC = [[LookupSheetListViewController alloc] init];
        listVC.tableData = sheets;
        [[self navigationController] pushViewController:listVC animated:YES];
    }
}

- (void) performSearch:(ExtUITextField *)textField {
    if (textField && [textField.text length] > 0) {
        NSLog(@"Incoming text: %@", textField.text);
        
        if ([textField.tagName isEqualToString:@"LookupCustomerName"] && [textField.text length] > 0) {
            if (textField.text.length < 3) {
                [AlertUtils showModalAlertMessage:@"You must enter at least 3 characters for the search." withTitle:@"iPOS"];
            } else {
                NSArray *customerList = [facade lookupCustomerByName:textField.text];
                
                if (customerList == nil || [customerList count] == 0) {
                    [AlertUtils showModalAlertMessage:@"No customer matches found." withTitle:@"iPOS"];
                } else {
                    CustomerListViewController *custListViewController = [[CustomerListViewController alloc] init];
                    
                    custListViewController.customerList = customerList;
                    custListViewController.searchString = textField.text;
                    custListViewController.doGetOrdersOnSelection = YES;
                    [[self navigationController] pushViewController:custListViewController animated:TRUE];
                    [custListViewController release];
                }
            }
        } 
        /*else if ([textField.tagName isEqualToString:@"LookupOrderId"] && [textField.text length] > 0) {
         NSNumber *orderIdInput = [orderIdFormatter numberFromString:textField.text];
         if (orderIdInput != nil) {
         // order comes back autoreleased
         Order *order = [facade lookupOrderByOrderId:orderIdInput];
         if (order != nil) {
         if (![order isCanceled]) {
         // Prep and go to the order edit view controller
         NSLog(@"Found Order: %@", order.orderId);
         textField.text = nil;
         [orderCart setPreviousOrder:order];
         OrderItemsViewController *orderItemsViewController = [[OrderItemsViewController alloc] init];
         [[self navigationController] pushViewController:orderItemsViewController animated:TRUE];
         [orderItemsViewController release];
         } else {
         [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Order %@ is a canceled order.  Cannot display the details.", orderIdInput] withTitle:@"iPOS"];
         }
         } else {
         [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Could not retrieve previous order.  Order Id: %@", orderIdInput] withTitle:@"iPOS"];
         }
         } else {
         [AlertUtils showModalAlertMessage:@"Please input a numeric order id." withTitle:@"iPOS"];
         }
         
         } else if ([textField.tagName isEqualToString:@"LookupOrderPhone"] && [textField.text length] > 0) {
         [LookupOrderUtil showOrdersFrom:self withPhone:textField.text];
         
         // Clear the text field here because we will send the number to the list view controller above.
         textField.text = nil;
         }*/
    }
    
}

- (void)handleClose:(id)sender {
    // Switch the order cart back to working with a new order.
    [SelectionSheet switchSheets];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
