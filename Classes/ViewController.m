//
//  ViewController.m
//  iPOS
//
//  Created by Enning Tang on 5/1/13.
//
//

#import "ViewController.h"

#import "HHTabListController.h"


@interface ViewController ()

@end


@implementation ViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	//self = [super initWithNibName:@"ViewController" bundle:nil];
    self = [super init];
    if (self == nil)
        return nil;
	
	if (self != nil) {
		
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.label.text = self.title;
}


#pragma mark -
#pragma mark Accessors

@synthesize label = _label;


#pragma mark -
#pragma mark Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([self isMovingToParentViewController]) {
		HHTabListController *tabListController = [self tabListController];
		UIBarButtonItem *leftBarButtonItem = tabListController.revealTabListBarButtonItem;
		
		self.navigationItem.leftBarButtonItem = leftBarButtonItem;
	}
}


#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
