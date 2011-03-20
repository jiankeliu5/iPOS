//
//  CustomerEditViewController.m
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerEditViewController.h"
#import "UIViewController+ViewControllerLayout.h"

#pragma mark -
#pragma mark Private Interface
@interface CustomerEditViewController ()
@end

#pragma mark -
@implementation CustomerEditViewController

#pragma mark Constructors
- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	facade = [iPOSFacade sharedInstance];
	
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Methods

- (void) loadView {
	[super loadView];
	
	UITableView *formTableView = [[[UITableView alloc] initWithFrame:[self rectForNav] style:UITableViewStyleGrouped] autorelease];
	[formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	formTableView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	
	[self setTableView:formTableView];
	[self setView:formTableView];
}

@end
