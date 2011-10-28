//
//  LookupOrderViewController.m
//  iPOS
//
//  Created by Steven McCoole on 10/5/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "LookupOrderViewController.h"
#import "Order.h"
#import "PreviousOrder.h"
#import "AlertUtils.h"
#import "OrderListViewController.h"
#import "OrderItemsViewController.h"

#import "UIScreen+Helpers.h"

#define TEXT_FIELD_HEIGHT 40.0f

@interface LookupOrderViewController()
- (void)layoutView: (UIInterfaceOrientation) interfaceOrientation;
- (void)performSearch:(ExtUITextField *) textField;
- (void)handleClose:(id)sender;
@end

@implementation LookupOrderViewController

@synthesize closeBarButton;

#pragma mark Constructors
- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    // Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Lookup Order"];
	[self setTitle:@"Lookup Order"];
	
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
    
    orderIdFormatter = [[NSNumberFormatter alloc] init];
	[orderIdFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    // The T literal needs to be escaped as 'T' or the match will not work.
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    return self;

}

- (void)dealloc {
    [self setCloseBarButton:nil];
    
    [orderIdFormatter release];
    orderIdFormatter = nil;
    
    [dateFormatter release];
    dateFormatter = nil;
    
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
    
    lookupOrderIdField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupOrderIdField.textColor = [UIColor blackColor];
	lookupOrderIdField.borderStyle = UITextBorderStyleRoundedRect;
	lookupOrderIdField.textAlignment = UITextAlignmentCenter;
	lookupOrderIdField.clearsOnBeginEditing = NO;
	lookupOrderIdField.placeholder = @"Order By Id";
	lookupOrderIdField.tagName = @"LookupOrderId";
	lookupOrderIdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	lookupOrderIdField.keyboardType = UIKeyboardTypeNumberPad;
	[super addSearchAndCancelToolbarForTextField:lookupOrderIdField];
	[self.view addSubview:lookupOrderIdField];
	[lookupOrderIdField release];
    
    lookupOrderPhoneField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupOrderPhoneField.textColor = [UIColor blackColor];
	lookupOrderPhoneField.borderStyle = UITextBorderStyleRoundedRect;
	lookupOrderPhoneField.textAlignment = UITextAlignmentCenter;
	lookupOrderPhoneField.clearsOnBeginEditing = NO;
	lookupOrderPhoneField.placeholder = @"Order By Phone #";
	lookupOrderPhoneField.tagName = @"LookupOrderPhone";
	lookupOrderPhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	lookupOrderPhoneField.keyboardType = UIKeyboardTypeNumberPad;
    lookupOrderPhoneField.mask = @"999-999-9999";
	[super addSearchAndCancelToolbarForTextField:lookupOrderPhoneField];
	[self.view addSubview:lookupOrderPhoneField];
	[lookupOrderPhoneField release];
    
    self.closeBarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(handleClose:)] autorelease];
    [[self navigationItem] setRightBarButtonItem:self.closeBarButton];
}

- (void)layoutView: (UIInterfaceOrientation) interfaceOrientation {
    CGRect viewBounds = [UIScreen rectForScreenView: interfaceOrientation isNavBarVisible:YES];
    CGFloat textFieldWidth = viewBounds.size.width * 0.60f;
	CGFloat	textFieldSpacing = viewBounds.size.height * 0.10f;
    
    self.view.frame = viewBounds;
	
	lookupOrderIdField.frame = CGRectMake(0.0f, 0.0f, textFieldWidth, TEXT_FIELD_HEIGHT);
	lookupOrderIdField.center = CGPointMake((viewBounds.size.width / 2.0f), textFieldSpacing);
	
	lookupOrderPhoneField.frame = CGRectOffset(lookupOrderIdField.frame, 0.0f, textFieldSpacing + (TEXT_FIELD_HEIGHT / 2.0f));
    
    // UIKit bug.  Need to do this to re-center the placeholder text.
    lookupOrderIdField.textAlignment = UITextAlignmentLeft;
    lookupOrderIdField.textAlignment = UITextAlignmentCenter;
    
    // UIKit bug.  Need to do this to re-center the placeholder text.
    lookupOrderPhoneField.textAlignment = UITextAlignmentLeft;
    lookupOrderPhoneField.textAlignment = UITextAlignmentCenter;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	lookupOrderIdField.delegate = self;
    lookupOrderPhoneField.delegate = self;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Lookup Order" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
    [self layoutView: [UIApplication sharedApplication].statusBarOrientation];
    
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
    if ([textField.tagName isEqualToString:@"LookupOrderId"]) {
        lookupOrderPhoneField.text = nil;
    } else if ([textField.tagName isEqualToString:@"LookupOrderPhone"]) {
        lookupOrderIdField.text = nil;
    }
}

- (void) performSearch:(ExtUITextField *)textField {
    if (textField && [textField.text length] > 0) {
        NSArray *foundOrderList = nil;
        NSLog(@"Incoming text: %@", textField.text);
        
        if ([textField.tagName isEqualToString:@"LookupOrderId"] && [textField.text length] > 0) {
            NSNumber *orderIdInput = [orderIdFormatter numberFromString:textField.text];
            if (orderIdInput != nil) {
                // order comes back autoreleased
                Order *order = [facade lookupOrderByOrderId:orderIdInput];
                if (order != nil) {
                    // Prep and go to the order edit view controller
                    NSLog(@"Found Order: %@", order.orderId);
                    textField.text = nil;
                    [orderCart setPreviousOrder:order];
                    OrderItemsViewController *orderItemsViewController = [[OrderItemsViewController alloc] init];
                    [[self navigationController] pushViewController:orderItemsViewController animated:TRUE];
                    [orderItemsViewController release];
                } else {
                    [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Could not retrieve previous order.  Order Id: %@", orderIdInput] withTitle:@"iPOS"];
                }
            } else {
                [AlertUtils showModalAlertMessage:@"Please input a numeric order id." withTitle:@"iPOS"];
            }
    
        } else if ([textField.tagName isEqualToString:@"LookupOrderPhone"] && [textField.text length] > 0) {
            // Clean the dashes out of the phone number
            NSString *searchString = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            // See if we are at least a 10 digit number
            NSString *regex = @"[0-9]{10}";
            NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if ([regextest evaluateWithObject:searchString] == YES) {
                foundOrderList = [facade lookupOrderByPhoneNumber:searchString];
                if (foundOrderList && [foundOrderList count] > 0) {
                    if ([foundOrderList count] == 1) {
                        // Found one previous order, prep and go to order edit view controller
                        PreviousOrder *p = (PreviousOrder *)[foundOrderList objectAtIndex:0];
                        NSLog(@"Found one previous order: %@", p.orderId);
                        Order *order = [facade lookupOrderByOrderId:p.orderId];
                        if (order != nil) {
                            // Prep and go to the order edit view controller
                            NSLog(@"Single return from search by phone.  Found Order: %@", order.orderId);
                            [orderCart setPreviousOrder:order];
                            OrderItemsViewController *orderItemsViewController = [[OrderItemsViewController alloc] init];
                            [[self navigationController] pushViewController:orderItemsViewController animated:TRUE];
                            [orderItemsViewController release];
                        } else {
                            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Could not retrieve previous order.  Order Id: %@", p.orderId] withTitle:@"iPOS"];
                        }
                    } else {
                        NSLog(@"Found %d previous orders.", [foundOrderList count]);
                        // Sort the list of orders by order type and then date newest first.
                        NSArray *sortedOrderList = [foundOrderList sortedArrayUsingComparator:^(id a, id b)
                                                    {
                                                        NSComparisonResult statusSort = [((PreviousOrder *)a).orderTypeId compare:((PreviousOrder *)b).orderTypeId];
                                                        if (statusSort == NSOrderedSame) {
                                                            NSDate *dateA = [dateFormatter dateFromString:((PreviousOrder *)a).orderDate];
                                                            NSDate *dateB = [dateFormatter dateFromString:((PreviousOrder *)b).orderDate];
                                                            return [dateB compare:dateA];
                                                        } 
                                                        return statusSort;
                                                    }];
                        // Set the previous order list on the order cart singleton
                        [orderCart setPreviousOrderList:sortedOrderList];
                        
                        OrderListViewController *orderListController = [[OrderListViewController alloc] init];
                        [orderListController setSearchPhone:textField.text];
                        [[self navigationController] pushViewController:orderListController animated:TRUE];
                        [orderListController release];
                    }
                    // Clear the text field here because we will send the number to the list view controller above.
                    textField.text = nil;
                }
            } else {
                [AlertUtils showModalAlertMessage:@"Please enter a 10 digit phone number" withTitle:@"iPOS"];
            }
        }
    }
    
}

- (void)handleClose:(id)sender {
    // Switch the order cart back to working with a new order.
    [orderCart setNewOrder:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
