//
//  ItemsViewController.m
//  selSheet
//
//  Created by Joshua Walker on 2/11/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "ItemsViewController.h"
#import "Area.h"
#import "ItemTableCell.h"

@implementation ItemsViewController

@synthesize parentArea;

#pragma mark Constructors
- (id)initWithArea:(Area *)area 
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
    
    self.parentArea = area;
    
    return self;
}

- (void)dealloc {
    [parentArea release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    //self.searchButton.enabled = YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
    linea = [Linea sharedDevice];
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
    [linea addDelegate:self];
    // Add this controller as a Linea Device Delegate
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		// This is what shows up on the back button in the *next* controller.
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Areas" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        
        //self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(handleAddNote:)] autorelease];
        
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
    [linea removeDelegate: self];
    
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


-(void) handleAddNote:(id)sender {
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Add Note:"
                                                     message:@"\n\n"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Enter", nil];
    
    textField = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 50)];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setText:self.parentArea.note];
    [prompt insertSubview:textField atIndex:1];
    [textField release];
    
    // show the dialog box
    [prompt show];
    [prompt release];
    
    // set cursor and show keyboard
    // [textField becomeFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex > 0) {
        NSLog(@"Did save note");
        self.parentArea.note = textField.text;
    }
}



#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    [super layoutView:orientation];
}


#pragma mark -
#pragma mark UITableView delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.parentArea.items == nil) ? 0 : [self.parentArea.items count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    ItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCellIdentifier"];
    if (cell == nil) {
        cell = [[[ItemTableCell alloc] init] autorelease];
    }
    
    cell.textLabel.text = [[self.parentArea.items objectAtIndex:indexPath.row] description];
    //cell.item = [self.parentArea.items objectAtIndex:indexPath.row];
    return cell;
}



-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = [indexPath row];
        [self.parentArea.items removeObjectAtIndex:row];      
        [tableView reloadData];
    }
}*/


#pragma mark -
#pragma mark SearchItemView delegate
- (void) searchforItem:(id)sender {
	[linea removeDelegate:self];
    
    SearchItemView *searchOverlay = [[SearchItemView alloc] initWithFrame:self.view.bounds];
	[searchOverlay setDelegate:self];
	[self.view addSubview:searchOverlay];
	[searchOverlay release];
}

- (void) searchItem:(SearchItemView *)aSearchItemView withSku:(NSString *)aSku {
	
    NSLog(@"ItemsViewController: searchItem called");
	[aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
    
    //searchOverlay = nil;
	
	// Set the values and do the work here
	if (aSku && [aSku length] > 0) {
		ProductItem *item = [facade lookupProductItem:aSku];
        NSArray *foundItems = nil;
        
        if(item != nil && (![item.itemId isEqualToNumber:[NSNumber numberWithInt:0]] || ![item.sku isEqualToString:@""])) {
            foundItems = [NSArray arrayWithObject:item];
        }
        
        [self showAddItemOverlay:foundItems];        
	}
}

- (void) searchItem:(SearchItemView *)aSearchItemView withName: (NSString *) aName {
    [aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
    
    //searchOverlay = nil;
	
	// Set the values and do the work here
	if (aName && [aName length] > 0) {
		NSArray *foundItems = [facade lookupProductItemByName:aName];
        
        // If one item is returned, load the details for the item
        if (foundItems && [foundItems count] == 1) {
            ProductItem *foundItem = [facade lookupProductItem:((ProductItem *) [foundItems objectAtIndex:0]).sku];
            foundItems = [NSArray arrayWithObjects:foundItem, nil];
        }
        
        [self showAddItemOverlay:foundItems];        
	}
}

- (void) cancelSearchItem:(SearchItemView *)aSearchItemView {
	[aSearchItemView removeFromSuperview];
	[linea addDelegate:self];
    
    //searchOverlay = nil;
}

#pragma mark -
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    ProductItem *item = [facade lookupProductItem:barcode];
    NSArray *foundItems = nil;
    
    if(item != nil && (![item.itemId isEqualToNumber:[NSNumber numberWithInt:0]] || ![item.sku isEqualToString:@""])) {
		foundItems = [NSArray arrayWithObject:item];
	}
    
    [self showAddItemOverlay:foundItems];
}

#pragma mark -
#pragma mark AddItemViewDelegate
- (void) addItem:(SSAddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	ProductItem *item = addItemView.itemToAdd;
	
    /*[orderCart addItem:item withQuantity:quantity];
     if ([orderCart getOrder].errorList && [[orderCart getOrder].errorList count] > 0) {
     [AlertUtils showModalAlertForErrors:[orderCart getOrder].errorList withTitle:@"iPOS"];
     return;
     }*/
    item.itemQty = quantity;
    [self.parentArea.items addObject:item];
	
	[addItemView removeFromSuperview];
    //addItemOverlay = nil;
	
	[linea addDelegate:self];
	
	[self.orderTable reloadData];
    
    self.logoutButton.enabled = YES;
    
}

- (void) cancelAddItem:(SSAddItemView *)addItemView {
	[addItemView removeFromSuperview];
    
    self.logoutButton.enabled = YES;
    
	[linea addDelegate:self];
}

#pragma mark -
#pragma mark Show Add Item Overlay
- (void) showAddItemOverlay: (NSArray *) foundItems {
    if (foundItems && [foundItems count] > 0) {
        [linea removeDelegate:self];
        
        SSAddItemView *addItemOverlay = [[SSAddItemView alloc] initWithFrame:self.view.bounds];
        [addItemOverlay setViewDelegate:self];
        
        [self.view addSubview:addItemOverlay];
        
        if ([foundItems count] == 1) {
            [addItemOverlay setItemToAdd:(ProductItem *) [foundItems objectAtIndex:0]];
        } else {
            [addItemOverlay setProductItemList:foundItems];
        }
        
        // Disable the suspend button
        self.logoutButton.enabled = NO;
        
        [addItemOverlay release];
    } else {
        // [AlertUtils showModalAlertMessage:@"No item(s) found" withTitle:@"iPOS"];
    }
    
}

@end
