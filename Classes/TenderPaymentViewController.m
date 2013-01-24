//
//  TenderPaymentViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AlertUtils.h"

#import "TenderPaymentViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIScreen+Helpers.h"

#import "LineView.h"


#import "ChargeCreditCardView.h"
#import "ReceiptViewController.h"
#import "SignatureViewController.h"

#import "NSString+StringFormatters.h"
#import "NSString+Extensions.h"

#import "CreditCardPayment.h"
#import "AccountPayment.h"
#import "NotesController.h"
#import "PaymentView.h"

#define TOOLBAR_HEIGHT 44.0f
#define SEPARATOR_HEIGHT 5.0f

#define LABEL_STARTY 10.0f
#define LABEL_STARTX 60.0f
#define LABEL_BALDUE_STARTX 40.0f
#define LABEL_HEIGHT 18.0f
#define LABEL_FONT_SIZE 16.0f
#define LABEL_TITLE_WIDTH 80.0f
#define LABEL_BALDUE_WIDTH 100.0f
#define LABEL_WIDTH 120.0f
#define LABEL_MIDDLE_WIDTH 108.0f
#define LABEL_SPACING 5.0f

#define LINE_WIDTH 70.0f
#define LINE_HEIGHT 2.0f

static NSString * const ACCOUNT = @"account";
static NSString * const CREDIT = @"credit";

@interface TenderPaymentViewController()

// Demo Methods
- (void) processOrderAsDemo: (id) sender;
- (BOOL) tenderDemoPayment;

// Production Methods
- (UIView *) buildTenderTotalView;
- (UIView *) buildSeparatorView;

- (void) handleCreditCardPayment:(id)sender;
- (void) handleAccountPayment:(id)sender;
- (void) handleSuspendOrder: (id) sender;

- (void) layoutView: (UIInterfaceOrientation) orientation;
- (void) updateDisplayValues;

- (BOOL) tenderPaymentFromCardData: (NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3;
- (BOOL) sendPaymentOnAccount:(NSDecimalNumber *) amount;
- (BOOL) isOrderSaved;

- (void) showPaymentRetryAlert:(Payment *) aPayment;
- (void) cancelTenderAndLogout;

- (void) navToReceipt;
- (void) displayPayOnAccountSuccessfulView;
@end

@implementation TenderPaymentViewController

@synthesize paymentAmount, payment;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Tender"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];
    orderCart = [OrderCart sharedInstance];
	
    orderIsSaved = NO;
    doNavToReceiptAfterOnAcctPayment = NO;
    return self;
}

- (void)dealloc {
    [paymentAmount release];
    [payment release];
    
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
    
    //Just used as an example of how we can change screens.  
    UISwipeGestureRecognizer *swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(displayNotesAndPOView:)] autorelease];
    [bgView addGestureRecognizer:swipeRight];
    
	[self setView:bgView];
	[bgView release];
    [self.view addSubview:[self buildTenderTotalView]];
    [self.view addSubview:[self buildSeparatorView]];
    
    // Add Balance Due
    CGFloat balanceDueY = rectForView.size.height - [self navBarHeight] - LABEL_SPACING - LABEL_HEIGHT;
    balancePaidTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
    balancePaidTitleLabel.text = @"Paid";
    balancePaidTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    balancePaidTitleLabel.textAlignment = UITextAlignmentLeft;
    
    balancePaidLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balancePaidLabel.textColor = [UIColor blueColor];
    balancePaidLabel.text = @"$0.00";
    balancePaidLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balancePaidLabel.textAlignment = UITextAlignmentRight;
    
    balanceOwingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
    balanceOwingTitleLabel.text = @"Owing";
    balanceOwingTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    balanceOwingTitleLabel.textAlignment = UITextAlignmentLeft;
    
    balanceOwingLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balanceOwingLabel.textColor = [UIColor blueColor];
    balanceOwingLabel.text = @"$0.00";
    balanceOwingLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balanceOwingLabel.textAlignment = UITextAlignmentRight;
    
    balanceDueTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
    balanceDueTitleLabel.text = @"Balance Due";
    balanceDueTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    balanceDueTitleLabel.textAlignment = UITextAlignmentLeft;
    
    balanceDueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balanceDueLabel.textColor = [UIColor blueColor];
    balanceDueLabel.text = @"$0.00";
    balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balanceDueLabel.textAlignment = UITextAlignmentRight;
    
    [self.view addSubview:balancePaidTitleLabel];
    [self.view addSubview:balancePaidLabel];
    [self.view addSubview:balanceOwingTitleLabel];
    [self.view addSubview:balanceOwingLabel];
    [self.view addSubview:balanceDueTitleLabel];
    [self.view addSubview:balanceDueLabel];
    
    [balanceDueTitleLabel release];
    [balanceDueLabel release]; 
    
    // Add the susend button
    UIBarButtonItem *suspendButton = [[UIBarButtonItem alloc] init];
    suspendButton.title = @"Suspend";
    suspendButton.target = self;
    [suspendButton setAction:@selector(handleSuspendOrder:)];
    self.navigationItem.rightBarButtonItem = suspendButton;
    [suspendButton release];
    
    
    // Add the payment toolbar to the bottom
    paymentToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, rectForView.size.height - [self navBarHeight], rectForView.size.width, TOOLBAR_HEIGHT)];
    paymentToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    tbFixed.width = 150.0;
    UIBarButtonItem *notesAndPOButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(displayNotesAndPOView:)] autorelease];
    
    
        UIBarButtonItem * accountPaymentButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notes.png"] 
                                                             style:UIBarButtonItemStylePlain 
                                                            target:self 
                                                            action:@selector(handleAccountPayment:)] autorelease];
    
    
    if (![[orderCart getCustomerForOrder] isPaymentOnAccountEligable]) {
        [accountPaymentButton setEnabled:NO];
    } 
    
    UIBarButtonItem *creditCardButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CreditCard.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleCreditCardPayment:)] autorelease];
    NSArray *paymentToolbarItems = [[[NSArray alloc] initWithObjects:notesAndPOButton, tbFixed, accountPaymentButton, tbFlex, creditCardButton, nil] autorelease];
    [paymentToolbar setItems:paymentToolbarItems];
    
    [self.view addSubview:paymentToolbar];
    [paymentToolbar release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
	}
    
    self.delegate = self;
    
    // Get a handle to the shared Linea Device
    linea = [DTDevices sharedDevice];
	
}

- (void) viewWillAppear:(BOOL)animated {
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    [self updateDisplayValues];
    [super viewWillAppear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    // Remove this controller as a linea delegate
    [linea removeDelegate: self];
    
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	// Do this at the end
	[super viewDidDisappear:animated];
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
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
    // Re-position the separator view and the balance due
    CGRect separatorFrame = separatorView.frame;
    separatorFrame.origin.y = viewBounds.size.height - (3 * TOOLBAR_HEIGHT) - SEPARATOR_HEIGHT;
    separatorFrame.size.width = viewBounds.size.width;
    separatorView.frame = separatorFrame;
    
    CGRect tenderTotalFrame = tenderTotalView.frame;
    tenderTotalFrame.size.height = viewBounds.size.height - (3 * TOOLBAR_HEIGHT);
    tenderTotalFrame.size.width = viewBounds.size.width;
    tenderTotalView.frame = tenderTotalFrame;
    
    CGFloat balancePaidY = viewBounds.size.height - 3*LABEL_SPACING - 3*LABEL_HEIGHT - TOOLBAR_HEIGHT;
    CGFloat balanceOwingY = viewBounds.size.height - 2*LABEL_SPACING - 2*LABEL_HEIGHT - TOOLBAR_HEIGHT;
    CGFloat balanceDueY = viewBounds.size.height - LABEL_SPACING - LABEL_HEIGHT - TOOLBAR_HEIGHT;
    
    balancePaidTitleLabel.frame = CGRectMake(LABEL_BALDUE_STARTX, balancePaidY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT);        
    balancePaidLabel.frame = CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balancePaidY, LABEL_WIDTH, LABEL_HEIGHT);
    balanceOwingTitleLabel.frame = CGRectMake(LABEL_BALDUE_STARTX, balanceOwingY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT);        
    balanceOwingLabel.frame = CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceOwingY, LABEL_WIDTH, LABEL_HEIGHT);
    balanceDueTitleLabel.frame = CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT);        
    balanceDueLabel.frame = CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT);
    
    // Layout the toolbar
    paymentToolbar.frame = CGRectMake(0.0f, viewBounds.size.height - TOOLBAR_HEIGHT, viewBounds.size.width, TOOLBAR_HEIGHT);
    
    if (chargeCCView) {
        chargeCCView.frame = self.view.bounds;
    }
    
    if (accountPaymentView) {
        accountPaymentView.frame = self.view.bounds;
    }

}

#pragma mark -
#pragma mark ChargeCreditCardViewDelegate
- (void) setupKeyboardSupport:(id) theChargeView {
    
    if([theChargeView conformsToProtocol:@protocol(PaymentView)] == YES) {
        ExtUITextField *chargeAmtField = [theChargeView getChargeAmountTextField];
        
        chargeAmtField.returnKeyType = UIReturnKeyDone;
        chargeAmtField.keyboardType = UIKeyboardTypeDecimalPad;
        [self addDoneAndCancelToolbarForTextField:chargeAmtField];
        
        chargeAmtField.delegate = self;  
    }
}

- (void) cancelCardSwipe: (ChargeCreditCardView *) theChargeCCView {
    
    // Remove as a Linea Delegate
    [linea removeDelegate:self];
    
    CGRect frame = theChargeCCView.frame;
    frame.origin.y = 480;
    theChargeCCView.frame = frame;
    
    // Just remove the view
    if (!orderIsSaved) {
        self.navigationItem.hidesBackButton = NO;
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    if (chargeCCView) {
        [chargeCCView removeFromSuperview];
        chargeCCView = nil;
    }
}

- (void) readyForCardSwipe:(NSDecimalNumber *)chargeAmount fromView:(ChargeCreditCardView *)chargeCCView {
    // Set the payment amount
    self.paymentAmount = chargeAmount;
    
#if TARGET_IPHONE_SIMULATOR
    // Setup a timer to simulate accepting credit card payment
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(processOrderAsDemo:) userInfo:nil repeats: NO];        
#else
    // Add this controller as a Linea Device Delegate
    [linea addDelegate:self];
#endif
    
}

#pragma mark -
#pragma mark Linea Delegate Methods
- (void) magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    BOOL isOrderSaved = [self isOrderSaved];
    BOOL isPaymentTendered = NO;
    
    int sound[]={2730,150,0,30,2730,150};
	[linea playSound:100 beepData:sound length:sizeof(sound) error:nil];
    
    // When the Credit Card is scanned we are going to:
    // 1.  Create the order in POS
    // 2.  Process the payment with indicated amount
    // 3.  Prompt for signature
    
    // Only create the order if it is not created at this point
    if (!isOrderSaved) {
        isOrderSaved = [orderCart saveOrder];
        
        orderIsSaved = isOrderSaved;
    }
    
    if (isOrderSaved) {
        isPaymentTendered = [self tenderPaymentFromCardData:track1 track2:track2 track3:track3];
    }
    
    if (isPaymentTendered) {
        SignatureViewController *ccSignatureViewController = [[[SignatureViewController alloc] init] autorelease];
        
        ccSignatureViewController.delegate = self;
        
        [self presentModalViewController:ccSignatureViewController animated:YES];
        ccSignatureViewController.payAmountLabel.text = [NSString formatDecimalNumberAsMoney:self.paymentAmount];
        
        // Remove the credit card view
        if (chargeCCView) {
            [chargeCCView removeFromSuperview];
            chargeCCView = nil;
            
            // Remove as a Linea Delegate
            [linea removeDelegate:self];
        } 
    }
}

#pragma mark -
#pragma mark ExtUIViewController delegates
- (void) extTextFieldFinishedEditing:(ExtUITextField *) textField {
    // Verify that the amount entered is between balance due and order total
    Order *order = [orderCart getOrder];
    
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *amount = [[NSDecimalNumber decimalNumberWithString:textField.text] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    NSDecimalNumber *balanceDue = [[order calcBalanceDue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    NSDecimalNumber *orderAmount = [[[order calcOrderSubTotal] decimalNumberByAdding:[order calcOrderTax]] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    
    if (textField.tagName == ACCOUNT) {
        Order *order = [orderCart getOrder];
        NSArray *closedItems = [order getOrderItems:LINE_ORDERSTATUS_CLOSED];
        
        //If the amount is greater than our credit available then display a warning
        if([amount compare:[[orderCart getCustomerForOrder] calculateAccountBalance]] == NSOrderedDescending)
        {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the account balance." withTitle:@"iPOS"];
            return; 
        } else if ([amount compare:orderAmount] == NSOrderedDescending) {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the order total balance." withTitle:@"iPOS"];
            return;        
        } else if ([[order calcBalanceDue] compare:[NSDecimalNumber zero]] == NSOrderedSame && [closedItems count] == 0 
                   && [amount compare:[NSDecimalNumber zero]] != NSOrderedSame) {
            [AlertUtils showModalAlertMessage:@"No closed items in the order.  You must enter a charge of $0.00." withTitle:@"iPOS"];
        } else {
            BOOL isOrderSaved = orderIsSaved;
            
            if (!isOrderSaved) {
                orderIsSaved = [orderCart saveOrder];
                isOrderSaved = orderIsSaved;
            }
            
            // Just go to receipt view or continue with payment
            if (isOrderSaved && [amount compare:[NSDecimalNumber zero]] == NSOrderedSame) {
                [self navToReceipt];
            } else if (isOrderSaved) {
                BOOL onAcctPaymentSuccessful = [self sendPaymentOnAccount:amount];
                
                if (onAcctPaymentSuccessful) {
                    // Do I navigate to the receipt view or stay on tender??
                    if([amount compare:balanceDue] == NSOrderedSame || [amount compare:balanceDue] == NSOrderedDescending) {
                        doNavToReceiptAfterOnAcctPayment = YES;
                    } else {
                        // Fetch the payments for the order (to reflect current order state with payments)
                        order.previousPayments = [NSMutableArray arrayWithArray:[facade getPaymentHistoryForOrderid:order.orderId]];
                    }
                }
            }
        }
    } else if (textField.tagName == CREDIT) {
        if ([amount compare:balanceDue] == NSOrderedAscending) {
            [AlertUtils showModalAlertMessage:@"Cannot charge less than the balance due." withTitle:@"iPOS"];
            return;
        } else if ([amount compare:orderAmount] == NSOrderedDescending) {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the order total balance." withTitle:@"iPOS"];
            return;
        }
        
        // If the amount was $0.00 at this point, Just save the order
        if ([amount compare:[NSDecimalNumber zero]] == NSOrderedSame) {
            BOOL isOrderSaved = orderIsSaved;
            
            if (!isOrderSaved) {
                orderIsSaved = [orderCart saveOrder];
                isOrderSaved = orderIsSaved;
            }
            
            if (isOrderSaved) {
                [self navToReceipt];
            }
            
        } else {
            // We are good at this point so show the message to have user swipe credit card
            if (chargeCCView) {
                [chargeCCView switchCardSwipeToReady];
            }
        }
    }  
}

#pragma mark -
#pragma mark Send payment on account method.
- (BOOL) sendPaymentOnAccount:(NSDecimalNumber *) amount {
    self.payment = [[[AccountPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
    [payment setPaymentAmount:amount];
    [facade tenderPaymentOnAccount:payment];
    
    if ([[payment errorList] count] == 0) {
        SignatureViewController *signatureViewController = [[[SignatureViewController alloc] init] autorelease];
        signatureViewController.delegate = self;
        
        [self presentModalViewController:signatureViewController animated:YES];
        signatureViewController.payAmountLabel.text = [NSString formatDecimalNumberAsMoney:amount];
    } else {
        [self showPaymentRetryAlert:payment];
        return NO;
    }
    
    return YES;
}

#pragma mark -

-(void)displayPayOnAccountSuccessfulView
{
    
    UILabel *textLabel = [[UILabel alloc ]initWithFrame:CGRectMake(self.view.frame.size.width / 6, self.view.frame.size.height / 4, 225.0f, 100.0f)];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.layer.cornerRadius = 5.0f;
    textLabel.text = @"Payment Successful";
    textLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    textLabel.textAlignment = UITextAlignmentCenter;
    
    [UIView animateWithDuration:1.5 animations:^ {
        [self.view addSubview:textLabel];
        textLabel.alpha = 0.0;
    } completion:^(BOOL isFinished) {
        if (doNavToReceiptAfterOnAcctPayment) {
            [self navToReceipt];
        }
    }];
}

#pragma mark -
#pragma mark SignatureDelegate methods
- (void) signatureController:(SignatureViewController *)signatureController signatureAsBase64:(NSString *)signature savePressed:(id)sender {

    if (payment && signature) {
        if([payment isKindOfClass:[CreditCardPayment class]]) {
            [self.payment attachSignature:signature];
            
            if (![facade acceptSignatureFor:self.payment]) {
                Error *error = [[[Error alloc] init] autorelease];
                error.errorId = @"PMT_SIG";
                error.message = [NSString stringWithFormat:@"Problem accepting signature for payment with ref #%@.", [payment paymentRefId]];
                [payment addError:error];
                
                [AlertUtils showModalAlertForErrors:((Payment *)  payment).errorList withTitle: @"iPOS"];
            } 
        
            [self dismissModalViewControllerAnimated:YES];
            [self navToReceipt];
        } else if ([payment isKindOfClass:[AccountPayment class]]) {
            [self.payment attachSignature:signature];

            if (![facade acceptSignatureOnAccount:self.payment]) {
                Error *error = [[[Error alloc] init] autorelease];
                error.errorId = @"PMT_SIG";
                error.message = [NSString stringWithFormat:@"Problem accepting signature for payment with ref #%@.", [payment paymentRefId]];
                [payment addError:error];
                
                [AlertUtils showModalAlertForErrors:((Payment *)  payment).errorList withTitle: @"iPOS"];
                [self dismissModalViewControllerAnimated:YES];
                [self navToReceipt];
            } else {
                if([[payment paymentAmount] compare:[[orderCart getOrder] calcBalanceDue]] == NSOrderedSame) {
                    [self dismissModalViewControllerAnimated:YES];
                    [self navToReceipt];
                } else {
                    [self dismissModalViewControllerAnimated:YES];
                    [accountPaymentView removeFromSuperview];
                    accountPaymentView = nil;
                    [self updateDisplayValues];
                    [self displayPayOnAccountSuccessfulView];
                }
            }
        }
    }
    else {
      [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"A Signature was not provided for payment with ref #%@.", [payment paymentRefId]] withTitle:@"iPOS"];
       
    }
}
-(void) signatureController: (SignatureViewController *) signatureController signatureAsImage: (UIImage *) signature savePressed: (id) sender {
	// We are not capturing the signature as an image, but as base64encoded string.
}

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex {
	if ([anAlertView.title isEqualToString:@"Payment Retry?"]) {
		if (aButtonIndex == 1) {
			[self cancelTenderAndLogout];
		}
	}
	// On a retry or other generic alerts, it will just fall through and dismiss with no other actions.
}


#pragma mark -
#pragma mark Demo Methods
- (void) processOrderAsDemo: (id) sender {
    BOOL isOrderSaved = [self isOrderSaved];
    BOOL isPaymentTendered = NO;
    
    // When the Credit Card is scanned we are going to:
    // 1.  Create the order in POS
    // 2.  Process the payment with indicated amount
    // 3.  Prompt for signature
    
    if (!isOrderSaved) {
        isOrderSaved = [orderCart saveOrder];
        orderIsSaved = isOrderSaved;
    }
    
    if (isOrderSaved) {
        isPaymentTendered = [self tenderDemoPayment];
    }
    
    if (isPaymentTendered) {
        SignatureViewController *ccSignatureViewController = [[[SignatureViewController alloc] init] autorelease];
        
        ccSignatureViewController.delegate = self;
        
        [self presentModalViewController:ccSignatureViewController animated:YES];
        ccSignatureViewController.payAmountLabel.text = [NSString formatDecimalNumberAsMoney:self.paymentAmount];
        
        // Remove the credit card view
        if (chargeCCView) {
            [chargeCCView removeFromSuperview];
            chargeCCView = nil;
        } 
    }
}
- (BOOL) tenderDemoPayment {
    BOOL isPaymentTendered = NO;
    
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    self.payment = [[[CreditCardPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
    
    [payment setNameOnCard:@"Joe Testing"];
    [payment setCardNumber:@"1111222233334444"];
    [payment setExpireDateMonthYear:@"11" year:@"14"] ;
    [payment setPaymentAmount:[[self paymentAmount] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]];
    
    [facade tenderPaymentWithCC:payment];
    
    if ([[payment errorList] count] == 0) {
        isPaymentTendered = YES;
    } else {
        [self showPaymentRetryAlert:payment];
    }    
    return isPaymentTendered;
}

#pragma mark -
#pragma mark Private Interface
- (UIView *) buildTenderTotalView {
    CGRect rect = [self rectForNavAndStatus];
    UIColor *bgColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    rect.size.height = rect.size.height - (3 * TOOLBAR_HEIGHT);
    
    tenderTotalView = [[[GradientView alloc] initWithFrame:rect] autorelease];
	tenderTotalView.backgroundColor = bgColor;
    
    [tenderTotalView setStart:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] andEndColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    
    // Layout the labels for the order totals
    CGFloat currentY = LABEL_STARTY;
    
    // Build out the labels
    UILabel *itemsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    itemsTitleLabel.backgroundColor = [UIColor clearColor];
    itemsTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	itemsTitleLabel.textAlignment = UITextAlignmentLeft; 
    itemsTitleLabel.text = @"Items";
    retailTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    retailTotalLabel.backgroundColor = [UIColor clearColor];
    retailTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	retailTotalLabel.textAlignment = UITextAlignmentRight; 
    retailTotalLabel.text = @"$0.00";
    
    
    currentY += LABEL_HEIGHT + LABEL_SPACING;
    
    UILabel *discountTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    discountTitleLabel.backgroundColor = [UIColor clearColor];
    discountTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	discountTitleLabel.textAlignment = UITextAlignmentLeft; 
    discountTitleLabel.text = @"Discount";
    discountTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    discountTotalLabel.backgroundColor = [UIColor clearColor];
    discountTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	discountTotalLabel.textAlignment = UITextAlignmentRight; 
    discountTotalLabel.text = @"($0.00)";
    
    // line
    LineView *discountLine = [[[LineView alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH+LABEL_WIDTH-LINE_WIDTH, currentY+LABEL_HEIGHT+LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)] autorelease];
    
    currentY += LABEL_HEIGHT + 2*LABEL_SPACING;
    
    UILabel *subTotalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    subTotalTitleLabel.backgroundColor = [UIColor clearColor];
    subTotalTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	subTotalTitleLabel.textAlignment = UITextAlignmentLeft; 
    subTotalTitleLabel.text = @"Subtotal";
    subTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    subTotalLabel.backgroundColor = [UIColor clearColor];
    subTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	subTotalLabel.textAlignment = UITextAlignmentRight; 
    subTotalLabel.text = @"$0.00";
    
    currentY += LABEL_HEIGHT + LABEL_SPACING;
    
    UILabel *taxTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    taxTitleLabel.backgroundColor = [UIColor clearColor];
    taxTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	taxTitleLabel.textAlignment = UITextAlignmentLeft; 
    taxTitleLabel.text = @"Tax";
    taxTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    taxTotalLabel.backgroundColor = [UIColor clearColor];
    taxTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	taxTotalLabel.textAlignment = UITextAlignmentRight; 
    taxTotalLabel.text = @"$0.00";
    
    // line
    LineView *totalLine = [[[LineView alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH+LABEL_WIDTH-LINE_WIDTH, currentY+LABEL_HEIGHT+LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)] autorelease];
    
    currentY += LABEL_HEIGHT + 2*LABEL_SPACING;
    UILabel *totalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    totalTitleLabel.backgroundColor = [UIColor clearColor];
    totalTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	totalTitleLabel.textAlignment = UITextAlignmentLeft; 
    totalTitleLabel.text = @"Total";
    totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	totalLabel.textAlignment = UITextAlignmentRight; 
    totalLabel.text = @"$0.00";
    
    
    // Add the the view
    [tenderTotalView addSubview:itemsTitleLabel];
    [tenderTotalView addSubview:discountTitleLabel];
    [tenderTotalView addSubview:subTotalTitleLabel];
    [tenderTotalView addSubview:taxTitleLabel]; 
    [tenderTotalView addSubview:totalTitleLabel]; 
    [tenderTotalView addSubview:retailTotalLabel];
    [tenderTotalView addSubview:discountTotalLabel];
    [tenderTotalView addSubview:discountLine];
    [tenderTotalView addSubview:subTotalLabel];
    [tenderTotalView addSubview:taxTotalLabel]; 
    [tenderTotalView addSubview:totalLine];
    [tenderTotalView addSubview:totalLabel];
    
    
    // Release objects
    [itemsTitleLabel release];
    [discountTitleLabel release];
    [subTotalTitleLabel release];
    [taxTitleLabel release];
    [totalTitleLabel release];
    [retailTotalLabel release];
    [discountTotalLabel release];
    [subTotalLabel release];
    [taxTotalLabel release];
    [totalLabel release];
    
    return tenderTotalView;
}

- (UIView *) buildSeparatorView {
    CGRect rect = [self rectForNavAndStatus];
    UIColor *bgColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    
    rect.origin.y = rect.size.height - (3 * TOOLBAR_HEIGHT) - SEPARATOR_HEIGHT;
    rect.size.height = SEPARATOR_HEIGHT;
    
    separatorView = [[[GradientView alloc] initWithFrame:rect] autorelease];
	separatorView.backgroundColor = bgColor;
    
    [separatorView setStart:[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] andEndColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    return separatorView;
}

- (void) updateDisplayValues {
    Order *order = [orderCart getOrder];
    
    if (order != nil) {
        // Set the tender payment totals
        NSDecimalNumber *subTotal = [order calcOrderSubTotal];
        NSDecimalNumber *tax = [order calcOrderTax];
        retailTotalLabel.text = [NSString formatDecimalNumberAsMoney:[order calcOrderRetailSubTotal]];
        discountTotalLabel.text =  [NSString stringWithFormat:@"(%@)", [NSString formatDecimalNumberAsMoney:[order calcOrderDiscountTotal]]];
        subTotalLabel.text = [NSString formatDecimalNumberAsMoney:subTotal];
        taxTotalLabel.text = [NSString formatDecimalNumberAsMoney:tax];
        totalLabel.text = [NSString formatDecimalNumberAsMoney: [subTotal decimalNumberByAdding:tax]];
        balancePaidLabel.text = [NSString formatDecimalNumberAsMoney:[order calcBalancePaid]];
        balanceOwingLabel.text = [NSString formatDecimalNumberAsMoney:[order calcBalanceOwing]];
        balanceDueLabel.text = [NSString formatDecimalNumberAsMoney:[order calcBalanceDue]];
    } else {
        retailTotalLabel.text = @"0.00";
        discountTotalLabel.text =  @"(0.00)";
        subTotalLabel.text = @"0.00";
        taxTotalLabel.text = @"0.00";
        balancePaidLabel.text = @"0.00";
        balanceOwingLabel.text = @"0.00";
        balanceDueLabel.text = @"0.00";
    }
    
    if (order.isNewOrder || order.previousPayments  == nil || [order.previousPayments count] == 0) {
        balancePaidTitleLabel.hidden = YES;
        balancePaidLabel.hidden = YES;
        balanceOwingTitleLabel.hidden = YES;
        balanceOwingLabel.hidden = YES;
    } else {
        balancePaidTitleLabel.hidden = NO;
        balancePaidLabel.hidden = NO;
        balanceOwingTitleLabel.hidden = NO;
        balanceOwingLabel.hidden = NO;
    }
}

- (void) handleCreditCardPayment:(id)sender {
    Order *order = [orderCart getOrder];
    
    if ([order purchaseOrderInfoRequired] && (order.purchaseOrderId == nil || [order.purchaseOrderId isEmpty])) {
        [AlertUtils showModalAlertMessage:@"Please enter a PO before accepting an On Account payment." withTitle:@"iPOS"];
    } else {
        self.navigationItem.hidesBackButton = YES;
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        CGRect overlayRect = self.view.bounds;
        chargeCCView = [[ChargeCreditCardView alloc] initWithFrame:overlayRect];
        
        chargeCCView.viewDelegate = self;
        chargeCCView.balanceDue = balanceDueLabel.text;
        chargeCCView.totalBalance = totalLabel.text;
        
        [self.view addSubview:chargeCCView];
        
        [chargeCCView release];
    }
}

-(void)handleAccountPayment:(id)sender {
    Order *order = [orderCart getOrder];
    
    if ([order purchaseOrderInfoRequired] && (order.purchaseOrderId == nil || [order.purchaseOrderId isEmpty])) {
        [AlertUtils showModalAlertMessage:@"Please enter a PO before accepting an On Account payment." withTitle:@"iPOS"];
    } else {
        self.navigationItem.hidesBackButton = YES;
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        CGRect overlayRect = self.view.bounds;
        accountPaymentView = [[AccountPaymentView alloc] initWithFrame:overlayRect];
        accountPaymentView.viewDelegate = self;
        accountPaymentView.balanceDue = balanceDueLabel.text;
        accountPaymentView.totalAccountBalance =  [NSString formatDecimalNumberAsMoney:[[orderCart getCustomerForOrder] calculateAccountBalance]];
        
        [self.view addSubview:accountPaymentView];
        
        [accountPaymentView release];
    }
}

-(void)displayNotesAndPOView:(id)sender {
    
    NSLog(@"displaying Notes and PO view");
    
    NotesController *notesOverlay = [[[NotesController alloc] init] autorelease];
    notesOverlay.notesDelegate = self;
    notesOverlay.notesData = [orderCart getOrder].notes;
    notesOverlay.purchaseOrderData = [orderCart getOrder].purchaseOrderId;
    [self.navigationController pushViewController:notesOverlay animated:YES];
}

- (void) handleSuspendOrder:(id) sender {
    // Cancel the order and completely Logoff
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL) tenderPaymentFromCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    BOOL isPaymentTendered = NO;
    NSDictionary *card = [linea msProcessFinancialCard:track1 track2:track2];
	
    if(card) {
        NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
		self.payment = [[[CreditCardPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
        [payment setNameOnCard:[[(NSString *)[card valueForKey:@"cardholderName"] copy] autorelease]];
        [payment setCardNumber:[[(NSString *)[card valueForKey:@"accountNumber"] copy] autorelease]];
        [payment setPaymentAmount:[[self paymentAmount] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]];
        [payment setExpireDateMonthYear:[[(NSString *)[card valueForKey:@"expirationMonth"] copy] autorelease] 
                                     year:[[(NSString *)[card valueForKey:@"expirationYear"] copy] autorelease]] ;
        
        [facade tenderPaymentWithCC:payment];
        
        if ([[payment errorList] count] == 0) {
            isPaymentTendered = YES;
        } else {
            [self showPaymentRetryAlert:payment];
        }
    }
    
    return isPaymentTendered;
}

- (void) showPaymentRetryAlert:(Payment *) aCCPayment {
    
    if (payment) {
        UIAlertView *paymentAlert = [[UIAlertView alloc] init];
        NSMutableString *errMsg = [[[NSMutableString alloc] init] autorelease];
        
        for (Error *e in aCCPayment.errorList) {
            NSLog(@"Error Id: %@ %@", e.errorId, e.message);
            [errMsg appendFormat:@"\nError (%@): %@", e.errorId, e.message];
        }
        
        [errMsg appendString:@"\nWould you like to try again?"];
        
        
        paymentAlert.title = @"Payment Retry?";
        paymentAlert.message = errMsg;
        paymentAlert.delegate = self;
        
        [paymentAlert addButtonWithTitle:@"Retry"];
        [paymentAlert addButtonWithTitle:@"Cancel"];
        [paymentAlert show];
        [paymentAlert release];
    }
}

#pragma mark- Notes And PO View delegate method 
-(void)close:(NotesController *)notesView {
    
    if (notesView.notesData != nil)
    {
        [orderCart getOrder].notes = notesView.notesData;
    }
    
    if (notesView.purchaseOrderData != nil)
    {
        [orderCart getOrder].purchaseOrderId = notesView.purchaseOrderData;
    }
}

-(void) navToReceipt {
    // Make sure we clear out the payment at this point
    self.payment = nil;
    
    [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Order %@ was successfully processed.", [orderCart getOrder].orderId] withTitle:@"iPOS"];
    
    // Navigate to the Send Receipt View Controller
    [[self navigationController] pushViewController:[[[ReceiptViewController alloc]init]autorelease] animated:YES];
}

- (BOOL) isOrderSaved {
    // If the order is already created it will have a valid order id.
    Order *order = [orderCart getOrder];
    
    if (order.orderId != nil && ![order.orderId isEqualToNumber:[NSNumber numberWithInt:0]] && ![order isModified]) { 
        return YES;
    }
    
    return NO;
}

- (void) cancelTenderAndLogout {
    Order *order = [orderCart getOrder];
    
    [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"No payment received for order %@.", order.orderId] withTitle:@"iPOS"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Payment on Account
-(void)cancelAccountPayment:(id)sender {
    
    if (!orderIsSaved) {
        self.navigationItem.hidesBackButton = NO;
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    if (accountPaymentView) {
        [accountPaymentView removeFromSuperview];
        accountPaymentView = nil;
    }
}


@end
