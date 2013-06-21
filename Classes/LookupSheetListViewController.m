//
//  LookupSheetListViewController.m
//  selSheet
//
//  Created by Enning Tang on 8/1/12.
//  Copyright (c) 2012 TileShop. All rights reserved.
//

#import "LookupSheetListViewController.h"
#import "RoomsViewController.h"
#import "SSCartItemsViewController.h"
#import "SSLookupCustomerViewController.h"



#define TEXT_FIELD_HEIGHT 40.0f

@interface LookupSheetListViewController()
- (void) presscheckout:(id)sender;

@end


@implementation LookupSheetListViewController

@synthesize tableData;
@synthesize theTableView;
@synthesize checkoutbutton;
@synthesize customernamefield;
@synthesize customerphonefield;
@synthesize checkoutResponseString;
//@synthesize checkoutResponseData;
@synthesize itemset = _itemset;
@synthesize itemDescription;
@synthesize itemQty;
@synthesize itemSku;
@synthesize itemUOM;


#pragma mark Constructors
- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    // Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Sheet List"];
	[self setTitle:@"Sheet List"];
	
    facade = [iPOSFacade sharedInstance];
	selSheet = [SelectionSheet sharedInstance];
    orderCart = [SSOrderCart sharedInstance];
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //CGRect toolBarRect, tableRect;
    //CGRectDivide(self.view.frame, &toolBarRect, &tableRect, 44.0, CGRectMinYEdge);
    
    UIAlertView *longPress = [[UIAlertView alloc] init];
    longPress.title = @"Message";
    longPress.message = @"Long press for checkout";
    [longPress addButtonWithTitle:@"OK"];
    [longPress show];
    [longPress release];
    
    self.theTableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain] autorelease];
	self.theTableView.backgroundColor = [UIColor whiteColor];
	self.theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.theTableView.tableHeaderView.hidden = YES;
	self.theTableView.delegate = self;
	self.theTableView.dataSource = self;
	[self.view addSubview:self.theTableView];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    [self.theTableView addGestureRecognizer:lpgr];
    [lpgr release];
    
    checkoutbutton = [[UIBarButtonItem alloc] initWithTitle:@"Checkout" style:UIBarButtonItemStyleBordered target:self action:@selector(presscheckout:)];
	//[[self navigationItem] setRightBarButtonItem:checkoutbutton];
    [checkoutbutton release];
    
    
    /* UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:toolBarRect];
     //toolBar.barStyle = UIBarStyleBlack;
     
     UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] 
     initWithTitle:@"Cancel"
     style:UIBarButtonItemStyleBordered 
     target:self 
     action:@selector(dismissView)] autorelease];
     
     NSArray *toolbarItems = [[[NSArray alloc] initWithObjects:cancelButton, nil] autorelease];
     
     [toolBar setItems:toolbarItems];
     
     
     [self.view addSubview:toolBar];
     [toolBar release];
     */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    //CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    //self.view.frame = viewBounds;
    //self.theTableView.frame = self.view.frame;
    
}

-(void) dismissView {
    //[self.delegate didDismissModalView];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Count %d",[self.tableData count]);
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"AddListIdentifier";
    UITableViewCell *cell = [tableView
							 dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleSubtitle 
				 reuseIdentifier:MyIdentifier] autorelease];
    }
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // The T literal needs to be escaped as 'T' or the match will not work.
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSDateFormatter *dateStringFormatter = [[NSDateFormatter alloc] init];
    // The T literal needs to be escaped as 'T' or the match will not work.
    [dateStringFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //===================================================================bind data to cell
    //NSDictionary *data = [self.tableData objectAtIndex:indexPath.row];
    NSDictionary *dict = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ | %@",[dict objectForKey:@"project"], [dict objectForKey:@"client"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@",[dateStringFormatter stringFromDate:[dateFormatter dateFromString:[dict objectForKey:@"date"]]], [dict objectForKey:@"contractor"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.tableData objectAtIndex:indexPath.row];
    
	//NSDictionary *selected = [self.tableData objectAtIndex:indexPath.row];
	selSheet = [facade lookupSheetById:[dict objectForKey:@"projUid"]];
    [facade lookupSelection:[dict objectForKey:@"projUid"]];
    
    NSLog(@"SelSheet is %@",selSheet);
    
    RoomsViewController *roomsViewController = [[RoomsViewController alloc] init];
	[[self navigationController] pushViewController:roomsViewController animated:TRUE];
	[roomsViewController release];
    
	[self.theTableView deselectRowAtIndexPath:indexPath animated:YES]; 
    //[self.delegate addFromListViewController:self didAddItem:indexPath.row];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [theTableView release], theTableView = nil;
    [tableData release];
    [super dealloc];
}

//
//
//LONG PRESS
//
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gestureRecognizer locationInView:self.theTableView];
        
        NSIndexPath *indexPath = [self.theTableView indexPathForRowAtPoint:p];
        if (indexPath == nil)
        {
            NSLog(@"Long press on table view but not a row");
        }else {
            NSLog(@"Long press on table view at row %d",indexPath.row);
            NSDictionary *dict = [self.tableData objectAtIndex:indexPath.row];
            checkoutResponseString = [facade lookupSelection:[dict objectForKey:@"projUid"]];
            
            //Start Parsing XML
            
            ItemSet *itemset = [[[ItemSet alloc]init]autorelease];
            
            NSMutableArray *itemarray = [[NSMutableArray alloc]init];
            
            CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:checkoutResponseString options:0 error:nil] autorelease];
            CXMLElement *root = [xmlParser rootElement];
            
            for (CXMLElement *rooms in [root elementsForName:@"Rooms"]) {
                for (CXMLElement *room in [rooms elementsForName:@"Room"]){
                    for (CXMLElement *areas in [room elementsForName:@"Areas"]){
                        for (CXMLElement *area in [areas elementsForName:@"Area"]){
                            for (CXMLElement *items in [area elementsForName:@"Items"]){
                                [itemarray addObject:items.XMLString];
                            }
                        }
                    }
                }
            }
            
            for (int i = 0; i<itemarray.count; i++){
                NSString *str = [itemarray objectAtIndex:i];
                str = [str stringByReplacingOccurrencesOfString:@"i:nil" withString:@"none"];
                NSLog(@"From Item Array, index = %@", [NSString stringWithFormat:@"%d", i]);
                GDataXMLDocument *itemxmlstring = [[GDataXMLDocument alloc]initWithXMLString:str options:0 error:nil];
                NSArray *eachitem = [itemxmlstring.rootElement elementsForName:@"Item"]; //Enning Tang deal with potential memory leak
                for (GDataXMLElement *each in eachitem){
                    NSString *ItemID;
                    NSString *StoreID;
                    NSString *ItemNumber;
                    NSString *ItemDescription;
                    NSString *ItemTypeID;
                    NSString *StockingCode;
                    NSString *ItemStatusCode;
                    NSString *ItemQty;
                    NSString *PrimaryUOM;
                    //Enning Tang Add ShipToStoreID 10/29/2012
                    NSString *ShipToStoreID;
                    
                    //ItemID
                    NSArray *ItemIDs = [each elementsForName:@"ItemID"];
                    if (ItemIDs.count > 0){
                        GDataXMLElement *xmlitemid = (GDataXMLElement *)[ItemIDs objectAtIndex:0];
                        ItemID = xmlitemid.stringValue;
                        //NSLog(@"ItemID:%@----",ItemID);
                    }else continue;
                    
                    //StoreID
                    NSArray *StoreIDs = [each elementsForName:@"StoreID"];
                    if (StoreIDs.count > 0){
                        GDataXMLElement *xmlstoreid = (GDataXMLElement *)[StoreIDs objectAtIndex:0];
                        StoreID = xmlstoreid.stringValue;
                        //NSLog(@"StoreID:%@",StoreID);
                    }else continue;
                    
                    //ItemNumber
                    NSArray *ItemNumbers = [each elementsForName:@"ItemNumber"];
                    if (ItemNumbers.count > 0){
                        GDataXMLElement *xmlitemnumber = (GDataXMLElement *)[ItemNumbers objectAtIndex:0];
                        ItemNumber = xmlitemnumber.stringValue;
                        //NSLog(@"ItemNumber:%@",ItemNumber);
                    }else continue;
                    
                    //ItemDescription
                    NSArray *ItemDescriptions = [each elementsForName:@"ItemDescription"];
                    if (ItemDescriptions.count > 0){
                        GDataXMLElement *xmlitemdescription = (GDataXMLElement *)[ItemDescriptions objectAtIndex:0];
                        ItemDescription = xmlitemdescription.stringValue;
                        //NSLog(@"ItemDescription:%@",ItemDescription);
                    }else continue;
                    
                    //ItemTypeID
                    NSArray *ItemTypeIDs = [each elementsForName:@"ItemTypeID"];
                    if (ItemTypeIDs.count > 0){
                        GDataXMLElement *xmlitemtypeid = (GDataXMLElement *)[ItemTypeIDs objectAtIndex:0];
                        ItemTypeID = xmlitemtypeid.stringValue;
                        //NSLog(@"ItemTypeID:%@",ItemTypeID);
                    }else continue;
                    
                    //StockingCode
                    NSArray *StockingCodes = [each elementsForName:@"StockingCode"];
                    if (StockingCodes.count > 0){
                        GDataXMLElement *xmlstockingcode = (GDataXMLElement *)[StockingCodes objectAtIndex:0];
                        StockingCode = xmlstockingcode.stringValue;
                        //NSLog(@"StockingCode:%@",StockingCode);
                    }else continue;
                    
                    //ItemStatusCode
                    NSArray *ItemStatusCodes = [each elementsForName:@"ItemStatusCode"];
                    if (ItemStatusCodes.count > 0){
                        GDataXMLElement *xmlitemstatuscode = (GDataXMLElement *)[ItemStatusCodes objectAtIndex:0];
                        ItemStatusCode = xmlitemstatuscode.stringValue;
                        //NSLog(@"ItemStatusCode:%@",ItemStatusCode);
                    }else continue;
                    
                    //ItemQty
                    NSArray *ItemQtys = [each elementsForName:@"ItemQty"];
                    if (ItemQtys.count > 0){
                        GDataXMLElement *xmlitemqty = (GDataXMLElement *)[ItemQtys objectAtIndex:0];
                        ItemQty = xmlitemqty.stringValue;
                        //NSLog(@"ItemQty:%@",ItemQty);
                    }else continue;
                    
                    //PrimaryUOM
                    NSArray *PrimaryUOMs = [each elementsForName:@"PrimaryUOM"];
                    if (PrimaryUOMs.count > 0){
                        GDataXMLElement *xmlprimaryuom = (GDataXMLElement *)[PrimaryUOMs objectAtIndex:0];
                        PrimaryUOM = xmlprimaryuom.stringValue;
                        //NSLog(@"PrimaryUOM:%@",PrimaryUOM);
                    }else continue;
                    
                    ShipToStoreID = StoreID;
                    
                    if ([ItemDescription length] != 0){
                        Items *item = [[[Items alloc]init:ItemID StoreID:StoreID ItemNumber:ItemNumber ItemDescription:ItemDescription ItemTypeID:ItemTypeID StockingCode:StockingCode ItemStatusCode:ItemStatusCode ItemQty:ItemQty PrimaryUOM:PrimaryUOM ShipToStoreID:ShipToStoreID]autorelease];
                        [itemset.items addObject:item];
                    }else continue;
                }
            }
            
            for (int j=0; j<itemset.items.count; j++)
            {
                Items *obj = [itemset.items objectAtIndex:j];
                if ([obj.ItemDescription length] == 0)
                {
                    NSLog(@"OBJ IS NULL");
                }
                else {
                    NSLog(@"OBJ:%@",obj.ItemDescription);
                }
            }
            
            
            SSCartItemsViewController *cartViewController = [[SSCartItemsViewController alloc] initwithItems:itemset];
            cartViewController.getitems = itemset;
            [[self navigationController] pushViewController:cartViewController animated:TRUE];
            [cartViewController release];
        }
    }
}


///
//
//
///
//
//

- (void)presscheckout:(id)sender {
    // Switch the order cart over to looking at existing orders rather than a new order.
    //[orderCart setNewOrder:NO];
    //iPOSAppDelegate *app = (iPOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    //UINavigationController *orderNav = [app orderNavigationController];
    //[orderNav setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    //[self presentModalViewController:orderNav animated:YES];
    if ([checkoutbutton.title isEqual: @"Checkout"])
    {
        [theTableView setEditing:YES animated:YES];
        [theTableView reloadData];
        checkoutbutton.title = @"Done";
    }
    else if ([checkoutbutton.title isEqual: @"Done"])
    {
        [theTableView setEditing:NO animated:YES];
        [theTableView reloadData];
        checkoutbutton.title = @"Checkout";
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Checkout";
}

//submit checkout
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"1" message:@"2" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    //[alert show];
    NSDictionary *dict = [self.tableData objectAtIndex:indexPath.row];
    checkoutResponseString = [facade lookupSelection:[dict objectForKey:@"projUid"]];
    
    //Start Parsing XML
    
    ItemSet *itemset = [[[ItemSet alloc]init]autorelease];
    
    NSMutableArray *itemarray = [[NSMutableArray alloc]init];
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:checkoutResponseString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    for (CXMLElement *rooms in [root elementsForName:@"Rooms"]) {
        for (CXMLElement *room in [rooms elementsForName:@"Room"]){
            for (CXMLElement *areas in [room elementsForName:@"Areas"]){
                for (CXMLElement *area in [areas elementsForName:@"Area"]){
                    for (CXMLElement *items in [area elementsForName:@"Items"]){
                        [itemarray addObject:items.XMLString];
                    }
                }
            }
        }
    }
    
    for (int i = 0; i<itemarray.count; i++){
        NSString *str = [itemarray objectAtIndex:i];
        str = [str stringByReplacingOccurrencesOfString:@"i:nil" withString:@"none"];
        NSLog(@"From Item Array, index = %@", [NSString stringWithFormat:@"%d", i]);
        GDataXMLDocument *itemxmlstring = [[GDataXMLDocument alloc]initWithXMLString:str options:0 error:nil];
        NSArray *eachitem = [itemxmlstring.rootElement elementsForName:@"Item"];
        for (GDataXMLElement *each in eachitem){
            NSString *ItemID;
            NSString *StoreID;
            NSString *ItemNumber;
            NSString *ItemDescription;
            NSString *ItemTypeID;
            NSString *StockingCode;
            NSString *ItemStatusCode;
            NSString *ItemQty;
            NSString *PrimaryUOM;
            //Enning Tang Add ShipToStoreID 10/29/2012
            NSString *ShipToStoreID;
            
            //ItemID
            NSArray *ItemIDs = [each elementsForName:@"ItemID"];
            if (ItemIDs.count > 0){
                GDataXMLElement *xmlitemid = (GDataXMLElement *)[ItemIDs objectAtIndex:0];
                ItemID = xmlitemid.stringValue;
                //NSLog(@"ItemID:%@----",ItemID);
            }else continue;
            
            //StoreID
            NSArray *StoreIDs = [each elementsForName:@"StoreID"];
            if (StoreIDs.count > 0){
                GDataXMLElement *xmlstoreid = (GDataXMLElement *)[StoreIDs objectAtIndex:0];
                StoreID = xmlstoreid.stringValue;
                //NSLog(@"StoreID:%@",StoreID);
            }else continue;
            
            //ItemNumber
            NSArray *ItemNumbers = [each elementsForName:@"ItemNumber"];
            if (ItemNumbers.count > 0){
                GDataXMLElement *xmlitemnumber = (GDataXMLElement *)[ItemNumbers objectAtIndex:0];
                ItemNumber = xmlitemnumber.stringValue;
                //NSLog(@"ItemNumber:%@",ItemNumber);
            }else continue;
            
            //ItemDescription
            NSArray *ItemDescriptions = [each elementsForName:@"ItemDescription"];
            if (ItemDescriptions.count > 0){
                GDataXMLElement *xmlitemdescription = (GDataXMLElement *)[ItemDescriptions objectAtIndex:0];
                ItemDescription = xmlitemdescription.stringValue;
                //NSLog(@"ItemDescription:%@",ItemDescription);
            }else continue;
            
            //ItemTypeID
            NSArray *ItemTypeIDs = [each elementsForName:@"ItemTypeID"];
            if (ItemTypeIDs.count > 0){
                GDataXMLElement *xmlitemtypeid = (GDataXMLElement *)[ItemTypeIDs objectAtIndex:0];
                ItemTypeID = xmlitemtypeid.stringValue;
                //NSLog(@"ItemTypeID:%@",ItemTypeID);
            }else continue;
            
            //StockingCode
            NSArray *StockingCodes = [each elementsForName:@"StockingCode"];
            if (StockingCodes.count > 0){
                GDataXMLElement *xmlstockingcode = (GDataXMLElement *)[StockingCodes objectAtIndex:0];
                StockingCode = xmlstockingcode.stringValue;
                //NSLog(@"StockingCode:%@",StockingCode);
            }else continue;
            
            //ItemStatusCode
            NSArray *ItemStatusCodes = [each elementsForName:@"ItemStatusCode"];
            if (ItemStatusCodes.count > 0){
                GDataXMLElement *xmlitemstatuscode = (GDataXMLElement *)[ItemStatusCodes objectAtIndex:0];
                ItemStatusCode = xmlitemstatuscode.stringValue;
                //NSLog(@"ItemStatusCode:%@",ItemStatusCode);
            }else continue;
            
            //ItemQty
            NSArray *ItemQtys = [each elementsForName:@"ItemQty"];
            if (ItemQtys.count > 0){
                GDataXMLElement *xmlitemqty = (GDataXMLElement *)[ItemQtys objectAtIndex:0];
                ItemQty = xmlitemqty.stringValue;
                ItemQty = [ItemQty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSLog(@"before itemqty:%@",ItemQty);
                if ([ItemQty isEqualToString:@"0"])
                    ItemQty = @"1";
                NSLog(@"ItemQty:%@",ItemQty);
            }else continue;
            
            //PrimaryUOM
            NSArray *PrimaryUOMs = [each elementsForName:@"PrimaryUOM"];
            if (PrimaryUOMs.count > 0){
                GDataXMLElement *xmlprimaryuom = (GDataXMLElement *)[PrimaryUOMs objectAtIndex:0];
                PrimaryUOM = xmlprimaryuom.stringValue;
                //NSLog(@"PrimaryUOM:%@",PrimaryUOM);
            }else continue;
            
            ShipToStoreID = StoreID;
            
            if ([ItemDescription length] != 0){
                Items *item = [[[Items alloc]init:ItemID StoreID:StoreID ItemNumber:ItemNumber ItemDescription:ItemDescription ItemTypeID:ItemTypeID StockingCode:StockingCode ItemStatusCode:ItemStatusCode ItemQty:ItemQty PrimaryUOM:PrimaryUOM ShipToStoreID:ShipToStoreID]autorelease];
                [itemset.items addObject:item];
            }else continue;
        }
    }
    
    for (int j=0; j<itemset.items.count; j++)
    {
        Items *obj = [itemset.items objectAtIndex:j];
        if ([obj.ItemDescription length] == 0)
        {
            NSLog(@"OBJ IS NULL");
        }
        else {
            NSLog(@"OBJ:%@",obj.ItemDescription);
        }
    }
    
    
    SSCartItemsViewController *cartViewController = [[SSCartItemsViewController alloc] initwithItems:itemset];
    cartViewController.getitems = itemset;
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
    
    /*
    SSLookupCustomerViewController *lookupcustomerViewController = [[SSLookupCustomerViewController alloc] initWithItems:itemSku itemQty:itemQty itemUOM:itemUOM];
	[[self navigationController] pushViewController:lookupcustomerViewController animated:TRUE];
	[lookupcustomerViewController release];
     */
}

@end
