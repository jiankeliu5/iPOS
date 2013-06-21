//
//  SSLookupCustomerViewController.m
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "SSLookupCustomerViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIScreen+Helpers.h"
#import "UIView+ViewLayout.h"
#import "NSString+StringFormatters.h"
#import "AlertUtils.h"
#import "SSCheckoutCustomerFormDataSource.h"

#import "CartItemsViewController.h"

#import "SSCheckoutCustomerDetailViewController.h"
#import "SSCheckoutCustomerListViewController.h"
#import "SSCheckoutCustomerEditViewController.h"
#import "LookupSheetViewController.h"

#define MARGIN_TOP 40.0f
#define SPACING 20.0f

#define TEXT_FIELD_HEIGHT 40.0f
#define TEXT_FIELD_WIDTH 200.0f

@interface SSLookupCustomerViewController()
- (void)performSearch:(ExtUITextField *) textField;

- (void) layoutView: (UIInterfaceOrientation) orientation;
- (void) handlegoback:(id)sender;

@end

@implementation SSLookupCustomerViewController

// @synthesize customer;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Lookup Customer"];
	[self setTitle:@"Lookup Customer"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
	orderCart = [OrderCart sharedInstance];
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
	
	custPhoneField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	custPhoneField.textColor = [UIColor blackColor];
	custPhoneField.borderStyle = UITextBorderStyleRoundedRect;
	custPhoneField.textAlignment = NSTextAlignmentCenter;
	custPhoneField.clearsOnBeginEditing = YES;
	custPhoneField.placeholder = @"Phone Number";
	custPhoneField.tagName = @"CustPhone";
	custPhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	custPhoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
	custPhoneField.returnKeyType = UIReturnKeySearch;
	custPhoneField.keyboardType = UIKeyboardTypeNumberPad;
	custPhoneField.mask = @"999-999-9999";
	[super addSearchAndCancelToolbarForTextField:custPhoneField];
	
	[self.view addSubview:custPhoneField];
	[custPhoneField release];
    
    custNameField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	custNameField.textColor = [UIColor blackColor];
	custNameField.borderStyle = UITextBorderStyleRoundedRect;
	custNameField.textAlignment = NSTextAlignmentCenter;
	custNameField.clearsOnBeginEditing = YES;
	custNameField.placeholder = @"Name";
	custNameField.tagName = @"CustName";
    custNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    custNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	custNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	custNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
	custNameField.returnKeyType = UIReturnKeySearch;
	custNameField.keyboardType = UIKeyboardTypeDefault;
	[super addSearchAndCancelToolbarForTextField:custNameField];
	
	[self.view addSubview:custNameField];
	[custNameField release];	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	custPhoneField.delegate = self;
    custNameField.delegate = self;
    
	
}

- (void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Selection" style:UIBarButtonItemStyleBordered target:self action:@selector(handlegoback:)] autorelease];
	}
	
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
	
    custPhoneField.text = @"";
    custPhoneField.text = @"";
	
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

- (void) handlegoback:(id)sender{
    LookupSheetViewController *lookupsheetViewController = [[LookupSheetViewController alloc] init];
	[[self navigationController] pushViewController:lookupsheetViewController animated:TRUE];
	[lookupsheetViewController release];
}

#pragma mark -
#pragma mark ExtUIViewController delegate
- (void)extTextFieldFinishedEditing:(ExtUITextField *)textField {
	// Nothing to do.
}

- (void) dismissKeyboard:(id)sender {
    ExtUITextField *textField = (ExtUITextField *) self.currentFirstResponder;
    
    [super dismissKeyboard:sender];
    
    [self performSearch:textField];
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
    
    [self performSearch:textField];
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
    if ([textField.tagName isEqualToString:@"CustName"]) {
        custPhoneField.text = nil;
    } else if ([textField.tagName isEqualToString:@"CustPhone"]) {
        custNameField.text = nil;
    }
}

#pragma mark -
#pragma mark Performing Searches
- (void) performSearch:(ExtUITextField *)textField {
    
    if (textField && [textField.text length] > 0) {
        NSLog(@"Incoming text: %@", textField.text);
        
        if ([textField.tagName isEqualToString:@"CustName"] && [textField.text length] > 0) {
            if (textField.text.length < 3) {
                [AlertUtils showModalAlertMessage:@"You must enter at least 3 characters for the search." withTitle:@"iPOS"];
            } else {
                NSArray *customerList = [facade lookupCustomerByName:textField.text];
                
                if (customerList == nil || [customerList count] == 0) {
                    [AlertUtils showModalAlertMessage:@"No customer matches found." withTitle:@"iPOS"];
                } else {
                    SSCheckoutCustomerListViewController *custListViewController = [[SSCheckoutCustomerListViewController alloc] init];
                    custListViewController.customerList = customerList;
                    custListViewController.searchString = textField.text;
                    [[self navigationController] pushViewController:custListViewController animated:YES];
                    [custListViewController release];
                }
            }
        } else if ([textField.tagName isEqualToString:@"CustPhone"] && [textField.text length] > 0) {
            NSString *searchString = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *regex = @"[0-9]{10}";
            NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];          
            
            if ([regextest evaluateWithObject:searchString] == YES) {
                Customer *customer = [facade lookupCustomerByPhone:searchString];
                
                // Load the details or go right to edit customer
                if (customer) {
                    // Load the customer details
                    SSCheckoutCustomerDetailViewController *custDetailsController = [[SSCheckoutCustomerDetailViewController alloc] init];
                    
                    custDetailsController.customer = customer;
                    
                    [[self navigationController] pushViewController:custDetailsController animated:TRUE];
                    [custDetailsController release];
                } else {
                    NSMutableDictionary *customerFormModel = [[[NSMutableDictionary alloc] init] autorelease];
                    [customerFormModel setValue:[NSString stringWithString:searchString] forKey:@"phoneNumber"];
                    SSCheckoutCustomerFormDataSource *customerFormDataSource = [[SSCheckoutCustomerFormDataSource alloc] initWithModel:customerFormModel];
                    SSCheckoutCustomerEditViewController *customerEditViewController = [[SSCheckoutCustomerEditViewController alloc] initWithNibName:nil bundle:nil formDataSource:customerFormDataSource];
                    
                    [customerEditViewController setTitle: @"New Customer"];
                    
                    [[self navigationController] pushViewController:customerEditViewController animated:YES];
                    
                    [customerFormDataSource release];
                    [customerEditViewController release];
                }
                
            } else {
                [AlertUtils showModalAlertMessage:@"Please enter a 10 digit phone number" withTitle:@"iPOS"];
            }
        }
        
    }
    
}

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    CGFloat cy = MARGIN_TOP;
    
    self.view.frame = viewBounds;
    
    // custPhoneField, custSearchField
    custPhoneField.frame = CGRectMake(0, cy, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT);
    custPhoneField.center = [self.view centerAt:cy];
    
    cy += TEXT_FIELD_HEIGHT + SPACING;
    custNameField.frame = CGRectMake(0, cy, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT);
    custNameField.center = [self.view centerAt:cy];
}

@end
