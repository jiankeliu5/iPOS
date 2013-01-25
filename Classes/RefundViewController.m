//
//  RefundViewController.m
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "RefundViewController.h"
#import "UIScreen+Helpers.h"
#import "NSString+StringFormatters.h"

#import "AlertUtils.h"
#import "NotesController.h"

#import "ReceiptViewController.h"

@interface RefundViewController()

- (void) layoutView: (UIInterfaceOrientation) interfaceOrientation;

- (void) handleSuspend: (id) sender;
- (BOOL) sendRefund;

- (BOOL) doCardSwipe;
- (BOOL) doSignatureCapture;

- (void) processRefund;
- (void) processRefundAsDemo: (id) sender;

@end

@implementation RefundViewController
@synthesize facade;
@synthesize orderCart;
@synthesize refundInfo;

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
        
        orderIsSaved = NO;
    }
    
    return self;
}

- (void) dealloc {
    [refundInfo release];
    refundInfo = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void) loadView {
    [super loadView];
    
    // Initialize the refund Info
    Order *order = [orderCart getOrder];
    
    self.refundInfo = [order getRefundInfo];
    
    refundView = [[RefundView alloc] initWithFrame:CGRectZero andOrder:order andRefund:refundInfo];
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
    
    // Get a handle to the shared Linea Device
    linea = [DTDevices sharedDevice];
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

- (void) viewWillDisappear:(BOOL)animated {
    // Remove this controller as a linea delegate
    [linea removeDelegate: self];
    
	// Do this at the end
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Rotation Support
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark SignatureDelegate methods
- (void) signatureController:(SignatureViewController *)signatureController signatureAsBase64:(NSString *)signature savePressed:(id)sender {
    if (signature) {
        refundInfo.signature = signature;
        [self dismissModalViewControllerAnimated:YES];
        
        [self processRefund];
    } else {
     [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"A Signature was not provided for refund."] withTitle:@"iPOS"];
        
    }
}
-(void) signatureController: (SignatureViewController *) signatureController signatureAsImage: (UIImage *) signature savePressed: (id) sender {
	// We are not capturing the signature as an image, but as base64encoded string.
}


#pragma mark- 
#pragma Notes And PO View delegate method 
-(void)close:(NotesController *)notesView {
    if (notesView.notesData != nil) {
        [orderCart getOrder].notes = notesView.notesData;
    }
    
    if (notesView.purchaseOrderData != nil) {
        [orderCart getOrder].purchaseOrderId = notesView.purchaseOrderData;
    }
}

#pragma mark -
#pragma mark RefundViewDelegate Methods
- (void) applyRefund:(RefundView *)refundView {
    [self processRefund];
}

#pragma mark -
#pragma mark ChargeCreditCardViewDelegate
- (void) setupKeyboardSupport:(id) theChargeCCView {
    // Not applicable no data entry needed for refunds
}

- (void) readyForCardSwipe:(NSDecimalNumber *)chargeAmount fromView:(ChargeCreditCardView *) theChargeCCView {
#if TARGET_IPHONE_SIMULATOR
    // Setup a timer to simulate accepting credit card payment
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(processRefundAsDemo:) userInfo:nil repeats: NO];        
#else
    // Add this controller as a Linea Device Delegate
    [linea addDelegate:self];
#endif
}

- (void) cancelCardSwipe:(ChargeCreditCardView *) theChargeCCView {
    // Remove as a Linea Delegate
    [linea removeDelegate:self];
    
    CGRect frame = theChargeCCView.frame;
    frame.origin.y = 480;
    theChargeCCView.frame = frame;
    
    // Just remove the view
    self.navigationItem.hidesBackButton = NO;
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    if (chargeCCView) {
        [chargeCCView removeFromSuperview];
        chargeCCView = nil;
    }
}

#pragma mark -
#pragma mark Linea Delegate Methods
- (void) magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    int sound[]={2730,150,0,30,2730,150};
	[linea playSound:100 beepData:sound length:sizeof(sound) error:nil];
    
    NSDictionary *card = [linea msProcessFinancialCard:track1 track2:track2];
	
    if(card) {
        // Does the card number (last 4) match the current card to swipe
        RefundItem *swipeItem = [refundInfo getCurrentRefundItemForSwipe];
        
        // Check full number or last 4
        BOOL isMatch = YES;
        NSString *swipeCardNum = swipeItem.creditCard.cardNumber;
        
        NSString *accountNumber = (NSString *)[card valueForKey:@"accountNumber"];
        if (accountNumber.length == swipeCardNum.length) {
            if (![accountNumber isEqualToString:swipeCardNum]) {
                isMatch = NO;
            }
        }
        
        // Check last 4
        if (swipeCardNum.length == 4 
            && ![swipeCardNum isEqualToString:[accountNumber substringFromIndex:accountNumber.length - 4]]) {
            isMatch = NO;
        }
        
        if (!isMatch) {
            [AlertUtils showModalAlertMessage:@"The card you swiped does not match please try again." withTitle:@"iPOS"];
        } else {
            [refundInfo setCardData:card];
            
            // Remove the credit card view
            if (chargeCCView) {
                [chargeCCView removeFromSuperview];
                chargeCCView = nil;
                // Remove as a Linea Delegate
                [linea removeDelegate:self];
            } 
            
            [self processRefund];
        }
    }
}

- (void) editOrderNotes:(RefundView *)refundView {
    NSLog(@"displaying Notes and PO view");
    
    NotesController *notesOverlay = [[[NotesController alloc] init] autorelease];
    notesOverlay.notesDelegate = self;
    notesOverlay.notesData = [orderCart getOrder].notes;
    notesOverlay.purchaseOrderData = [orderCart getOrder].purchaseOrderId;
    [self.navigationController pushViewController:notesOverlay animated:YES];
}

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex {
	
    // Send quote modal.
    if ([anAlertView.title isEqualToString:@"Send Refund?"]) {
		// Check by titles rather than index since documentation suggests that different 
		// devices can set the indexes differently.
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Send Refund"]) {
			[self sendRefund];
		}
	}
    
    // Cancel and logout modal.
    if ([anAlertView.title isEqualToString:@"Cancel and Logout?"]) {
		NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Logout"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
    
	// Other generic alerts will just fall through and dismiss with no other actions.
}

#pragma mark -
#pragma mark Private Methods
- (void) layoutView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect viewBounds = [UIScreen rectForScreenView:interfaceOrientation isNavBarVisible:YES];
    
    self.view.frame = viewBounds;
    
    if (chargeCCView) {
        chargeCCView.frame = self.view.bounds;
    }
}

- (void) handleSuspend:(id)sender {
    // Cancel the order and completely Logoff
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL) doCardSwipe {
    if (refundInfo) {
        if (refundInfo.isCardSwipeRequired) {
            // Do the card swipe
            CGRect overlayRect = self.view.bounds;
            chargeCCView = [[ChargeCreditCardView alloc] initWithFrame:overlayRect andRefundInfo: refundInfo];
            
            chargeCCView.viewDelegate = self;
                       
            [self.view addSubview:chargeCCView];
            
            [chargeCCView release];

            return YES;
        }
    }
    
    return NO;
}

- (BOOL) doSignatureCapture {
    if (refundInfo) {
        // Just the signature capture view or the charge card view
        if (refundInfo.isSignatureRequired) {
            SignatureViewController *refundSignatureController = [[SignatureViewController alloc] init];
            
            refundSignatureController.delegate = self;
            
            [self presentModalViewController:refundSignatureController animated:YES];
            refundSignatureController.signingLabel.text = @"By signing below, I agree to a refund of";
            refundSignatureController.payAmountLabel.text =  [NSString formatDecimalNumberAsMoney:[refundInfo getTotalRefundAmount]];
            [refundSignatureController release];
            
            return YES;
        }
    }
    
    return NO;
}

- (void) processRefundAsDemo:(id)sender {
    // Just add dummy data for the swiped card
    RefundItem *swipeItem = [refundInfo getCurrentRefundItemForSwipe];
    
    if (swipeItem.creditCard) {
        swipeItem.creditCard.cardNumber = @"1111222233334444";
        [swipeItem.creditCard setExpireDateMonthYear:@"12" year:@"2020"];
        swipeItem.creditCard.nameOnCard = @"Demo User";
        swipeItem.isSwipeCaptured = YES;
    }
    
    // Remove the credit card view
    if (chargeCCView) {
        [chargeCCView removeFromSuperview];
        chargeCCView = nil;
    } 
    
    [self processRefund];
}
            
- (void) processRefund {
    if (![self doCardSwipe]) {
        if (![self doSignatureCapture]) {
            // Show the alert, continue with refund ??
            UIAlertView *refundAlert = [[UIAlertView alloc] init];
            refundAlert.title = @"Send Refund?";
            refundAlert.message = @"This change the order and process the refund.  Are you sure you wish to do this?";
            refundAlert.delegate = self;
            [refundAlert addButtonWithTitle:@"Cancel"];
            [refundAlert addButtonWithTitle:@"Send Refund"];
            [refundAlert show];
            [refundAlert release];
            
            // reload the refund view
            [refundView.refundAmountsTableView reloadData];
        }
    } 
}

- (BOOL) sendRefund {
    // Save the order
    // Save order 
    BOOL isOrderSaved = [orderCart saveOrder];
    orderIsSaved = isOrderSaved;
    
    // Send refund request
    if (isOrderSaved) {
        // Send Request to save the refund
        if (![facade sendRefundRequest:refundInfo]) {
            [AlertUtils showModalAlertForErrors:refundInfo.errorList withTitle:@"iPOS Order Saved But Refund Failed"];
        } else {
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Refund for order %@ was successfully processed.", [orderCart getOrder].orderId] withTitle:@"iPOS"];
            
            // Navigate to the Send Receipt View Controller
            [[self navigationController] pushViewController:[[[ReceiptViewController alloc]init]autorelease] animated:YES];
            
            return YES;
        }
    } 
    
    return NO;
}



@end
