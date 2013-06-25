//
//  SendEmailViewController.m
//  iPOS
//
//  Created by Enning Tang on 5/8/13.
//
//

#import "SendEmailViewController.h"
#import "AlertUtils.h"
#import "ValidationUtils.h"

#import "UIScreen+Helpers.h"
#include "iPOSAppDelegate.h"

#import "iPOSFacade.h"
#import "OrderCart.h"
#import "Order.h"

@interface SendEmailViewController ()

@end

@implementation SendEmailViewController

@synthesize order;

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Email Receipt"];
	[self setTitle:@"Email Receipt"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
	
    return self;
}

#pragma mark -
#pragma mark UIViewController overrides

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self layoutView:[[UIApplication sharedApplication] statusBarOrientation]];
	
	// Do this last
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
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

- (void)loadView {
    
    NSLog(@"email receipt loadView called");
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
	bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:bgView];
	[bgView release];
	
	emailReceipt = [[UILabel alloc] initWithFrame:CGRectZero];
	emailReceipt.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	emailReceipt.textColor = [UIColor blackColor];
	emailReceipt.text = @"Enter Order ID and email address";
	emailReceipt.textAlignment = NSTextAlignmentCenter;
    
	//[self.view addSubview:emailReceipt];
	[emailReceipt release];
	
    orderID = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	orderID.textColor = [UIColor blackColor];
	orderID.borderStyle = UITextBorderStyleRoundedRect;
	orderID.textAlignment = NSTextAlignmentCenter;
	orderID.clearsOnBeginEditing = NO;
	orderID.placeholder = @"Order ID";
	orderID.tagName = @"OrderID";
    orderID.keyboardType = UIKeyboardTypeNumberPad;
	orderID.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
	[super addSearchAndCancelToolbarForTextField:orderID];
	[self.view addSubview:orderID];
	[orderID release];
    
	emailAddress = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	emailAddress.textColor = [UIColor blackColor];
	emailAddress.borderStyle = UITextBorderStyleRoundedRect;
	emailAddress.textAlignment = NSTextAlignmentCenter;
	emailAddress.clearsOnBeginEditing = NO;
	emailAddress.placeholder = @"E-mail address";
	emailAddress.tagName = @"emailAddress";
	emailAddress.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailAddress.autocorrectionType = UITextAutocorrectionTypeNo;
    emailAddress.autocapitalizationType = UITextAutocapitalizationTypeNone;
	emailAddress.keyboardType = UIKeyboardTypeEmailAddress;
	[super addDoneAndCancelToolbarForTextField:emailAddress];
	[self.view addSubview:emailAddress];
	[emailAddress release];
	
	sendReceipt = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[sendReceipt setTitle:@"Send Receipt" forState:UIControlStateNormal];
	[sendReceipt setupAsBlackButton];
	[self.view addSubview:sendReceipt];

}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
	if (self.navigationController != nil)
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	orderID.delegate = self;
    emailAddress.delegate = self;
    
	[sendReceipt addTarget:self action:@selector(sendReceiptPressed:) forControlEvents:UIControlEventTouchUpInside];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) layoutView:(UIInterfaceOrientation)interfaceOrientation {
    
    NSLog(@"email receipt layoutView called");
    CGRect viewBounds = [UIScreen rectForScreenView:interfaceOrientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
    
    emailReceipt.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 50.0f, 40.0f);
    emailReceipt.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        labelButtonSpacing = labelButtonSpacing + 4.0;
    }
    
    orderID.frame = CGRectOffset(emailReceipt.frame, 0.0f, labelButtonSpacing);
    emailAddress.frame = CGRectOffset(orderID.frame, 0.0f, labelButtonSpacing);
    
    // Change to work from lookupOrderField position when that is implemented
    sendReceipt.frame = CGRectOffset(emailAddress.frame, 0.0f, labelButtonSpacing);
    
    orderID.textAlignment = NSTextAlignmentLeft;
    emailAddress.textAlignment = NSTextAlignmentLeft;
    orderID.textAlignment = NSTextAlignmentCenter;
    emailAddress.textAlignment = NSTextAlignmentCenter;
    
}

- (IBAction)sendReceiptPressed:(id)sender{
    if (!([orderID.text length] == 0) && !([emailAddress.text length] == 0))
    {
        NSLog(@"sendReceiptPressed called");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm?" message:[NSString stringWithFormat:@"Email order %@ receipt to %@?", orderID.text, emailAddress.text] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        [alert release];
    }else
    {
        NSLog(@"sendReceiptPressed called");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPOS" message:@"Invalid order ID or email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
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

- (void) performSearch:(ExtUITextField *)textField {
    if (textField && [textField.text length] > 0) {
        NSString *lookupText = textField.text;
        
        if ([textField.tagName isEqualToString:@"OrderID"] && [textField.text length] > 0) {
            // Call the service and display the overlay view
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *orderIDNum = [formatter numberFromString:lookupText];
            [formatter release];
            
            Order *getOrder = [facade lookupOrderByOrderId:orderIDNum];
            self.order = getOrder;
            
            NSLog(@"order customer: %@", getOrder.customer.customerId.stringValue);
            
            if (([getOrder.customer.customerId isEqualToNumber:[NSNumber numberWithInt:0]]) || (getOrder.customer.customerId == nil))
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPOS" message:@"Invalid order number." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [alert release];
                orderID.text = @"";
                emailAddress.text = @"";
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Customer's email?" message:@"Do you want to load order customer's email address?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                [alert show];
                [alert release];
            }
        }else if ([textField.tagName isEqualToString:@"emailAddress"] && [textField.text length] > 0) {
            // Call the service to get a list of items
            if(![ValidationUtils validateEmail:lookupText]) {
                // user entered invalid email address
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPOS" message:@"Please enter a valid email address." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [alert release];
                emailAddress.text = @"";
            } else {
                // user entered valid email address
            }
        }
    }
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex {
    
    if ([anAlertView.title isEqualToString:@"Load Customer's email?"]) {
        NSLog(@"Got alert");
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Yes"]) {
            emailAddress.text = self.order.customer.emailAddress;
		}
	}
    if ([anAlertView.title isEqualToString:@"Confirm?"]) {
        NSLog(@"Got alert");
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Yes"]) {
            [facade emailReceiptWithEmail:self.order withEmail:emailAddress.text];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPOS" message:@"Email has been sent successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            orderID.text = @"";
            emailAddress.text = @"";
		}
	}
    
	// Other generic alerts will just fall through and dismiss with no other actions.
}

@end
