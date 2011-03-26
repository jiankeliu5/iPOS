//
//  CartItemsViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemsViewController.h"
#include "UIViewController+ViewControllerLayout.h"
#include "AlertUtils.h"

@interface CartItemsViewController()
- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment;
@end

@implementation CartItemsViewController

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Items"];
	[self setTitle:@"Items"];

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
	UIView *cartView = [[UIView alloc] initWithFrame:[self rectForNav]];
	cartView.backgroundColor = [UIColor whiteColor];
	[self setView:cartView];
	[cartView release];
	
	// Where we are in the layout.
	CGFloat cy = 0.0f;
	custLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.frame.size.width, CUST_LABEL_HEIGHT)];
	custLabel.font = [UIFont systemFontOfSize:CUST_LABEL_FONT_SIZE];
	[self.view addSubview:custLabel];
	[custLabel release];
	
	cy += CUST_LABEL_HEIGHT;
	
	orderTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.frame.size.width, ORDER_TABLE_HEIGHT) style:UITableViewStylePlain];
	orderTable.backgroundColor = [UIColor clearColor];
	orderTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.view addSubview:orderTable];
	[orderTable release];
	
	cy += ORDER_TABLE_HEIGHT;
	
	subTotalLabel = [self createOrderLabel:@"Subtotal:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:UITextAlignmentRight];
	[self.view addSubview:subTotalLabel];
	[subTotalLabel release];
	
	subTotalValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_LABEL_WIDTH, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:UITextAlignmentLeft];
	[self.view addSubview:subTotalValue];
	[subTotalValue release];
	
	cy += ORDER_LABEL_HEIGHT;
	
	taxLabel = [self createOrderLabel:@"Tax:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:UITextAlignmentRight];
	[self.view addSubview:taxLabel];
	[taxLabel release];
	
	taxValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_LABEL_WIDTH, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:UITextAlignmentLeft];
	[self.view addSubview:taxValue];
	[taxValue release];
	
	cy += ORDER_LABEL_HEIGHT;
	
	totalLabel = [self createOrderLabel:@"Total:" withRect:CGRectMake(0.0f, cy, ORDER_LABEL_WIDTH, ORDER_LABEL_HEIGHT) andAlignment:UITextAlignmentRight];
	[self.view addSubview:totalLabel];
	[totalLabel release];
	
	totalValue = [self createOrderLabel:@"$0.00" withRect:CGRectMake(ORDER_LABEL_WIDTH, cy, ORDER_VALUE_WIDTH, ORDER_VALUE_HEIGHT) andAlignment:UITextAlignmentLeft];
	[self.view addSubview:totalValue];
	[totalValue release];
	
	cy += ORDER_LABEL_HEIGHT;
	
	orderToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, cy, self.view.frame.size.width, ORDER_TOOLBAR_HEIGHT)];
	orderToolBar.barStyle = UIBarStyleBlack;
	UIImageView *spyGlassView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-magnify2.png"]];
	lookupSkuField = [[ExtUITextField alloc] initWithFrame:CGRectMake(LOOKUP_SKU_X, LOOKUP_SKU_Y, LOOKUP_SKU_WIDTH, LOOKUP_SKU_HEIGHT)];
	lookupSkuField.textColor = [UIColor blackColor];
	lookupSkuField.borderStyle = UITextBorderStyleRoundedRect;
	lookupSkuField.textAlignment = UITextAlignmentCenter;
	lookupSkuField.clearsOnBeginEditing = YES;
	lookupSkuField.placeholder = @"Look Up Item";
	lookupSkuField.tagName = @"LookupItem";
	lookupSkuField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	lookupSkuField.returnKeyType = UIReturnKeyGo;
	lookupSkuField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	[lookupSkuField setLeftView:spyGlassView];
	[lookupSkuField setLeftViewMode:UITextFieldViewModeAlways];
	[spyGlassView release];
	UIBarButtonItem *fieldItem = [[[UIBarButtonItem alloc] initWithCustomView:lookupSkuField] autorelease];
	[lookupSkuField release];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:fieldItem, flex, nil] autorelease];
	[orderToolBar setItems:items];
	[self.view addSubview:orderToolBar];
	[orderToolBar release];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
    
    // Add itself as a delegate
    linea = [Linea sharedDevice];
	
}

- (void)viewWillAppear:(BOOL)animated {
    // Add this controller as a Linea Device Delegate
    [linea addDelegate:self];
   
	
	// Do this last
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove this controller as a linea delegate
    [linea removeDelegate: self];
    
    // Do this at the end
	[super viewWillDisappear:animated];
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    ProductItem *item = [facade lookupProductItem:barcode];
    
    if (item == nil) {
        [AlertUtils showModalAlertMessage: @"Item not found"];
    } else {
		[linea removeDelegate:self];
		AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
		[overlay setViewDelegate:self];
		[self.view addSubview:overlay];
		[overlay setProductItem:item];
		[overlay release];
    }
}

#pragma mark -
#pragma mark AddItemViewDelegate
- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	// TODO: set up the order and push to the cart view
	NSMutableString *status = [[NSMutableString alloc] init];
	[status setString:@""];
	[status appendFormat:@"Would Order:  %.2f\n", [quantity doubleValue]];
	[status appendFormat:@"Units:  %@\n", unitOfMeasure];
	
	[addItemView removeFromSuperview];
	[linea addDelegate:self];
    
	[AlertUtils showModalAlertMessage: status];
	[status release];
    
}

- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
	[linea addDelegate:self];
}

#pragma mark -
#pragma mark UILabel creation
- (UILabel *) createOrderLabel:(NSString *)text withRect:(CGRect)rect andAlignment:(int)alignment {
	UILabel *label;
	label = [[UILabel alloc] initWithFrame:rect];
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = alignment;
	label.font = [UIFont boldSystemFontOfSize:ORDER_LABEL_FONT_SIZE];
	return label;
}

@end
