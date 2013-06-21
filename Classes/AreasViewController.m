//
//  AreasViewController.m
//  selSheet
//
//  Created by Joshua Walker on 2/10/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "AreasViewController.h"

#import "Area.h"
#import "Room.h"
#import "AddFromListViewController.h"
#import "ItemsViewController.h"

@implementation AreasViewController

@synthesize addAreaList, parentRoom;

#pragma mark Constructors
- (id)initWithRoom:(Room *)room 
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Areas"];
	[self setTitle:@"Areas"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
    self.parentRoom = room;
    
    return self;
}

- (void)dealloc {
    // [parentRoom release];
	[addAreaList release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
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
    
    // Add this controller as a Linea Device Delegate
    
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		// This is what shows up on the back button in the *next* controller.
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Areas" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
		// Be able to switch into the previous order navigation flow.
        //  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"" 
        //                                                                             style:UIBarButtonItemStyleBordered 
        //                                                                            target:self 
        //action:@selector(handleLookupOrder:)] autorelease];
        
        //self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAddTapped:)] autorelease];
        
    }
    
    [self.orderTable reloadData];
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
    
    
    //   self.addAreaList = [plist objectForKey:@"Areas"];
    self.addAreaList = [facade lookupAreas];
    //NSArray *array = [NSArray alloc] initWithObjects:<#(id), ...#>, nil
	
	AddFromListViewController *viewController = [[AddFromListViewController alloc] init];
	// We are the delegate responsible for dismissing the modal view 
	viewController.delegate = self;
    
    viewController.tableData = self.addAreaList;
    
	viewController.modalPresentationStyle = UIModalPresentationFormSheet;
	// show the navigation controller modally
	[self presentViewController:viewController animated:YES completion:nil];
	
	[viewController release];
}

- (void)addFromListViewController:(AddFromListViewController *)addFromListViewController didAddItem:(NSInteger)item {
    [self dismissViewControllerAnimated:YES completion:nil];
    // NSDictionary *roomDict = [self.addRoomList objectAtIndex:item];
    Area *newArea = [[Area alloc] init];
    //newArea.areaId = [roomDict objectForKey:@"id"];
    newArea.description = [self.addAreaList objectAtIndex:item];
    
    [self.parentRoom.areas addObject:newArea];
    // Need to do some save code ??
    [newArea release];
    [self.orderTable reloadData];
}

- (void)addFromListViewController:(AddFromListViewController *)addFromListViewController didAddNewItem:(NSString*)item {
    [self dismissViewControllerAnimated:YES completion:nil];
    Area *newArea = [[Area alloc] init];
    //newArea.areaId = [roomDict objectForKey:@"id"];
    newArea.description = item;
    
    [self.parentRoom.areas addObject:newArea];
    [newArea release];
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
	return (self.parentRoom.areas == nil) ? 0 : [self.parentRoom.areas count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomsCellIdentifier"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RoomsCellIdentifier"] autorelease];
    }
    
    cell.textLabel.text = [[self.parentRoom.areas objectAtIndex:indexPath.row] description];
    cell.detailTextLabel.text = [[self.parentRoom.areas objectAtIndex:indexPath.row] note];
    
    return cell;
}


/*
 - (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
 return UITableViewCellEditingStyleNone;
 }
 */


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemsViewController *itemsVC = [[ItemsViewController alloc] initWithArea:[self.parentRoom.areas objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:itemsVC animated:TRUE];
    [itemsVC release];
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
        [self.parentRoom.areas removeObjectAtIndex:row];      
        [tableView reloadData];
    }
}*/


@end
