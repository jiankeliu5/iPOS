//
//  RefundViewController.m
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "RefundViewController.h"
#import "UIScreen+Helpers.h"

@interface RefundViewController()

- (void) layoutView: (UIInterfaceOrientation) interfaceOrientation;

- (void) handleSuspend: (id) sender;

@end

@implementation RefundViewController
@synthesize facade;
@synthesize orderCart;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id) init {
    self = [super init];
    
    if (self) {
        // Set up the items that will appear in a navigation controller bar if
        // this view controller is added to a UINavigationController.
        [[self navigationItem] setTitle:@"Refund"];
        
        // Setup the facade and orderCart
        facade = [iPOSFacade sharedInstance];
        orderCart = [OrderCart sharedInstance];

    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

#pragma mark - View lifecycle
- (void) loadView {
    [super loadView];
    
    RefundView *refundView = [[RefundView alloc] initWithFrame:CGRectZero andOrder:[orderCart getOrder]];
    refundView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    refundView.delegate = self;
    
    // Add the susend button
    UIBarButtonItem *suspendButton = [[UIBarButtonItem alloc] init];
    suspendButton.title = @"Suspend";
    suspendButton.target = self;
    [suspendButton setAction:@selector(handleSuspend:)];
    self.navigationItem.rightBarButtonItem = suspendButton;
    [suspendButton release];
    
    [self setView: refundView];
    
    [refundView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Rotation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark RefundViewDelegate Methods
- (void) applyRefund:(RefundView *)refundView {
    
}

- (void) editOrderNotes:(RefundView *)refundView {
    
}

#pragma mark -
#pragma mark Private Methods
- (void) layoutView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect viewBounds = [UIScreen rectForScreenView:interfaceOrientation isNavBarVisible:YES];
    
    self.view.frame = viewBounds;
}

- (void) handleSuspend:(id)sender {
    
}
@end
