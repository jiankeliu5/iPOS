//
//  AddFromListViewController.m
//  selSheet
//
//  Created by Josh Walker on 2/10/2012.
//  Copyright 2012 Object Partners Inc. All rights reserved.
//

#import "AddFromListViewController.h"


@implementation AddFromListViewController

@synthesize delegate;
@synthesize tableData;
@synthesize theTableView;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect toolBarRect, tableRect;
    CGRectDivide(self.view.frame, &toolBarRect, &tableRect, 44.0, CGRectMinYEdge);
    
    self.theTableView = [[[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain] autorelease];
	self.theTableView.backgroundColor = [UIColor whiteColor];
	self.theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.theTableView.tableHeaderView.hidden = YES;
	self.theTableView.delegate = self;
	self.theTableView.dataSource = self;
	[self.view addSubview:self.theTableView];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:toolBarRect];
	toolBar.barStyle = UIBarStyleBlack;
	
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] 
                                      initWithTitle:@"Cancel"
                                      style:UIBarButtonItemStyleBordered 
                                      target:self 
                                      action:@selector(dismissModalView)] autorelease];
    
    UIBarButtonItem *newButton = [[[UIBarButtonItem alloc] 
                                   initWithTitle:@"Custom"
                                   style:UIBarButtonItemStyleBordered 
                                   target:self 
                                   action:@selector(addNewItem)] autorelease];
    
    UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    
    NSArray *toolbarItems = [[[NSArray alloc] initWithObjects:cancelButton, tbFlex, newButton, nil] autorelease];
    
    [toolBar setItems:toolbarItems];
    //[toolBar set
    
    
    [self.view addSubview:toolBar];
    [toolBar release];
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

-(void) dismissModalView {
    [self.delegate didDismissModalView];
}

-(void) addNewItem {
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Add Custom"
                                                     message:@"\n\n"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Add", nil];
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [prompt show];
    [prompt release];
    
    // set cursor and show keyboard
    // [textField becomeFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Add"])
    {
        UITextField *newItem = [alertView textFieldAtIndex:0];
        
        NSLog(@"Username: %@\n", newItem.text);
        [self.delegate addFromListViewController:self didAddNewItem:newItem.text];
    }
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
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:MyIdentifier] autorelease];
    }
	
    //NSDictionary *data = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [[self.tableData objectAtIndex:indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSDictionary *selected = [self.tableData objectAtIndex:indexPath.row];
	
	
    [self.delegate addFromListViewController:self didAddItem:indexPath.row];
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

@end
