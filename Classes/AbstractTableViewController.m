//
//  CartItemsViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "AbstractTableViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "RIButtonItem.h"
#import "NSString+StringFormatters.h"
#import "AlertUtils.h"
#import "LayoutUtils.h"
#import "iPOSAppDelegate.h"
#import "SSCustomerViewController.h"

#import "UIScreen+Helpers.h"

#define CUST_SELECTED_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define NO_CUST_SELECTED_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]

#define CONT_SELECTED_COLOR [UIColor colorWithRed:100.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]
#define NO_CONT_SELECTED_COLOR [UIColor colorWithRed:50.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0f]

#define CUST_LABEL_HEIGHT 14.0f
#define CUST_LABEL_FONT_SIZE 12.0f

#define ORDER_TOOLBAR_HEIGHT 44.0f

#define ORDER_LABEL_FONT_SIZE 14.0f
#define ORDER_LABEL_HEIGHT 16.0f
#define ORDER_VALUE_WIDTH 80.0f
#define LABEL_SPACING 20.0f


@implementation AbstractTableViewController

@synthesize facade, selSheet, orderTable, toolBar, custButton, logoutButton, searchButton, emailButton;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	self.facade = [iPOSFacade sharedInstance];
    self.selSheet = [SelectionSheet sharedInstance];
    
    return self;
}

- (void)dealloc {
    [custButton release];
    [logoutButton release];
    [emailButton release];
    [searchButton release];
    //[projNameButton release];
    [toolBar release];
	[orderTable release];
    [selSheet release];
    
    [facade release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
	UIView *cartView = [[UIView alloc] initWithFrame:[self rectForNav]];
	cartView.backgroundColor = [UIColor whiteColor];
	[self setView:cartView];
	[cartView release];
	
    // Add the customer info
	custPhoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	custPhoneLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custPhoneLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:custPhoneLabel];
	[custPhoneLabel release];
	
	custNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	custNameLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custNameLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:custNameLabel];
	[custNameLabel release];
    
	custZipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	custZipLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	custZipLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:custZipLabel];
	[custZipLabel release];
    
    // Add the customer info
	contPhoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	contPhoneLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	contPhoneLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:contPhoneLabel];
	[contPhoneLabel release];
	
	contNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	contNameLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	contNameLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:contNameLabel];
	[contNameLabel release];
    
	contZipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	contZipLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	contZipLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:contZipLabel];
	[contZipLabel release];
    
	
	
    // Add the Order Items table
	self.orderTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.orderTable.backgroundColor = [UIColor clearColor];
	self.orderTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.orderTable.delegate = self;
	self.orderTable.dataSource = self;
	[self.view addSubview:self.orderTable];
	[self.orderTable release];
	
  	
	// Create a toolbar for the bottom of the screen
	self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	self.toolBar.barStyle = UIBarStyleBlack;
	
    self.searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] 
                                                         style:UIBarButtonItemStylePlain 
                                                        target:self 
                                                        action:@selector(searchforItem:)];
    self.searchButton.enabled = NO;
	
	//UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	tbFixed.width = 10.0f;
	
	self.custButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"customer.png"] 
                                                       style:UIBarButtonItemStylePlain 
                                                      target:self 
                                                      action:@selector(addOrEditCustomer:)];
    
    self.logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop_hand.png"]
                                                         style:UIBarButtonItemStylePlain 
                                                        target:self 
                                                        action:@selector(handleLogout:)];
    
    self.emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"email.png"]
                                                        style:UIBarButtonItemStylePlain 
                                                       target:self 
                                                       action:@selector(handleEmail:)];
    
    
    NSArray *toolbarBasic = [[[NSArray alloc] initWithObjects:self.logoutButton, nil] autorelease];
    
    [self.toolBar setItems:toolbarBasic];
    
    
    [self.view addSubview:self.toolBar];
    // [toolBar release];
	// Basic toolbar
    //self.toolbarBasic = [[[NSArray alloc] initWithObjects:searchButton, tbFixed, custButton, tbFixed, logoutButton, nil] autorelease];
    
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
    // Add itself as a delegate
    
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
    // Add this controller as a Linea Device Delegate
    //  [linea addDelegate:self];
	
	Customer *cust = selSheet.customer;
	if (cust == nil) {
		custPhoneLabel.backgroundColor = NO_CUST_SELECTED_COLOR;
		custNameLabel.backgroundColor = NO_CUST_SELECTED_COLOR;
		custNameLabel.text = @"No Customer";
		custZipLabel.backgroundColor = NO_CUST_SELECTED_COLOR;
	} else {
		custPhoneLabel.backgroundColor = CUST_SELECTED_COLOR;
		custPhoneLabel.text = [NSString formatAsUSPhone:cust.phoneNumber];
		custNameLabel.backgroundColor = CUST_SELECTED_COLOR;
		custNameLabel.text = (cust.lastName == nil) ? cust.firstName : cust.lastName;
		custZipLabel.backgroundColor = CUST_SELECTED_COLOR;
		custZipLabel.text = cust.address.zipPostalCode;
	}
    
    Customer *cont = selSheet.contractor;
	if (cont == nil) {
		contPhoneLabel.backgroundColor = NO_CONT_SELECTED_COLOR;
		contNameLabel.backgroundColor = NO_CONT_SELECTED_COLOR;
		contNameLabel.text = @"No Contractor";
		contZipLabel.backgroundColor = NO_CONT_SELECTED_COLOR;
	} else {
		contPhoneLabel.backgroundColor = CONT_SELECTED_COLOR;
		contPhoneLabel.text = [NSString formatAsUSPhone:cont.phoneNumber];
		contNameLabel.backgroundColor = CONT_SELECTED_COLOR;
		contNameLabel.text = (cont.lastName == nil) ? cont.firstName : cont.lastName;
		contZipLabel.backgroundColor = CONT_SELECTED_COLOR;
		contZipLabel.text = cont.address.zipPostalCode;
	}
    
    
	// Do this last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove this controller as a linea delegate
    //    [linea removeDelegate: self];
    
    // Do this at the end
	[super viewWillDisappear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
    
    CGRect custInfoRect = CGRectZero;
    CGRect contInfoRect = CGRectZero;
    CGRect orderTableRect = CGRectZero;
    CGRect toolbarRect = CGRectZero;
    
    CGRect custPhoneRect = CGRectZero;
    CGRect custNameRect = CGRectZero;
    CGRect custZipRect = CGRectZero;
    
    CGRect contPhoneRect = CGRectZero;
    CGRect contNameRect = CGRectZero;
    CGRect contZipRect = CGRectZero;
    
    // Calculate the layout rects (rows and cols)
    CGRectDivide(viewBounds, &custInfoRect, &orderTableRect, CUST_LABEL_HEIGHT, CGRectMinYEdge);
    
    
    CGRectDivide(custInfoRect, &custPhoneRect, &custNameRect, custInfoRect.size.width * 0.3, CGRectMinXEdge);
    CGRectDivide(custNameRect, &custNameRect, &custZipRect, custNameRect.size.width * 0.5, CGRectMinXEdge);
    
    CGRectDivide(orderTableRect, &contInfoRect, &orderTableRect, CUST_LABEL_HEIGHT, CGRectMinYEdge);
    
    CGRectDivide(contInfoRect, &contPhoneRect, &contNameRect, contInfoRect.size.width * 0.3, CGRectMinXEdge);
    CGRectDivide(contNameRect, &contNameRect, &contZipRect, contNameRect.size.width * 0.5, CGRectMinXEdge);
    
    CGRectDivide(orderTableRect, &toolbarRect, &orderTableRect, ORDER_TOOLBAR_HEIGHT, CGRectMaxYEdge);
    
    // Set the layout frames for customer, order table, totals, and toolbar
    custPhoneLabel.frame = custPhoneRect;
    custNameLabel.frame = custNameRect;
    custZipLabel.frame = custZipRect;
    
    contPhoneLabel.frame = contPhoneRect;
    contNameLabel.frame = contNameRect;
    contZipLabel.frame = contZipRect;
    
    
    orderTable.frame = orderTableRect;
    
    toolBar.frame = toolbarRect;
    
}

#pragma mark -
#pragma mark Button Event Methods

/*- (void) sendSheetAsEmail:(id)sender {
 UIAlertView *quoteAlert = [[UIAlertView alloc] init];
 quoteAlert.title = @"Send Quote?";
 quoteAlert.message = @"This will send the order as a quote and return to the login screen.  Are you sure you wish to do this?";
 quoteAlert.delegate = self;
 [quoteAlert addButtonWithTitle:@"Cancel"];
 [quoteAlert addButtonWithTitle:@"Send Quote"];
 [quoteAlert show];
 [quoteAlert release];
 }*/

- (void) handleLogout: (id) sender {
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    
    RIButtonItem *logoutItem = [RIButtonItem itemWithLabel:@"Exit"];
    logoutItem.action = ^
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    
    UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Message" 
                                                          message:@"Do you want to exit and go back to order lookup screen?" 
                                                 cancelButtonItem:cancelItem 
                                                 otherButtonItems:logoutItem, nil];
    
	[logoutAlert show];
	[logoutAlert release];
}

- (void) handleEmail: (id) sender {
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    
    RIButtonItem *saveItem = [RIButtonItem itemWithLabel:@"Save"];
    saveItem.action = ^
    {
        // DO some service to send
        [facade saveSheet:self.selSheet];
        // 
    };
    
    
    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Save?" 
                                                        message:@"This will save the selection sheet and give the option to email it to the customer.  Are you sure you want to do this?" 
                                               cancelButtonItem:cancelItem 
                                               otherButtonItems:saveItem, nil];
    
	[saveAlert show];
	[saveAlert release];
    
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
    /* UIAlertView *logoutAlert = [[UIAlertView alloc] init];
     logoutAlert.title = @"Save and Email?";
     logoutAlert.message = @"This will save the selection sheet and email it to the customer.  Are you sure you want to do this?";
     logoutAlert.delegate = self;
     [logoutAlert addButtonWithTitle:@"Cancel"];
     [logoutAlert addButtonWithTitle:@"Logout"];
     [logoutAlert show];
     [logoutAlert release];*/
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) addOrEditCustomer: (id) sender {
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    
    RIButtonItem *customerItem = [RIButtonItem itemWithLabel:@"Customer"];
    customerItem.action = ^
    {
        SSCustomerViewController *contViewController = [[SSCustomerViewController alloc] init];
        [[self navigationController] pushViewController:contViewController animated:TRUE];
        [contViewController release];
        
    };
    
    RIButtonItem *contractorItem = [RIButtonItem itemWithLabel:@"Contractor"];
    contractorItem.action = ^
    {
        SSCustomerViewController *contViewController = [[SSCustomerViewController alloc] init];
        contViewController.contractor = YES;
        [[self navigationController] pushViewController:contViewController animated:TRUE];
        [contViewController release];
        
    };
    
    UIActionSheet *custOrCont = [[UIActionSheet alloc] initWithTitle:@"sel.TILE" 
                                                    cancelButtonItem:cancelItem 
                                               destructiveButtonItem:nil
                                                    otherButtonItems:customerItem, contractorItem, nil];
    custOrCont.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [custOrCont showInView:self.view];
    [custOrCont release];
    
}


- (void) handleTitle: (id) sender {
    
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Project Name"
                                                     message:@"\n\n"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Save", nil];
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [prompt textFieldAtIndex:0].text = self.selSheet.projectName;
    [prompt show];
    [prompt release];
    
    // set cursor and show keyboard
    // [textField becomeFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Save"])
    {
        UITextField *newItem = [alertView textFieldAtIndex:0];
        
        NSLog(@"Project: %@\n", newItem.text);
        self.selSheet.projectName = newItem.text;
    }
}

/*#pragma mark -
 #pragma mark UIAlertView delegate
 - (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex {
 
 // Send quote modal.
 if ([anAlertView.title isEqualToString:@"Send Quote?"]) {
 // Check by titles rather than index since documentation suggests that different 
 // devices can set the indexes differently.
 NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
 if ([clickedButtonTitle isEqualToString:@"Send Quote"]) {
 Order *order = [orderCart getOrder];
 
 // Send off the order as a quote.
 if ([orderCart saveOrderAsQuote]) {
 // Go clear back to the login screen.
 [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Quote %@ was successfully created.", order.orderId] withTitle:@"iPOS"];
 [self.navigationController popToRootViewControllerAnimated:YES];
 }
 }
 }
 
 // Cancel and logout modal.
 if ([anAlertView.title isEqualToString:@"Cancel and Logout?"]) {
 NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
 if ([clickedButtonTitle isEqualToString:@"Logout"]) {
 [self.navigationController popToRootViewControllerAnimated:YES];
 }
 }
 
 // Other generic alerts will just fall through and dismiss with no other actions.
 }*/


#pragma mark -
#pragma mark UITableView delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	//if (self.multiEditMode && section == 0) {
	//	return self.editHeaderView;
	//}
	return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	//if (self.multiEditMode && section == 0) {
	//	return EDIT_HEADER_HEIGHT;
	//}
	return 0.0f;
}


/*
 - (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
 return UITableViewCellEditingStyleNone;
 }
 */

@end
