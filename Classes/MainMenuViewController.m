//
//  MainMenuViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AlertUtils.h"
#import "ProductItem.h"

#include "CustomerViewController.h"
#include "CartItemsViewController.h"

#import "UIScreen+Helpers.h"

#include "Order.h"
#include "iPOSAppDelegate.h"

#import "DemoTableController.h"

#import "FPPopoverController.h"
#import "FPDemoTableViewController.h"

#import "LookupSheetViewController.h"

#import "LookupOrderUtil.h"

#import "iPOSFacade.h"
#import "OrderCart.h"

#import "OrderItemsViewController.h"
#import "OrderListViewController.h"
#import "PreviousOrder.h"

#import "SendEmailViewController.h"
#import "MyInfoViewController.h"

@interface MainMenuViewController()
-(void) layoutView: (UIInterfaceOrientation) interfaceOrientation;
- (void) showAddItemOverlay: (NSArray *) foundItems;

- (void) customerPressed:(id)sender;
- (void) cartPressed:(id)sender;
- (void) handleLookupOrder:(id)sender;

- (void) performSearch: (ExtUITextField *) textField;
@end


@implementation MainMenuViewController

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"iPOS"];
	[self setTitle:@"iPOS"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
	
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
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    ProductItem *item = [facade lookupProductItem:barcode];
    NSArray *foundItemList = nil;
    
    if(item != nil && (![item.itemId isEqualToNumber:[NSNumber numberWithInt:0]] || ![item.sku isEqualToString:@""])) {
        foundItemList = [NSArray arrayWithObject: item];
    }
    
    [self showAddItemOverlay:foundItemList];

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
	bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:bgView];
	[bgView release];
	
	scanItemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	scanItemLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	scanItemLabel.textColor = [UIColor blackColor];
	scanItemLabel.text = @"-- SCAN ITEM --";
	scanItemLabel.textAlignment = NSTextAlignmentCenter;
    
	[self.view addSubview:scanItemLabel];
	[scanItemLabel release];
    
    //Enning Tang add Version Label 10/23/2012
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VersionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	VersionLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	VersionLabel.textColor = [UIColor blackColor];
	VersionLabel.text = [NSString stringWithFormat:@"%@%@", @"ver.", (NSString *) [bundle objectForInfoDictionaryKey:@"currentVersion"]];
	VersionLabel.textAlignment = NSTextAlignmentCenter;
    
	[self.view addSubview:VersionLabel];
	[VersionLabel release];
	
    lookupItemNameField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupItemNameField.textColor = [UIColor blackColor];
	lookupItemNameField.borderStyle = UITextBorderStyleRoundedRect;
	lookupItemNameField.textAlignment = NSTextAlignmentCenter;
	lookupItemNameField.clearsOnBeginEditing = NO;
	lookupItemNameField.placeholder = @"Item By Name";
	lookupItemNameField.tagName = @"LookupItemName";
    lookupItemNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    lookupItemNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    lookupItemNameField.returnKeyType = UIReturnKeySearch;
	lookupItemNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

	[super addSearchAndCancelToolbarForTextField:lookupItemNameField];
	[self.view addSubview:lookupItemNameField];
	[lookupItemNameField release];
    
	lookupItemSkuField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupItemSkuField.textColor = [UIColor blackColor];
	lookupItemSkuField.borderStyle = UITextBorderStyleRoundedRect;
	lookupItemSkuField.textAlignment = NSTextAlignmentCenter;
	lookupItemSkuField.clearsOnBeginEditing = NO;
	lookupItemSkuField.placeholder = @"Item By SKU";
	lookupItemSkuField.tagName = @"LookupItemSku";
	lookupItemSkuField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	lookupItemSkuField.keyboardType = UIKeyboardTypeNumberPad;
	[super addSearchAndCancelToolbarForTextField:lookupItemSkuField];
	[self.view addSubview:lookupItemSkuField];
	[lookupItemSkuField release];
	
	customerButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[customerButton setTitle:@"Customer" forState:UIControlStateNormal];
	[customerButton setupAsBlackButton];
	[self.view addSubview:customerButton];
	
	cartButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[cartButton setTitle:@"Order Cart" forState:UIControlStateNormal];
	[cartButton setupAsBlackButton];
	[self.view addSubview:cartButton];
    
    orderLookupButton = [[UIBarButtonItem alloc] initWithTitle:@"Orders" style:UIBarButtonItemStyleBordered target:self action:@selector(handleLookupOrder:)];
	[[self navigationItem] setRightBarButtonItem:orderLookupButton];
    [orderLookupButton release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	lookupItemNameField.delegate = self;
    lookupItemSkuField.delegate = self;
    
	[customerButton addTarget:self action:@selector(customerPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartButton addTarget:self action:@selector(cartPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Enning Tang add menu button 5/1/2013
    
    NSLog(@"HHTab here");
    
    //NSArray *titles = [NSArray arrayWithObjects:@"New Order", @"Lookup Orders", @"My Orders", @"Selections", @"Customer", @"My Info", nil];
	//NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:[titles count]];
    
    UIImage *buttonImage = [UIImage imageNamed:@"list.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    
    button.frame = CGRectMake(0, 0, buttonImage.size.width + 20.0f, buttonImage.size.height);
    
    [button addTarget:self action:@selector(popover:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    [customBarItem release];
    //============================
	
    // Add itself as a delegate
    linea = [Linea sharedDevice];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {

    // Add this controller as a Linea Device Delegate
    [linea addDelegate:self];

    [self layoutView:[[UIApplication sharedApplication] statusBarOrientation]];
	
	// Do this last
	[super viewWillAppear:animated];
}
	 
- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    // Remove this controller as a linea delegate
    [linea removeDelegate: self];
	
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




#pragma mark -
#pragma mark AddItemViewDelegate
- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
    addItemOverlay = nil;
    
	[linea addDelegate:self];
	[self addKeyboardListeners];
}

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	ProductItem *item = addItemView.itemToAdd;
    
    [orderCart addItem:item withQuantity:quantity];
    if ([orderCart getOrder].errorList && [[orderCart getOrder].errorList count] > 0) {
        [AlertUtils showModalAlertForErrors:[orderCart getOrder].errorList withTitle:@"iPOS"];
        return;
    }
    
    [addItemView removeFromSuperview];
    addItemOverlay = nil;

    CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
}

#pragma mark -
#pragma mark UIButton callbacks
- (void)customerPressed:(id)sender {
	[linea removeDelegate:self];
	[self removeKeyboardListeners];
    CustomerViewController *customerViewController = [[CustomerViewController alloc] init];
	[[self navigationController] pushViewController:customerViewController animated:TRUE];
	[customerViewController release];
}

- (void)cartPressed:(id)sender {
	[linea removeDelegate:self];
	[self removeKeyboardListeners];
    CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
}

- (void)handleLookupOrder:(id)sender {
    // Switch the order cart over to looking at existing orders rather than a new order.
    [orderCart setNewOrder:NO];
    iPOSAppDelegate *app = (iPOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *orderNav = [app orderNavigationController];
    [orderNav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:orderNav animated:YES completion:nil];
}

#pragma mark -
#pragma mark Private Methods
- (void) layoutView:(UIInterfaceOrientation)interfaceOrientation {
    [linea addDelegate:self];
    
    CGRect viewBounds = [UIScreen rectForScreenView:interfaceOrientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
    
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
    
    scanItemLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
    scanItemLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
    
    //Enning Tang add version label 10/23/2012
    VersionLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
    VersionLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing + 300);
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        labelButtonSpacing = labelButtonSpacing + 4.0;
    } 
    
    lookupItemNameField.frame = CGRectOffset(scanItemLabel.frame, 0.0f, labelButtonSpacing);
    lookupItemSkuField.frame = CGRectOffset(lookupItemNameField.frame, 0.0f, labelButtonSpacing);
    
    // Change to work from lookupOrderField position when that is implemented
    customerButton.frame = CGRectOffset(lookupItemSkuField.frame, 0.0f, labelButtonSpacing);
    
    cartButton.frame = CGRectOffset(customerButton.frame, 0.0f, labelButtonSpacing);
    
    lookupItemNameField.textAlignment = NSTextAlignmentLeft;
    lookupItemSkuField.textAlignment = NSTextAlignmentLeft;
    lookupItemNameField.textAlignment = NSTextAlignmentCenter;
    lookupItemSkuField.textAlignment = NSTextAlignmentCenter;
    
    // Layout add item overlay (adjusting frame triggers a layoutSubviews of add item overlay)
    if (addItemOverlay) {
        addItemOverlay.frame = viewBounds;
    }
}

- (void) showAddItemOverlay:(NSArray *)foundItems {
    if (foundItems && [foundItems count] > 0) {
        [linea removeDelegate:self];
        [self removeKeyboardListeners];
        
        addItemOverlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
        [addItemOverlay setViewDelegate:self];
        
        [self.view addSubview:addItemOverlay];
        
        if ([foundItems count] == 1) {
            [addItemOverlay setItemToAdd:(ProductItem *) [foundItems objectAtIndex:0]];
        } else {
            [addItemOverlay setProductItemList:foundItems];
        }
        
        [addItemOverlay release];
    } else {
        [AlertUtils showModalAlertMessage:@"No item(s) found" withTitle:@"iPOS"];
    }
}

- (void) performSearch:(ExtUITextField *)textField {
    if (textField && [textField.text length] > 0) {
        NSString *lookupText = textField.text;
        NSArray *foundItemList = nil;

        if ([textField.tagName isEqualToString:@"LookupItemSku"] && [textField.text length] > 0) {
            // Call the service and display the overlay view
            ProductItem *item = [facade lookupProductItem:lookupText];
            
            if(item != nil && (![item.itemId isEqualToNumber:[NSNumber numberWithInt:0]] || ![item.sku isEqualToString:@""])) {
                foundItemList = [NSArray arrayWithObject:item];
                textField.text = nil;
            }
            
            [self showAddItemOverlay:foundItemList];
        } else if ([textField.tagName isEqualToString:@"LookupItemName"] && [textField.text length] > 0) {
            // Call the service to get a list of items
            foundItemList = [facade lookupProductItemByName:lookupText];
            
            if (foundItemList && [foundItemList count] > 0) {
                textField.text = nil;
            } 
            
            // If one item is returned, load the details for the item
            if (foundItemList && [foundItemList count] == 1) {
                ProductItem *foundItem = [facade lookupProductItem:((ProductItem *) [foundItemList objectAtIndex:0]).sku];
                foundItemList = [NSArray arrayWithObjects:foundItem, nil];
            }
            
            [self showAddItemOverlay:foundItemList];
        }
    }
}

-(IBAction)popover:(id)sender
{
    //NSLog(@"popover retain count: %d",[popover retainCount]);
    
    SAFE_ARC_RELEASE(popover); popover=nil;
    
    //the controller we want to present as a popover
    DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
    controller.delegate = self;
    popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.tint = FPPopoverDefaultTint;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover.contentSize = CGSizeMake(300, 500);
    }
    else {
        popover.contentSize = CGSizeMake(200, 300);
    }
    //sender is the UIButton view
    popover.arrowDirection = FPPopoverArrowDirectionAny;
    [popover presentPopoverFromView:sender];
    
}

- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

-(IBAction)navControllerPopover:(id)sender
{
    SAFE_ARC_RELEASE(popover); popover=nil;
    
    //the controller we want to present as a popover
    DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:controller];
    SAFE_ARC_RELEASE(controller); controller=nil;
    
    popover = [[FPPopoverController alloc] initWithViewController:nc];
    popover.tint = FPPopoverDefaultTint;
    popover.contentSize = CGSizeMake(300, 500);
    [popover presentPopoverFromView:sender];
    
    //    CGRect nc_bar_frame = nc.navigationBar.frame;
    //    nc_bar_frame.origin.y = 0;
    //    nc.navigationBar.frame = nc_bar_frame;
}


-(IBAction)goToTableView:(id)sender
{
    FPDemoTableViewController *controller = [[FPDemoTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)selectedTableRow:(NSUInteger)rowNum
{
    NSLog(@"SELECTED ROW %d",rowNum);
    [popover dismissPopoverAnimated:YES];
    if (rowNum == 0) //New Order
    {
        if ([[orderCart getOrder] getOrderItems].count != 0)
        {
            NSLog(@"do you want to discard current order?");
            NSString *message = [NSString stringWithFormat:@"Do you want to DISCARD current order and start a NEW order?"];
            UIAlertView *quoteAlert = [[UIAlertView alloc] init];
            quoteAlert.title = @"Start New Order?";
            quoteAlert.message = message;
            quoteAlert.delegate = self;
            [quoteAlert addButtonWithTitle:@"Cancel"];
            [quoteAlert addButtonWithTitle:@"Yes"];
            [quoteAlert show];
            [quoteAlert release];
        }else
        {
            [linea removeDelegate:self];
            [self removeKeyboardListeners];
            CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
            [UIView  beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationDuration:0.00];
            [self.navigationController pushViewController:cartViewController animated:NO];
            [UIView setAnimationTransition:UIViewAnimationOptionTransitionCrossDissolve forView:self.navigationController.view cache:NO];
            [UIView commitAnimations];
            [cartViewController release];
        }
    }
    if (rowNum == 1) //Lookup Order
    {
        // Switch the order cart over to looking at existing orders rather than a new order.
        [orderCart setNewOrder:NO];
        iPOSAppDelegate *app = (iPOSAppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *orderNav = [app orderNavigationController];
        [orderNav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:orderNav animated:YES completion:nil];
    }
    if (rowNum == 2) //Current Order
    {
        [linea removeDelegate:self];
        [self removeKeyboardListeners];
        CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.00];
        [self.navigationController pushViewController:cartViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
        [cartViewController release];
    }
    if (rowNum == 3) //Customer
    {
        [linea removeDelegate:self];
        [self removeKeyboardListeners];
        CustomerViewController *customerViewController = [[CustomerViewController alloc] init];
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.50];
        [self.navigationController pushViewController:customerViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
        [customerViewController release];
    }
    if (rowNum == 4) //Selections
    {
        //[linea removeDelegate:self];
        [self removeKeyboardListeners];
        LookupSheetViewController *selectionViewController = [[LookupSheetViewController alloc] init];
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.50];
        [self.navigationController pushViewController:selectionViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
        [selectionViewController release];
    }
    /*if (rowNum == 5) //My Info
    {
        //[linea removeDelegate:self];
        //[self removeKeyboardListeners];
        MyInfoViewController *myInfoViewController = [[MyInfoViewController alloc] init];
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.50];
        [self.navigationController pushViewController:myInfoViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
        [myInfoViewController release];
        

        
    }*/
    if (rowNum == 5) //Send E-mail
    {
        [linea removeDelegate:self];
        [self removeKeyboardListeners];
        SendEmailViewController *sendEmailViewController = [[SendEmailViewController alloc] init];
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.50];
        [self.navigationController pushViewController:sendEmailViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
        [sendEmailViewController release];
    }
    if (rowNum == 6) //Logout
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex {
    
    if ([anAlertView.title isEqualToString:@"Start New Order?"]) {
        NSLog(@"Got alert");
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Yes"]) {
            [orderCart clearAllCart];
            [orderCart setNewOrder:YES];
            [linea removeDelegate:self];
            [self removeKeyboardListeners];
            CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
            [UIView  beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.00];
            [self.navigationController pushViewController:cartViewController animated:NO];
            [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
            [UIView commitAnimations];
            [cartViewController release];
		}
	}
    
	// Other generic alerts will just fall through and dismiss with no other actions.
}

- (IBAction)callMenu:(id)sender{
    NSLog(@"Call Menu called");
}
@end
