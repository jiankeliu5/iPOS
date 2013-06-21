//
//  CartItemsViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "RoomsViewController.h"
#import "Room.h"
#import "AddFromListViewController.h"
#import "AreasViewController.h"
#import "CustomerViewController.h"

@implementation RoomsViewController

@synthesize addRoomList, addCustomer;


#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Rooms"];
	[self setTitle:@"Rooms"];
    
    self.addCustomer = false;
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
    return self;
}

- (id)initWithCustomerAdd
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Rooms"];
	[self setTitle:@"Rooms"];
    
    self.addCustomer = true;
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
    return self;
}


- (void)dealloc {
	
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    
    if (self.addCustomer) {
        CustomerViewController *customerViewController = [[CustomerViewController alloc] init];
        [[self navigationController] pushViewController:customerViewController animated:TRUE];
        [customerViewController release];
    }
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		// This is what shows up on the back button in the *next* controller.
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Rooms" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
		// Be able to switch into the previous order navigation flow.
        //  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"" 
        //                                                                             style:UIBarButtonItemStyleBordered 
        //                                                                            target:self 
        //action:@selector(handleLookupOrder:)] autorelease];
        
        //self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAddTapped:)] autorelease];
        
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


-(void) handleAddTapped:(id)sender {
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    //      NSUserDomainMask, YES); 
    // NSString *plistFile = [[paths objectAtIndex:0]
    //                 stringByAppendingPathComponent:@"Rooms.plist"];
    
    //   NSBundle* bundle = [NSBundle mainBundle];
    //	NSString* plistFile = [bundle pathForResource:@"TestData" ofType:@"plist"];
    
    //    NSDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
    
    //    self.addRoomList = [plist objectForKey:@"Rooms"];
    
    self.addRoomList = [self.facade lookupRooms];
    
    NSLog(@"List %@",self.addRoomList);
    NSLog(@"List 1 %@",[self.addRoomList objectAtIndex:1]);
    
	
	AddFromListViewController *viewController = [[AddFromListViewController alloc] init];
	// We are the delegate responsible for dismissing the modal view 
	viewController.delegate = self;
    
    viewController.tableData = self.addRoomList;
    
	viewController.modalPresentationStyle = UIModalPresentationFormSheet;
	// show the navigation controller modally
	[self presentViewController:viewController animated:YES completion:nil];
	
	[viewController release];
}

- (void)addFromListViewController:(AddFromListViewController *)addFromListViewController didAddItem:(NSInteger)item {
    NSLog(@"room added");
    [self dismissViewControllerAnimated:YES completion:nil];
    //NSDictionary *roomDict = [self.addRoomList objectAtIndex:item];
    Room *newRoom = [[Room alloc] init];
    // newRoom.roomId = [self.addRoomList objectAtIndex:item];
    newRoom.description = [self.addRoomList objectAtIndex:item];
    
    [self.selSheet.rooms addObject:newRoom];
    [newRoom release];
    [self.orderTable reloadData];
}

- (void)addFromListViewController:(AddFromListViewController *)addFromListViewController didAddNewItem:(NSString*)item {
    [self dismissViewControllerAnimated:YES completion:nil];
    Room *newRoom = [[Room alloc] init];
    newRoom.description = item;
    
    [self.selSheet.rooms addObject:newRoom];
    [newRoom release];
    [self.orderTable reloadData];
}

-(void)didDismissModalView {
    [self dismissViewControllerAnimated:YES completion:nil];
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
	return (selSheet.rooms == nil) ? 0 : [selSheet.rooms count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomsCellIdentifier"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RoomsCellIdentifier"] autorelease];
    }
    
    cell.textLabel.text = [[self.selSheet.rooms objectAtIndex:indexPath.row] description];

    return cell;
}


/*
 - (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
 return UITableViewCellEditingStyleNone;
 }
 */


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AreasViewController *areasVC = [[AreasViewController alloc] initWithRoom:[selSheet.rooms objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:areasVC animated:TRUE];
    [areasVC release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}


-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = [indexPath row];
        [selSheet.rooms removeObjectAtIndex:row];      
        [tableView reloadData];
    }
}*/

@end
