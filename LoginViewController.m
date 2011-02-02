//
//  LoginViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/1/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "LoginViewController.h"
#import "PlaceHolderView.h"

#pragma mark -
#pragma mark Private Interface
@interface LoginViewController ()
@end

#pragma mark -
@implementation LoginViewController

#pragma mark Constructors
- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"iPOS"];
	
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView
{
	return [self view];
}

#pragma mark -
#pragma mark Methods

#pragma mark UIViewController overrides
- (void) loadView
{
	[self setView:[[PlaceHolderView alloc]initWithFrame:CGRectZero]];
}

- (void) viewDidLoad
{
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:YES];
	}
}

- (void) viewDidUnload
{
	
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return TRUE;
}

@end
