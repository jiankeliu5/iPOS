//
//  ReceiptOptionsViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "AlertUtils.h"
#import "ReceiptViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"

#import "MOGlassButton.h"

#define OVERLAY_MARGIN_TOP 75.0f
#define OVERLAY_MARGIN_LEFT 40.0f
#define OVERLAY_MARGIN_RIGHT 40.0f
#define OVERLAY_MARGIN_BOTTOM 80.0f
#define BUTTON_SPACE 20.0f
#define BUTTON_WIDTH  200.0f
#define BUTTON_HEIGHT 40.0f

@interface ReceiptViewController()

- (void) handleEmailReceiptButton: (id) sender;

@end

@implementation ReceiptViewController

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Receipt"];
    self.navigationItem.hidesBackButton = YES;

    orderCart = [OrderCart sharedInstance];
	facade = [iPOSFacade sharedInstance];
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    CGRect rectForView = [self rectForNavAndStatus];
    
    // Create the background view
    UIView *bgView = [[UIView alloc] initWithFrame:rectForView];
	bgView.backgroundColor = [UIColor whiteColor];
	[self setView:bgView];
	[bgView release];
    
    // Create the overlay view
    UIView *overlay = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    
    overlay.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
    
    // Add the rounded view
    UIView *receiptRoundedView = [[[UIView alloc] 
                                    initWithFrame:CGRectMake(OVERLAY_MARGIN_LEFT, OVERLAY_MARGIN_TOP, rectForView.size.width-OVERLAY_MARGIN_LEFT-OVERLAY_MARGIN_RIGHT, 
                                                             rectForView.size.height-OVERLAY_MARGIN_TOP-OVERLAY_MARGIN_BOTTOM)] 
                                    autorelease];
    
    [receiptRoundedView applyRoundedStyle:[UIColor blackColor] withShadow:YES];
	[receiptRoundedView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] 
                                                    endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
                                                    
   
    MOGlassButton *emailReceiptButton = [[[MOGlassButton alloc] 
                                          initWithFrame:CGRectMake(floorf((receiptRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), BUTTON_SPACE, BUTTON_WIDTH, BUTTON_HEIGHT)] 
                                          autorelease];
    MOGlassButton *printReceiptButton = [[[MOGlassButton alloc] 
                                          initWithFrame:CGRectMake(floorf((receiptRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), BUTTON_HEIGHT+2*BUTTON_SPACE, BUTTON_WIDTH, BUTTON_HEIGHT)] 
                                         autorelease];
    MOGlassButton *printEmailReceiptButton = [[[MOGlassButton alloc] 
                                          initWithFrame:CGRectMake(floorf((receiptRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), 2*BUTTON_HEIGHT+3*BUTTON_SPACE, BUTTON_WIDTH, BUTTON_HEIGHT)] 
                                         autorelease];
    MOGlassButton *exitWithoutReceiptButton = [[[MOGlassButton alloc] 
                                               initWithFrame:CGRectMake(floorf((receiptRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), 3*BUTTON_HEIGHT+4*BUTTON_SPACE, BUTTON_WIDTH, BUTTON_HEIGHT)] 
                                              autorelease];

    
    [emailReceiptButton setupAsSmallBlackButton];
    [emailReceiptButton setTitle:@"E-Mail Receipt" forState:UIControlStateNormal];
    [emailReceiptButton addTarget:self action:@selector(handleEmailReceiptButton:) forControlEvents:UIControlEventTouchUpInside];
    emailReceiptButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [printReceiptButton setupAsSmallBlackButton];
    [printReceiptButton setTitle:@"Print Receipt" forState:UIControlStateNormal];
    printReceiptButton.titleLabel.textAlignment = UITextAlignmentCenter;
    printReceiptButton.enabled = NO;
    
    [printEmailReceiptButton setupAsSmallBlackButton];
    [printEmailReceiptButton setTitle:@"Print & E-Mail Receipt" forState:UIControlStateNormal];
    printEmailReceiptButton.titleLabel.textAlignment = UITextAlignmentCenter;
    printEmailReceiptButton.enabled = NO;
    
    [exitWithoutReceiptButton setupAsSmallBlackButton];
    [exitWithoutReceiptButton setTitle:@"Exit Without Receipt" forState:UIControlStateNormal];
    [exitWithoutReceiptButton addTarget:self action:@selector(handleExitWithoutReceiptButton:) forControlEvents:UIControlEventTouchUpInside];
    exitWithoutReceiptButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [receiptRoundedView addSubview:emailReceiptButton];  
    [receiptRoundedView addSubview:printReceiptButton];
    [receiptRoundedView addSubview:printEmailReceiptButton]; 
     [receiptRoundedView addSubview:exitWithoutReceiptButton]; 
    [overlay addSubview:receiptRoundedView];
    [self.view addSubview:overlay];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	// Do this at the end
	[super viewDidDisappear:animated];
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
#pragma mark Private Methods
- (void) handleEmailReceiptButton:(id)sender {
    Order *order = [orderCart getOrder];
    
    if (order && order.customer) {
        if (order.customer.emailAddress == nil || [order.customer.emailAddress isEqualToString:@""]) {
            [AlertUtils showModalAlertMessage:@"Customer does not have e-mail address"];
        }
        
        // Trigger the email
        if ([facade emailReceipt:order]) {
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Receipt e-mailed to customer at %@", order.customer.emailAddress]];
        } else {
            [AlertUtils showModalAlertMessage:@"Sending e-mail to customer failed."];
        }
    } else {
        [AlertUtils showModalAlertMessage:@"Order or Customer not available to send receipt."];
    }
    
    // Logoff
    [self. navigationController popToRootViewControllerAnimated:YES];
}

-(void)handleExitWithoutReceiptButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
