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

#import "SSLineView.h"


#import "ChargeCreditCardView.h"
#import "ReceiptViewController.h"
#import "SignatureViewController.h"

#import "NSString+StringFormatters.h"

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
- (void) handleSuspendOrder: (id) sender;
-(void) sendPaymentOnAccount:(NSDecimalNumber *) amount;

- (void) layoutView: (UIInterfaceOrientation) orientation;
- (void) updateDisplayValues;

- (BOOL) createOrder;
- (BOOL) tenderPaymentFromCardData: (NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3;
- (BOOL) isOrderCreated;

- (void) showPaymentRetryAlert:(Payment *) aCCPayment;
- (void) cancelTenderAndLogout;
-(NSDecimalNumber *) getOrderBalanceDue;

- (void) navToReceipt;
- (void) displayPayOnAccountSuccesfulView;
@end

@implementation TenderPaymentViewController

@synthesize paymentAmount, ccPayment;//, accountPayment;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Tender"];
    
	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];
    orderCart = [OrderCart sharedInstance];
	
    return self;
}

- (void)dealloc {
    [paymentAmount release];
    [ccPayment release];
    
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
    balanceDueTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
    balanceDueTitleLabel.text = @"Balance Due";
    balanceDueTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    balanceDueTitleLabel.textAlignment = UITextAlignmentLeft;
    
    balanceDueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balanceDueLabel.textColor = [UIColor blueColor];
    balanceDueLabel.text = @"$0.00";
    balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balanceDueLabel.textAlignment = UITextAlignmentRight;
    
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
    
    
    if (![orderCart getCustomerForOrder].isPaymentOnAccountEligable)
    {
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
    linea = [Linea sharedDevice];
	
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
    
    CGFloat balanceDueY = viewBounds.size.height - LABEL_SPACING - LABEL_HEIGHT - TOOLBAR_HEIGHT;
    
    balanceDueTitleLabel.frame = CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT);        
    balanceDueLabel.frame = CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT);
    
    // Layout the toolbar
    paymentToolbar.frame = CGRectMake(0.0f, viewBounds.size.height - TOOLBAR_HEIGHT, viewBounds.size.width, TOOLBAR_HEIGHT);
    
    if (chargeCCView) {
        chargeCCView.frame = self.view.bounds;
    }

}

#pragma mark -
#pragma mark ChargeCreditCardViewDelegate
- (void) setupKeyboardSupport:(id)theChargeCCView {
    
    if([theChargeCCView conformsToProtocol:@protocol(PaymentView)] == YES)
    {
        ExtUITextField *chargeAmtField = [theChargeCCView getChargeAmountTextField];
        
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
    
    // If the order is already created, logout and prompt user to process payment on POS
    if ([self isOrderCreated]) { 
        [self cancelTenderAndLogout];
    } else {
        self.navigationItem.hidesBackButton = NO;
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
        if (chargeCCView) {
            [chargeCCView removeFromSuperview];
        }
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
    BOOL isOrderCreated = [self isOrderCreated];
    BOOL isPaymentTendered = NO;
    
    int sound[]={2730,150,0,30,2730,150};
	[linea playSound:100 beepData:sound length:sizeof(sound)];
    
    // When the Credit Card is scanned we are going to:
    // 1.  Create the order in POS
    // 2.  Process the payment with indicated amount
    // 3.  Prompt for signature
    
    // Only create the order if it is not created at this point
    if (!isOrderCreated) {
        isOrderCreated = [self createOrder];
    }
    
    if (isOrderCreated) {
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
        } 
    }
}

-(NSDecimalNumber *) getOrderBalanceDue {
    
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *balanceDue = [[[orderCart getOrder] calcBalanceDue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    
    return balanceDue;
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
    NSDecimalNumber *balanceDue = [self getOrderBalanceDue];//[[self getOrderBalanceDue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    NSDecimalNumber *orderAmount = [[[order calcOrderSubTotal] decimalNumberByAdding:[order calcOrderTax]] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    
    if (textField.tagName == ACCOUNT)
    {
        //If the amount is greater than our credit available then display a warning
        if([amount compare:[[orderCart getCustomerForOrder] calculateAccountBalance]] == NSOrderedDescending)
        {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the account balance."];
            return; 
        }
        else if ([amount compare:orderAmount] == NSOrderedDescending) {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the order total balance."];
            return;        
        }
        else
        {
            if([amount compare:balanceDue] == NSOrderedSame)
            {
                if ([self createOrder])
                {
                    [self sendPaymentOnAccount:amount];
                }
            }
            else
            {
                [orderCart getCustomerForOrder].amountAppliedOnAccount = amount;
                [orderCart getOrder].partialPaymentOnAccount = YES;
                [self createOrder];
                [self sendPaymentOnAccount:amount];
            }
            
        }
        
    }
    else if (textField.tagName == CREDIT)
    {
        if ([amount compare:balanceDue] == NSOrderedAscending) {
            [AlertUtils showModalAlertMessage:@"Cannot charge less than the balance due."];
            return;
        } else if ([amount compare:orderAmount] == NSOrderedDescending) {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the order total balance."];
            return;
        }
        
        // If the amount was $0.00 at this point, it is a fully open order.  Create the open order and we are done.
        if ([amount compare:[NSDecimalNumber zero]] == NSOrderedSame) {
            BOOL isOrderCreated = [self createOrder];
            
            if (isOrderCreated) {
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
-(void) sendPaymentOnAccount:(NSDecimalNumber *) amount {
    self.ccPayment = [[[AccountPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
    [ccPayment setPaymentAmount:amount];
    [facade tenderPaymentOnAccount:ccPayment];
    
    if ([[ccPayment errorList] count] == 0) {
        SignatureViewController *signatureViewController = [[[SignatureViewController alloc] init] autorelease];
        signatureViewController.delegate = self;
        
        [self presentModalViewController:signatureViewController animated:YES];
        signatureViewController.payAmountLabel.text = [NSString formatDecimalNumberAsMoney:amount];
        
    } else {
        [self showPaymentRetryAlert:ccPayment];
    }
    
}

#pragma mark -

-(void)displayPayOnAccountSuccesfulView
{
    
    UILabel *textLabel = [[UILabel alloc ]initWithFrame:CGRectMake(self.view.frame.size.width / 6, self.view.frame.size.height / 4, 225.0f, 100.0f)];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.layer.cornerRadius = 5.0f;
    textLabel.text = @"Payment Successful";
    textLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    textLabel.textAlignment = UITextAlignmentCenter;
    
	[UIView beginAnimations: @"Fade Out" context:nil];
	
	// wait for time before begin
	[UIView setAnimationDelay:0.0];
	[self.view addSubview:textLabel];
    [textLabel release];
	// druation of animation
	[UIView setAnimationDuration:3.0];
	textLabel.alpha = 0.0;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark SignatureDelegate methods

- (void) signatureController:(SignatureViewController *)signatureController signatureAsBase64:(NSString *)signature savePressed:(id)sender {
   // BOOL isSignatureAccepted = YES;

    if (ccPayment && signature)
    {
        if([ccPayment isKindOfClass:[CreditCardPayment class]])
        {
            NSLog(@"It is a credit card!");
            [self.ccPayment attachSignature:signature];
            
            if (![facade acceptSignatureFor:self.ccPayment]) {
                [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Problem accepting signature for payment with ref #%@.", [ccPayment paymentRefId]]];
                //isSignatureAccepted = NO;
            }
            else {
                [self navToReceipt];
            }
            
        }
        else if ([ccPayment isKindOfClass:[AccountPayment class]])
        {
            [self.ccPayment attachSignature:signature];

            if (![facade acceptSignatureOnAccount:self.ccPayment]) {
                [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Problem accepting signature for payment with ref #%@.", [ccPayment paymentRefId]]];
            }
            else {
                
                if([[ccPayment paymentAmount] compare:[self getOrderBalanceDue]] == NSOrderedSame) {
                     [self navToReceipt];

                }
                else {
                    [self dismissModalViewControllerAnimated:YES];
                    [accountPaymentView removeFromSuperview];
                    [self updateDisplayValues];
                    [self displayPayOnAccountSuccesfulView];
                }
            }
        }
    }
    else
    {
      [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"A Signature was not provided for payment with ref #%@.", [ccPayment paymentRefId]]];
       
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
    BOOL isOrderCreated = [self isOrderCreated];
    BOOL isPaymentTendered = NO;
    
    // When the Credit Card is scanned we are going to:
    // 1.  Create the order in POS
    // 2.  Process the payment with indicated amount
    // 3.  Prompt for signature
    
    if (!isOrderCreated) {
        isOrderCreated = [self createOrder];
    }
    
    if (isOrderCreated) {
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
        } 
    }
}
- (BOOL) tenderDemoPayment {
    BOOL isPaymentTendered = NO;
    
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    self.ccPayment = [[[CreditCardPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
    
    [ccPayment setNameOnCard:@"Joe Testing"];
    [ccPayment setCardNumber:@"1111222233334444"];
    [ccPayment setExpireDateMonthYear:@"11" year:@"14"] ;
    [ccPayment setPaymentAmount:[[self paymentAmount] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]];
    
    [facade tenderPaymentWithCC:ccPayment];
    
    if ([[ccPayment errorList] count] == 0) {
        isPaymentTendered = YES;
    } else {
        [self showPaymentRetryAlert:ccPayment];
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
    SSLineView *discountLine = [[[SSLineView alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH+LABEL_WIDTH-LINE_WIDTH, currentY+LABEL_HEIGHT+LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)] autorelease];
    
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
    SSLineView *totalLine = [[[SSLineView alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH+LABEL_WIDTH-LINE_WIDTH, currentY+LABEL_HEIGHT+LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)] autorelease];
    
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
        balanceDueLabel.text = [NSString formatDecimalNumberAsMoney:[self getOrderBalanceDue]];
    } else {
        retailTotalLabel.text = @"0.00";
        discountTotalLabel.text =  @"(0.00)";
        subTotalLabel.text = @"0.00";
        taxTotalLabel.text = @"0.00";
        balanceDueLabel.text = @"0.00";
    }
}

- (void) handleCreditCardPayment:(id)sender {
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    CGRect overlayRect = self.view.bounds;
    chargeCCView = [[ChargeCreditCardView alloc] initWithFrame:overlayRect];
    
    chargeCCView.viewDelegate = self;
    chargeCCView.balanceDue = balanceDueLabel.text;
    chargeCCView.totalBalance = totalLabel.text;
    
    [self.view addSubview:chargeCCView];
}

-(void)handleAccountPayment:(id)sender {
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    CGRect overlayRect = self.view.bounds;
    accountPaymentView = [[AccountPaymentView alloc] initWithFrame:overlayRect];
    accountPaymentView.viewDelegate = self;
    accountPaymentView.balanceDue = balanceDueLabel.text;
    accountPaymentView.totalAccountBalance =  [NSString formatDecimalNumberAsMoney:[[orderCart getCustomerForOrder] calculateAccountBalance]];
    
    [self.view addSubview:accountPaymentView];
    
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

- (BOOL) createOrder {
    Order *cartOrder = [orderCart getOrder];
    
    [facade newOrder:cartOrder];
    
    if ([cartOrder.errorList count] == 0 && cartOrder.orderId != nil) {
        return YES;
    }
    
    [AlertUtils showModalAlertForErrors:cartOrder.errorList];
    return NO;    
}

- (BOOL) tenderPaymentFromCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    BOOL isPaymentTendered = NO;
    financialCard card;
	
    if([linea msProcessFinancialCard:&card track1:track1 track2:track2]) {
        NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
		self.ccPayment = [[[CreditCardPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
        [ccPayment setNameOnCard:[[card.cardholderName copy] autorelease]];
        [ccPayment setCardNumber:[[card.accountNumber copy] autorelease]];
        [ccPayment setPaymentAmount:[[self paymentAmount] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]];
        [ccPayment setExpireDateMonthYear:[NSString stringWithFormat:@"%d",card.exirationMonth] 
                                     year:[NSString stringWithFormat:@"%d",card.exirationYear]] ;
        
        [facade tenderPaymentWithCC:ccPayment];
        
        if ([[ccPayment errorList] count] == 0) {
            isPaymentTendered = YES;
        } else {
            [self showPaymentRetryAlert:ccPayment];
        }
    }
    
    return isPaymentTendered;
}

- (void) showPaymentRetryAlert:(Payment *) aCCPayment {
    
    if (ccPayment) {
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
    self.ccPayment = nil;
    
    // For now dismiss and logout
    [self dismissModalViewControllerAnimated:YES];
    [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Order %@ was successfully processed.", [orderCart getOrder].orderId]];
    
    // Navigate to the Send Receipt View Controller
    [[self navigationController] pushViewController:[[[ReceiptViewController alloc]init]autorelease] animated:YES];
}

- (BOOL) isOrderCreated {
    // If the order is already created it will have a valid order id.
    Order *order = [orderCart getOrder];
    
    if (order.orderId != nil && ![order.orderId isEqualToNumber:[NSNumber numberWithInt:0]]) { 
        return YES;
    }
    
    return NO;
}

- (void) cancelTenderAndLogout {
    Order *order = [orderCart getOrder];
    
    [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Order %@ was created, but no payment received.", order.orderId]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Payment on Account
-(void)cancelAccountPayment:(id)sender {
    self.navigationItem.hidesBackButton = NO;
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    if (accountPaymentView) {
        [accountPaymentView removeFromSuperview];
    }
}


@end
