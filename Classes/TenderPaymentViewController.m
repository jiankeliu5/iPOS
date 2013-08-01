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

#import "CustomerEditViewController.h"

#import "CustomerFormDataSource.h"

#import "OtherPaymentViewController.h"

#import "LookupOrderUtil.h"

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

static int calendarShadowOffset = (int)-20;

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
@synthesize calendar;

@synthesize selectdate;

@synthesize displaydate;

@synthesize requestString;

@synthesize reqdate;

Order *copyOriginalOrder;

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
    
    calendar = 	[[TKCalendarMonthView alloc] init];
    calendar.delegate = self;
    calendar.dataSource = self;
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
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
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
    balancePaidTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    balancePaidLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balancePaidLabel.textColor = [UIColor blueColor];
    balancePaidLabel.text = @"$0.00";
    balancePaidLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balancePaidLabel.textAlignment = NSTextAlignmentRight;
    
    balanceOwingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
    balanceOwingTitleLabel.text = @"Owing";
    balanceOwingTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    balanceOwingTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    balanceOwingLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balanceOwingLabel.textColor = [UIColor blueColor];
    balanceOwingLabel.text = @"$0.00";
    balanceOwingLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balanceOwingLabel.textAlignment = NSTextAlignmentRight;
    
    balanceDueTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
    balanceDueTitleLabel.text = @"Balance Due";
    balanceDueTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    balanceDueTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    balanceDueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + LABEL_TITLE_WIDTH, balanceDueY, LABEL_WIDTH, LABEL_HEIGHT)];
    balanceDueLabel.textColor = [UIColor blueColor];
    balanceDueLabel.text = @"$0.00";
    balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    balanceDueLabel.textAlignment = NSTextAlignmentRight;
    
    displaydate = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX - 20, balanceDueY - 30, LABEL_BALDUE_WIDTH + 20, LABEL_HEIGHT)];
    displaydate.text = @"Promise Date: ";
    displaydate.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    displaydate.textAlignment = NSTextAlignmentLeft;
    
    reqdate = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX + 90, balanceDueY - 30, LABEL_BALDUE_WIDTH + 20, LABEL_HEIGHT)];
    reqdate.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    reqdate.textColor = [UIColor orangeColor];
    reqdate.textAlignment = NSTextAlignmentLeft;
    
    NSDate *tempdate = [NSDate date];
    //NSDate *currdate = [tempdate dateByAddingTimeInterval:60*60*24*14];
    NSDate *currdate = tempdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currdate];
    Order *order = [orderCart getOrder];
    //Enning Tang Dont update request date everytime
    if ([order isNewOrder])
    {
        reqdate.text = dateString;
    }
    else
    {
        NSString *split = [order.requestDate substringToIndex:10];
        reqdate.text = split;
        selectdate.hidden = YES;
        
    }
    //reqdate.text = dateString;
    requestString = dateString;
    
    // Add button to toggle calendar
	selectdate = [[UIButton alloc] initWithFrame:CGRectMake(LABEL_STARTX + 80, balanceDueY - 60, 80, 20)];
	selectdate.backgroundColor = [UIColor darkGrayColor];
	selectdate.titleLabel.font = [UIFont systemFontOfSize:12];
	selectdate.titleLabel.textColor = [UIColor whiteColor];
	[selectdate setTitle:@"Select a date" forState:UIControlStateNormal];
	[selectdate addTarget:self action:@selector(toggleCalendar) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:selectdate];
	[selectdate release];
	
	// Add Calendar to just off the top of the screen so it can later slide down
	calendar.frame = CGRectMake(0, -calendar.frame.size.height+calendarShadowOffset, calendar.frame.size.width, calendar.frame.size.height);
	// Ensure this is the last "addSubview" because the calendar must be the top most view layer
	[self.view addSubview:calendar];
	[calendar reload];
    
    [self.view addSubview:balancePaidTitleLabel];
    [self.view addSubview:balancePaidLabel];
    [self.view addSubview:balanceOwingTitleLabel];
    [self.view addSubview:balanceOwingLabel];
    [self.view addSubview:balanceDueTitleLabel];
    [self.view addSubview:balanceDueLabel];
    [self.view addSubview:displaydate];
    [self.view addSubview:reqdate];
    
    [balanceDueTitleLabel release];
    [balanceDueLabel release]; 
    
    // Add the susend button
    /*
    UIBarButtonItem *suspendButton = [[UIBarButtonItem alloc] init];
    suspendButton.title = @"Suspend";
    suspendButton.target = self;
    [suspendButton setAction:@selector(handleSuspendOrder:)];
    self.navigationItem.rightBarButtonItem = suspendButton;
    [suspendButton release];
     */
    
    
    // Add the payment toolbar to the bottom
    paymentToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, rectForView.size.height - [self navBarHeight], rectForView.size.width, TOOLBAR_HEIGHT)];
    paymentToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    
    UIBarButtonItem *tbFixed2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    
    tbFixed.width = 150.0;
    tbFixed2.width = 50.0;
    UIBarButtonItem *notesAndPOButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(displayNotesAndPOView:)] autorelease];
    
    
        UIBarButtonItem * accountPaymentButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notes.png"] 
                                                             style:UIBarButtonItemStylePlain 
                                                            target:self 
                                                            action:@selector(handleAccountPayment:)] autorelease];
    
    UIBarButtonItem *custButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"customer.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(displayCustomerEditingView:)] autorelease];
    
    //Add pay at cashdrawer Enning Tang 2013/04/17
    UIBarButtonItem *cashDrawer = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iposcashdrawer.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleCashDrawer:)] autorelease];
    
    
    if (![[orderCart getCustomerForOrder] isPaymentOnAccountEligable]) {
        [accountPaymentButton setEnabled:NO];
    } 
    
    UIBarButtonItem *creditCardButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CreditCard.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleCreditCardPayment:)] autorelease];
    NSArray *paymentToolbarItems = [[[NSArray alloc] initWithObjects:notesAndPOButton, tbFlex, custButton, tbFlex, accountPaymentButton, tbFixed2, cashDrawer, tbFixed2, creditCardButton, nil] autorelease];
    [paymentToolbar setItems:paymentToolbarItems];
    
    [self.view addSubview:paymentToolbar];
    [paymentToolbar release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Customer *cust = [orderCart getCustomerForOrder];
    UIAlertView *emailVerify = [[UIAlertView alloc] init];
    emailVerify.title = @"Email Verification";
    emailVerify.message = [NSString stringWithFormat:@"Customer's Email is: %@, is this correct?", cust.emailAddress];
    emailVerify.delegate = self;
    [emailVerify addButtonWithTitle:@"Yes"];
    [emailVerify addButtonWithTitle:@"Edit"];
    [emailVerify show];
    [emailVerify release];
	
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
    return NO;
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

// Show/Hide the calendar by sliding it down/up from the top of the device.
- (void)toggleCalendar {
	// If calendar is off the screen, show it, else hide it (both with animations)
	//if (calendar.frame.origin.y == -calendar.frame.size.height+calendarShadowOffset) {
    // Show
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    calendar.frame = CGRectMake(0, 0, calendar.frame.size.width, calendar.frame.size.height);
    [UIView commitAnimations];
	/*} else {
     // Hide
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:.75];
     calendar.frame = CGRectMake(0, -calendar.frame.size.height+calendarShadowOffset, calendar.frame.size.width, calendar.frame.size.height);
     [UIView commitAnimations];
     }*/
}

#pragma mark -
#pragma mark TKCalendarMonthViewDelegate methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
    NSDate *currdate = [NSDate date];
    
    NSComparisonResult result = [currdate compare:d];
    
    NSArray *dateChunkd = [[NSString stringWithFormat:@"%@", d] componentsSeparatedByString:@" "];
    NSArray *dateChunkc = [[NSString stringWithFormat:@"%@", currdate] componentsSeparatedByString:@" "];
    
    if (result == NSOrderedDescending)
    //if (d < currdate)
    {
        //Enning Tang Fixed cannot choose today's date bug
        NSComparisonResult resultdate = [dateChunkd[0] compare:dateChunkc[0]];
        if (resultdate != NSOrderedSame)
        {
            NSLog(@"d is : %@", [NSString stringWithFormat:@"%@", d]);
            NSLog(@"currdate is : %@", [NSString stringWithFormat:@"%@", currdate]);
            NSLog(@"the date is behind the current date");
            UIAlertView *datealert = [[UIAlertView alloc] init];
            datealert.title = @"Message";
            datealert.message = @"The request date must be set to a value on after today.";
            [datealert addButtonWithTitle:@"OK"];
            [datealert show];
            [datealert release];
        }else
        {
            NSString *datestring = [NSString stringWithFormat:@"%@",d];
            datestring = [datestring substringToIndex:19];
            NSString *datedisplay = [NSString stringWithFormat:@"%@", [datestring substringToIndex:10]];
            NSLog(@"calendarMonthView didSelectDate %@", datestring);
            reqdate.text = datedisplay;
            requestString = datestring;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.75];
            calendar.frame = CGRectMake(0, -calendar.frame.size.height+calendarShadowOffset, calendar.frame.size.width, calendar.frame.size.height);
            [UIView commitAnimations];
        }
    }
    else
    {
        NSString *datestring = [NSString stringWithFormat:@"%@",d];
        datestring = [datestring substringToIndex:19];
        NSString *datedisplay = [NSString stringWithFormat:@"%@", [datestring substringToIndex:10]];
        NSLog(@"calendarMonthView didSelectDate %@", datestring);
        reqdate.text = datedisplay;
        requestString = datestring;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.75];
        calendar.frame = CGRectMake(0, -calendar.frame.size.height+calendarShadowOffset, calendar.frame.size.width, calendar.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)d {
	NSLog(@"calendarMonthView monthDidChange");
}

#pragma mark -
#pragma mark TKCalendarMonthViewDataSource methods

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
	NSLog(@"calendarMonthView marksFromDate toDate");
	NSLog(@"Make sure to update 'data' variable to pull from CoreData, website, User Defaults, or some other source.");
	// When testing initially you will have to update the dates in this array so they are visible at the
	// time frame you are testing the code.
    
	NSArray *data = [NSArray arrayWithObjects:
					 @"2011-01-01 00:00:00 +0000", @"2011-01-09 00:00:00 +0000", @"2011-01-22 00:00:00 +0000",
					 @"2011-01-10 00:00:00 +0000", @"2011-01-11 00:00:00 +0000", @"2011-01-12 00:00:00 +0000",
					 @"2011-01-15 00:00:00 +0000", @"2011-01-28 00:00:00 +0000", @"2011-01-04 00:00:00 +0000",
					 @"2011-01-16 00:00:00 +0000", @"2011-01-18 00:00:00 +0000", @"2011-01-19 00:00:00 +0000",
					 @"2011-01-23 00:00:00 +0000", @"2011-01-24 00:00:00 +0000", @"2011-01-25 00:00:00 +0000",
					 @"2011-02-01 00:00:00 +0000", @"2011-03-01 00:00:00 +0000", @"2011-04-01 00:00:00 +0000",
					 @"2011-05-01 00:00:00 +0000", @"2011-06-01 00:00:00 +0000", @"2011-07-01 00:00:00 +0000",
					 @"2011-08-01 00:00:00 +0000", @"2011-09-01 00:00:00 +0000", @"2011-10-01 00:00:00 +0000",
					 @"2011-11-01 00:00:00 +0000", @"2011-12-01 00:00:00 +0000", nil];
	
	// Initialise empty marks array, this will be populated with TRUE/FALSE in order for each day a marker should be placed on.
	NSMutableArray *marks = [NSMutableArray array];
	
	// Initialise calendar to current type and set the timezone to never have daylight saving
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	// Construct DateComponents based on startDate so the iterating date can be created.
	// Its massively important to do this assigning via the NSCalendar and NSDateComponents because of daylight saving has been removed
	// with the timezone that was set above. If you just used "startDate" directly (ie, NSDate *date = startDate;) as the first
	// iterating date then times would go up and down based on daylight savings.
	NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit |
                                              NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit)
                                    fromDate:startDate];
	NSDate *d = [cal dateFromComponents:comp];
	
	// Init offset components to increment days in the loop by one each time
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:1];
	
    
	// for each date between start date and end date check if they exist in the data array
	while (YES) {
		// Is the date beyond the last date? If so, exit the loop.
		// NSOrderedDescending = the left value is greater than the right
		if ([d compare:lastDate] == NSOrderedDescending) {
			break;
		}
		
		// If the date is in the data array, add it to the marks array, else don't
		if ([data containsObject:[d description]]) {
			[marks addObject:[NSNumber numberWithBool:YES]];
		} else {
			[marks addObject:[NSNumber numberWithBool:NO]];
		}
		
		// Increment day using offset components (ie, 1 day in this instance)
		d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
	}
	
	[offsetComponents release];
	
	return [NSArray arrayWithArray:marks];
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
	[linea playSound:100 beepData:sound length:sizeof(sound)];
    
    // When the Credit Card is scanned we are going to:
    // 1.  Create the order in POS
    // 2.  Process the payment with indicated amount
    // 3.  Prompt for signature
    
    // Only create the order if it is not created at this point
    
    //Enning Tang Changed isSaved mark for solving duplicate orders 3/1/2013
    UIAlertView *alert = [AlertUtils showProgressAlertMessage:@"Processing Payment..."];
    isOrderSaved = orderIsSaved;
    
    if (!isOrderSaved) {
        Order *order = [orderCart getOrder];
        if (!order.isNewOrder)
        {
            originalOrder = [facade lookupOrderByOrderId:order.orderId]; //Enning Tang Added original order 3/19/2013
        }
        //Enning Tang Dont update request date everytime
        order.requestDate = [reqdate.text stringByAppendingString:@" 00:00:00"];
        NSLog(@"save order from magneticCardData");
        //Enning Tang commented 3/1/2013
        //isOrderSaved = [orderCart saveOrder];
        //orderIsSaved = isOrderSaved;
        orderIsSaved = [orderCart saveOrder];
        isOrderSaved = orderIsSaved;
        
    }
    [AlertUtils dismissAlertMessage: alert];
    //=====================================================================
    
    
    if (isOrderSaved) {
        isPaymentTendered = [self tenderPaymentFromCardData:track1 track2:track2 track3:track3];
        //Test
        //isPaymentTendered = YES;
    }
    
    if (isPaymentTendered) {
        //Enning Tang added check order payment before saving order 3/13/2013
        Order *order = [orderCart getOrder];
        NSLog(@"Check Order Payment OrderID: %@", [order.orderId stringValue]);
        //===================================================================
        
        SignatureViewController *ccSignatureViewController = [[[SignatureViewController alloc] init] autorelease];
        
        ccSignatureViewController.delegate = self;
        
        [self presentViewController:ccSignatureViewController animated:YES completion:nil];
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
    
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    
    Order *order = [orderCart getOrder];
    
    //order.requestDate = requestString;
    //NSLog(@"%@", order.requestDate);
    
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
                //Enning Tang Dont update request date everytime
                order.requestDate = [reqdate.text stringByAppendingString:@" 00:00:00"];
                if (!order.isNewOrder)
                {
                    originalOrder = [facade lookupOrderByOrderId:order.orderId]; //Enning Tang Added original order 3/19/2013
                }
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
            
            NSLog(@"Entered zero amount");
            BOOL isOrderSaved = orderIsSaved;
            
            if (!isOrderSaved) {
                //Enning Tang Dont update request date everytime
                order.requestDate = [reqdate.text stringByAppendingString:@" 00:00:00"];
                if (!order.isNewOrder)
                {
                    originalOrder = [facade lookupOrderByOrderId:order.orderId]; //Enning Tang Added original order 3/19/2013
                }
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
    
    //test
    
    /*
    SignatureViewController *ccSignatureViewController = [[[SignatureViewController alloc] init] autorelease];
    
    ccSignatureViewController.delegate = self;
    
    [self presentModalViewController:ccSignatureViewController animated:YES];
    ccSignatureViewController.payAmountLabel.text = [NSString formatDecimalNumberAsMoney:self.paymentAmount];
    */
    
}

#pragma mark -
#pragma mark Send payment on account method.

//Enning Tang on account Payment should be fixed 10/23/2012
- (BOOL) sendPaymentOnAccount:(NSDecimalNumber *) amount {
    self.payment = [[[AccountPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
    [payment setPaymentAmount:amount];
    [facade tenderPaymentOnAccount:payment];
    
    if ([[payment errorList] count] == 0) {
        SignatureViewController *signatureViewController = [[[SignatureViewController alloc] init] autorelease];
        signatureViewController.delegate = self;
        
        [self presentViewController:signatureViewController animated:YES completion:nil];
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
    textLabel.textAlignment = NSTextAlignmentCenter;
    
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

    NSLog(@"signatureAsBase64 called");
    if (payment && signature) {
        if([payment isKindOfClass:[CreditCardPayment class]]) {
            [self.payment attachSignature:signature];
            
            if (![facade acceptSignatureFor:self.payment]) {
                NSLog(@"acceptSignatureFor error from facade");
                Error *error = [[[Error alloc] init] autorelease];
                error.errorId = @"PMT_SIG";
                error.message = [NSString stringWithFormat:@"Problem accepting signature for payment with ref #%@.", [payment paymentRefId]];
                [payment addError:error];
                
                [AlertUtils showModalAlertForErrors:((Payment *)  payment).errorList withTitle: @"iPOS"];
            } 
        
            [self dismissViewControllerAnimated:YES completion:nil];
            [self navToReceipt];
        } else if ([payment isKindOfClass:[AccountPayment class]]) {
            [self.payment attachSignature:signature];

            if (![facade acceptSignatureOnAccount:self.payment]) {
                NSLog(@"acceptSignatureOnAccount error");
                Error *error = [[[Error alloc] init] autorelease];
                error.errorId = @"PMT_SIG";
                error.message = [NSString stringWithFormat:@"Problem accepting signature for payment with ref #%@.", [payment paymentRefId]];
                [payment addError:error];
                
                [AlertUtils showModalAlertForErrors:((Payment *)  payment).errorList withTitle: @"iPOS"];
                [self dismissViewControllerAnimated:YES completion:nil];
                [self navToReceipt];
            } else {
                if([[payment paymentAmount] compare:[[orderCart getOrder] calcBalanceDue]] == NSOrderedSame) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self navToReceipt];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
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
        //TEST
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self navToReceipt];
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
    
    //Enning Tang Add Email Verification 2/8/2013
    if ([anAlertView.title isEqualToString:@"Email Verification"]) {
        NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Edit"]) {
            NSLog(@"Email Verification from Tender Payment");
            Customer *customer = [orderCart getCustomerForOrder];
            if (customer != nil) {
                NSMutableDictionary *customerFormModel = [customer modelFromCustomer];
                CustomerFormDataSource *customerFormDataSource = [[[CustomerFormDataSource alloc] initWithModel:customerFormModel] autorelease];
                CustomerEditViewController *customerEditViewController = [[[CustomerEditViewController alloc] initWithNibName:nil bundle:nil formDataSource:customerFormDataSource] autorelease];
                [customerEditViewController setTitle:@"Customer Edit"];
                [[self navigationController] pushViewController:customerEditViewController animated:TRUE];
            } else {
                NSLog(@"Should not be trying to edit if customer is nil");
            }
		}
	}
    
    //Enning Add confirmation box 5/10/2013
    if ([anAlertView.message isEqualToString:@"iPOS will create the order and continue to the order payment screen, you may not go return to the previous screen or turn off your device, Continue?"]) {
        NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:aButtonIndex];
		if ([clickedButtonTitle isEqualToString:@"Continue"]) {
            NSLog(@"Continue to cash payment screen");
            BOOL isOrderSaved = [self isOrderSaved];
            if (!isOrderSaved) {
                Order *order = [orderCart getOrder];
                if (!order.isNewOrder)
                {
                    originalOrder = [facade lookupOrderByOrderId:order.orderId]; //Enning Tang Added original order 3/19/2013
                }
                //Enning Tang Dont update request date everytime
                order.requestDate = [reqdate.text stringByAppendingString:@" 00:00:00"];
                NSLog(@"save order from magneticCardData");
                //Enning Tang commented 3/1/2013
                //isOrderSaved = [orderCart saveOrder];
                //orderIsSaved = isOrderSaved;
                
                orderIsSaved = [orderCart saveOrder];
                isOrderSaved = orderIsSaved;
                
            }
            Order *order = [orderCart getOrder];
            NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2
                                                                                                          raiseOnExactness:NO raiseOnOverflow:NO
                                                                                                          raiseOnUnderflow:NO raiseOnDivideByZero:NO];
            NSDecimalNumber *setBalanceDue = [[order calcBalanceDue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
            NSDecimalNumber *setTotalBalanceDue = [[[order calcOrderSubTotal] decimalNumberByAdding:[order calcOrderTax]] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
            OtherPaymentViewController *otherPayment = [[OtherPaymentViewController alloc]initWithBalanceDue:setBalanceDue totalBalanceDue:setTotalBalanceDue];
            [otherPayment.navigationController setNavigationBarHidden:YES animated:YES];
            [self.navigationController pushViewController:otherPayment animated:YES];
		}
	}
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
        Order *order = [orderCart getOrder];
        //Enning Tang Dont update request date everytime
        order.requestDate = [reqdate.text stringByAppendingString:@" 00:00:00"];
        isOrderSaved = [orderCart saveOrder];
        orderIsSaved = isOrderSaved;
    }
    
    if (isOrderSaved) {
        isPaymentTendered = [self tenderDemoPayment];
    }
    
    if (isPaymentTendered) {
        SignatureViewController *ccSignatureViewController = [[[SignatureViewController alloc] init] autorelease];
        
        ccSignatureViewController.delegate = self;
        
        [self presentViewController:ccSignatureViewController animated:YES completion:nil];
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
	itemsTitleLabel.textAlignment = NSTextAlignmentLeft;
    itemsTitleLabel.text = @"Items";
    retailTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    retailTotalLabel.backgroundColor = [UIColor clearColor];
    retailTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	retailTotalLabel.textAlignment = NSTextAlignmentRight;
    retailTotalLabel.text = @"$0.00";
    
    
    currentY += LABEL_HEIGHT + LABEL_SPACING;
    
    UILabel *discountTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    discountTitleLabel.backgroundColor = [UIColor clearColor];
    discountTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	discountTitleLabel.textAlignment = NSTextAlignmentLeft;
    discountTitleLabel.text = @"Discount";
    discountTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    discountTotalLabel.backgroundColor = [UIColor clearColor];
    discountTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	discountTotalLabel.textAlignment = NSTextAlignmentRight;
    discountTotalLabel.text = @"($0.00)";
    
    // line
    LineView *discountLine = [[[LineView alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH+LABEL_WIDTH-LINE_WIDTH, currentY+LABEL_HEIGHT+LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)] autorelease];
    
    currentY += LABEL_HEIGHT + 2*LABEL_SPACING;
    
    UILabel *subTotalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    subTotalTitleLabel.backgroundColor = [UIColor clearColor];
    subTotalTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	subTotalTitleLabel.textAlignment = NSTextAlignmentLeft;
    subTotalTitleLabel.text = @"Subtotal";
    subTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    subTotalLabel.backgroundColor = [UIColor clearColor];
    subTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	subTotalLabel.textAlignment = NSTextAlignmentRight;
    subTotalLabel.text = @"$0.00";
    
    currentY += LABEL_HEIGHT + LABEL_SPACING;
    
    UILabel *taxTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    taxTitleLabel.backgroundColor = [UIColor clearColor];
    taxTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	taxTitleLabel.textAlignment = NSTextAlignmentLeft;
    taxTitleLabel.text = @"Tax";
    taxTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    taxTotalLabel.backgroundColor = [UIColor clearColor];
    taxTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	taxTotalLabel.textAlignment = NSTextAlignmentRight;
    taxTotalLabel.text = @"$0.00";
    
    // line
    LineView *totalLine = [[[LineView alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH+LABEL_WIDTH-LINE_WIDTH, currentY+LABEL_HEIGHT+LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)] autorelease];
    
    currentY += LABEL_HEIGHT + 2*LABEL_SPACING;
    UILabel *totalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX, currentY, LABEL_TITLE_WIDTH, LABEL_HEIGHT)];
    totalTitleLabel.backgroundColor = [UIColor clearColor];
    totalTitleLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	totalTitleLabel.textAlignment = NSTextAlignmentLeft;
    totalTitleLabel.text = @"Total";
    totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_STARTX+LABEL_TITLE_WIDTH, currentY, LABEL_WIDTH, LABEL_HEIGHT)];
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	totalLabel.textAlignment = NSTextAlignmentRight;
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
        displaydate.hidden = YES;
        reqdate.hidden = YES;
        selectdate.hidden = YES;
    }
}

- (void) handleCreditCardPayment:(id)sender {
    Order *order = [orderCart getOrder];
    
    if ([order purchaseOrderInfoRequired] && (order.purchaseOrderId == nil || [order.purchaseOrderId isEmpty])) {
        [AlertUtils showModalAlertMessage:@"PO required before accepting this payment, please enter one." withTitle:@"iPOS"];
    } else {
        
        //Enning Tang pop up a message box to notify promise date
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"The Promise date will be set to %@", self.reqdate.text] withTitle:@"iPOS"];
        //========================================================
        
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
        
        //Enning Tang pop up a message box to notify promise date
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"The Promise date will be set to %@", self.reqdate.text] withTitle:@"iPOS"];
        //=======================================================
        
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

//Enning Tang Add Customer Editing view
-(void)displayCustomerEditingView:(id)sender {
    
    NSLog(@"displaying Customer Editing view");
    
    /*
    NotesController *notesOverlay = [[[NotesController alloc] init] autorelease];
    notesOverlay.notesDelegate = self;
    notesOverlay.notesData = [orderCart getOrder].notes;
    notesOverlay.purchaseOrderData = [orderCart getOrder].purchaseOrderId;
    [self.navigationController pushViewController:notesOverlay animated:YES];
    */
    //====================
    
    Customer *customer = [orderCart getCustomerForOrder];
    if (customer != nil) {
		NSMutableDictionary *customerFormModel = [customer modelFromCustomer];
		CustomerFormDataSource *customerFormDataSource = [[[CustomerFormDataSource alloc] initWithModel:customerFormModel] autorelease];
		CustomerEditViewController *customerEditViewController = [[[CustomerEditViewController alloc] initWithNibName:nil bundle:nil formDataSource:customerFormDataSource] autorelease];
		[customerEditViewController setTitle:@"Customer Edit"];
		[[self navigationController] pushViewController:customerEditViewController animated:TRUE];
	} else {
		NSLog(@"Should not be trying to edit if customer is nil");
	}
}

- (void) handleSuspendOrder:(id) sender {
    // Cancel the order and completely Logoff
    //Enning Tang release order lock 3/26/2013
    /*if (![[orderCart getOrder]isNewOrder])
    {
        [facade releaseTransactionLock:[orderCart getOrder].orderId.stringValue];
    }*/
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL) tenderPaymentFromCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    NSLog(@"tenderPaymentFromCardData called");
    BOOL isPaymentTendered = NO;
    //financialCard card;
	
    //[linea msProcessFinancialCard:<#(NSString *)#> track2:<#(NSString *)#>]
    //[linea msProcessFinancialCard:<#(NSString *)#> track2:<#(NSString *)#>]
    //NSDictionary *cardInfo = [linea msProcessFinancialCard:track1 track2:track2];
    NSDictionary *cardInfo=[linea msProcessFinancialCard:track1 track2:track2];
	if(cardInfo)
	{
        /*
		self.lastCardName=[cardInfo valueForKey:@"cardholderName"];
		self.lastCardNumber=[cardInfo valueForKey:@"accountNumber"];
		self.lastExpDate=[NSString stringWithFormat:@"%@/%@\n",[cardInfo valueForKey:@"expirationMonth"],[cardInfo valueForKey:@"expirationYear"]];
		
		
		if(self.lastCardName)
			[status appendFormat:@"Name: %@\n",self.lastCardName];
		if(self.lastCardNumber)
			[status appendFormat:@"Number: %@\n",self.lastCardNumber];
		if(self.lastExpDate)
			[status appendFormat:@"Expiration: %@\n",self.lastExpDate];
		[status appendString:@"\n"];
         */
        NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2
                                                                                                      raiseOnExactness:NO raiseOnOverflow:NO
                                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
		self.payment = [[[CreditCardPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
        [payment setNameOnCard:[cardInfo valueForKey:@"cardholderName"]];
        [payment setCardNumber:[cardInfo valueForKey:@"accountNumber"]];
        [payment setPaymentAmount:[[self paymentAmount] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]];
        [payment setExpireDateMonthYear:[NSString stringWithFormat:@"%d",[[cardInfo valueForKey:@"expirationMonth"] intValue]]
                                   year:[NSString stringWithFormat:@"%d",[[cardInfo valueForKey:@"expirationYear"] intValue]]];
        
        //Enning Tang test for invalid card
        NSLog(@"Card holder name: %@", [cardInfo valueForKey:@"cardholderName"]);
        NSLog(@"accoundNumber: %@", [cardInfo valueForKey:@"accountNumber"]);
        NSLog(@"expirationMonth: %@", [cardInfo valueForKey:@"expirationMonth"]);
        NSLog(@"expirationYear: %@", [cardInfo valueForKey:@"expirationYear"]);
        //==================================
        
        //Enning Tang uncomment to submit payment
        BOOL isSuccess = [facade tenderPaymentWithCC:payment];
        NSLog(@"Payment OrderID: %@", [[payment orderId]stringValue]);
        
        //Enning Tang Added isSuccess to check if the card has been approved 3/13/2013
        if (isSuccess)
        {
            isPaymentTendered = YES;
        }
        else
        {
            [self showPaymentRetryAlert:payment];
        }
        
        /*
        if ([[payment errorList] count] == 0) {
            isPaymentTendered = YES;
        } else {
            [self showPaymentRetryAlert:payment];
        }*/
	}
    else
    {
        //Enning Tang pop up a message box for invalid card
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Credit Card is unacceptable."] withTitle:@"iPOS"];
        //========================================================
        NSLog(@"Credit Card is unacceptable.");
    }
    
    /*
    if([linea msProcessFinancialCard:&card track1:track1 track2:track2]) {
        NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                      raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                      raiseOnUnderflow:NO raiseOnDivideByZero:NO];
		self.payment = [[[CreditCardPayment alloc] initWithOrder:[orderCart getOrder]] autorelease];
        [payment setNameOnCard:[[card.cardholderName copy] autorelease]];
        [payment setCardNumber:[[card.accountNumber copy] autorelease]];
        [payment setPaymentAmount:[[self paymentAmount] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]];
        [payment setExpireDateMonthYear:[NSString stringWithFormat:@"%d",card.expirationMonth]
                                     year:[NSString stringWithFormat:@"%d",card.expirationYear]];
        
        [facade tenderPaymentWithCC:payment];
        
        if ([[payment errorList] count] == 0) {
            isPaymentTendered = YES;
        } else {
            [self showPaymentRetryAlert:payment];
        }
    }*/
    
    return isPaymentTendered;
}

- (void) showPaymentRetryAlert:(Payment *) aCCPayment {
    
    NSLog(@"showPaymentRetryAlert called");
    
    copyOriginalOrder = [[Order alloc]init];
    copyOriginalOrder = originalOrder;
    
    //Enning Tang Check Order isNew 3/14/2013
    /*
    Order *previousOrder = [orderCart previousOrder];
    Order *currentOrder = [orderCart getOrder];
    NSLog(@"Previous OrderID: %@", previousOrder.orderId);
    NSLog(@"Current OrderID: %@", currentOrder.orderId);
    NSLog(@"previous Order isNew: %i", previousOrder.isNewOrder);
    NSLog(@"Current Order isNew: %i", currentOrder.isNewOrder);
    NSLog(@"Previous OrderItemStatus: ");*/
    /*for (OrderItem *previousOrderItem in [originalOrder getOrderItems]) {
        NSLog(@"Previous Order OpenItemStatus: %@", previousOrderItem.statusId.stringValue);
        NSLog(@"Previous Line isModified? %i", previousOrderItem.isModified);
        NSLog(@"Previous Line isClosed? %i", previousOrderItem.isClosed);
    }*/
    //NSLog(@"Current OrderItemStatus: ");
    
    /*
    newClosedLines = [[NSMutableArray alloc]init];
    for (OrderItem *CurrentOrderItem in [[orderCart getOrder] getOrderItems]) {
        for (OrderItem *previousOrderItem in [originalOrder getOrderItems]) {
            if (CurrentOrderItem.lineNumber == previousOrderItem.lineNumber)
            {
                if (previousOrderItem.isClosed == false && CurrentOrderItem.isClosed == true)
                {
                    NSLog(@"New closed line detected. %@", CurrentOrderItem.lineNumber);
                    [newClosedLines addObject:CurrentOrderItem.lineNumber];
                }
            }
        }
    }*/
    
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
    
    /*
    NSLog(@"cancelTenderAndLogout called");
    bool isNewOrder = false;
    if (![orderCart previousOrder].orderId.intValue)
    {
        isNewOrder = true;
        NSLog(@"set isNewOrder");
    }
        
    //Enning Tang if new order, should return sold items and cancel order
    NSLog(@"previous OrderID: ---%i---", [orderCart previousOrder].orderId.intValue);
    //NSLog(@"Previous isNewOrder? %i", [orderCart previousOrder].isNewOrder);
    //NSLog(@"currentOrder isNewOrder? %i", [orderCart getOrder].isNewOrder);
    
    bool *shouldClose = false;
    
    if (isNewOrder) //if new order has closed lines, return them all.
    {
        Order *currentOrder = [orderCart getOrder];
        for (OrderItem *CurrentOrderItem in [[[[orderCart getOrder] getOrderItems]copy]autorelease]) {
            //Return Closed Lines
            if (CurrentOrderItem.statusId == [NSNumber numberWithInt: LINE_ORDERSTATUS_CLOSED])
            {
                NSLog(@"Closed line detected.");
                double storeIDdouble = [currentOrder.store.storeId doubleValue] + 10;
                NSNumber *MCUNumber = [NSNumber numberWithDouble:storeIDdouble];
                NSString *MCU = [NSString stringWithFormat:@"%@",MCUNumber];
                NSLog(@"Current Order Store ID: %@", MCU);
                CurrentOrderItem.mcu = MCU;
                CurrentOrderItem.nxtr = @"560";
                
                ProductItem *returnProductItem = [[ProductItem alloc] init];
                
                returnProductItem = CurrentOrderItem.item;
                
                NSLog(@"CurrentOrderItem.quantityPrimary: %@", CurrentOrderItem.quantityPrimary);
                
                NSDecimalNumber *returnQuantity = [CurrentOrderItem.quantityPrimary decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1.000"]];
                
                OrderItem *returnOrderItem =  [[OrderItem alloc] initWithReturnItem:returnProductItem AndQuantity:returnQuantity SellingPricePrimary:CurrentOrderItem.sellingPricePrimary SellingPriceSecondary:CurrentOrderItem.sellingPriceSecondary];

                NSString *returnString = @"RETURNED: ";
                NSString *originalString = CurrentOrderItem.item.description;
                returnOrderItem.item.description = [NSString stringWithFormat:@"%@%@", returnString, originalString];
                
                NSLog(@"SellingPricePrimary: %@", CurrentOrderItem.sellingPricePrimary.stringValue);
                NSLog(@"SellingPricePrimary Return: %@", returnOrderItem.sellingPricePrimary.stringValue);
                
                //Enning Tang set same price 3/26/2012
                //returnOrderItem.item.retailPricePrimary = CurrentOrderItem.sellingPricePrimary;
                //returnOrderItem.item.retailPriceSecondary = CurrentOrderItem.sellingPriceSecondary;
                //returnOrderItem.sellingPricePrimary = CurrentOrderItem.sellingPricePrimary;
                //returnOrderItem.sellingPriceSecondary = CurrentOrderItem.sellingPriceSecondary;
                
                NSLog(@"AFTER SellingPricePrimary: %@", CurrentOrderItem.sellingPricePrimary.stringValue);
                NSLog(@"AFTER SellingPricePrimary Return: %@", returnOrderItem.sellingPricePrimary.stringValue);
                
                [returnOrderItem setStatusToReturn];
                
                NSLog(@"returnQuantity: %@", returnQuantity.stringValue);
                
                [orderCart addReturnItem:returnProductItem withQuantity:returnQuantity SellingPricePrimary:CurrentOrderItem.sellingPricePrimary SellingPriceSecondary:CurrentOrderItem.sellingPriceSecondary]; //add return line to order 3/22/2013
                //[[orderCart getOrder] setAsClosed]; //should close order if all line returned/closed/cancelled
                //[currentOrder addOrderItemToOrder:returnOrderItem];//Add Return Lines
                
                //TEST
                for (OrderItem *testOrderItem in [[orderCart getOrder]getOrderItems])
                {
                    NSLog(@"testOrderItem.quantityPrimary: %@", testOrderItem.quantityPrimary);
                    NSLog(@"testOrderItem.sellingPrimary: %@", testOrderItem.sellingPricePrimary);
                }
                //====
                
                shouldClose = true;
            }
            
            if (CurrentOrderItem.statusId == [NSNumber numberWithInt: LINE_ORDERSTATUS_OPEN])
            {
                NSLog(@"Cancel open line.");
                double storeIDdouble = [currentOrder.store.storeId doubleValue] + 10;
                NSNumber *MCUNumber = [NSNumber numberWithDouble:storeIDdouble];
                NSString *MCU = [NSString stringWithFormat:@"%@",MCUNumber];
                NSLog(@"Current Order Store ID: %@", MCU);
                CurrentOrderItem.mcu = MCU;
                [orderCart removeItem:CurrentOrderItem];
            }
        }
        
        //[facade saveOrder:currentOrder];
        [orderCart saveOrder];
        if (shouldClose)
        {
            [facade closeOrderByOrderId:[orderCart getOrder].orderId.stringValue];//if all lines are closed/returned, close order.
        }
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"No new payment received for order %@. Items have been Cancelled/Returned, Order has been closed.", currentOrder.orderId] withTitle:@"iPOS"];
    }else
    {
        NSLog(@"Existing Order");
        Order *currentOrder = [orderCart getOrder];
        
        for (OrderItem *CurrentOrderItem in [[[[orderCart getOrder] getOrderItems]copy]autorelease]) {
            for (NSNumber *getLineNumber in newClosedLines) {
                if ([CurrentOrderItem.lineNumber isEqualToNumber:getLineNumber])
                {
                    NSLog(@"New closed line detected. %@", CurrentOrderItem.lineNumber);
                    double storeIDdouble = [currentOrder.store.storeId doubleValue] + 10;
                    NSNumber *MCUNumber = [NSNumber numberWithDouble:storeIDdouble];
                    NSString *MCU = [NSString stringWithFormat:@"%@",MCUNumber];
                    NSLog(@"Current Order Store ID: %@", MCU);
                    CurrentOrderItem.mcu = MCU;
                    CurrentOrderItem.nxtr = @"560";
                    
                    ProductItem *returnProductItem = [[ProductItem alloc] init];
                    
                    returnProductItem = CurrentOrderItem.item;
                    
                    NSDecimalNumber *returnQuantity = [CurrentOrderItem.quantityPrimary decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1.000"]];
                    
                    OrderItem *returnOrderItem =  [[OrderItem alloc] initWithReturnItem:returnProductItem AndQuantity:returnQuantity SellingPricePrimary:CurrentOrderItem.sellingPricePrimary SellingPriceSecondary:CurrentOrderItem.sellingPriceSecondary];
                    
                    NSString *returnString = @"RETURNED: ";
                    NSString *originalString = CurrentOrderItem.item.description;
                    returnOrderItem.item.description = [NSString stringWithFormat:@"%@%@", returnString, originalString];
                    NSNumber *maxLineNum = [[NSNumber alloc]initWithInt:[[orderCart getOrder]getOrderItems].count];
                    NSNumber *one = [[NSNumber alloc]initWithInt:1];
                    NSNumber *newLineNumber = [NSNumber numberWithFloat:[maxLineNum floatValue] + [one floatValue]];
                    returnOrderItem.lineNumber = newLineNumber;
                    returnOrderItem.isNew = true;
                    
                    NSLog(@"SellingPricePrimary: %@", CurrentOrderItem.sellingPricePrimary.stringValue);
                    NSLog(@"SellingPricePrimary Return: %@", returnOrderItem.sellingPricePrimary.stringValue);
                    
                    //Enning Tang set same price 3/26/2012
                    returnOrderItem.sellingPricePrimary = CurrentOrderItem.sellingPricePrimary;
                    returnOrderItem.sellingPriceSecondary = CurrentOrderItem.sellingPriceSecondary;
                    
                    [returnOrderItem setStatusToReturn];
                    
                    [orderCart addReturnItem:returnProductItem withQuantity:returnQuantity SellingPricePrimary:CurrentOrderItem.sellingPricePrimary SellingPriceSecondary:CurrentOrderItem.sellingPriceSecondary];
                    NSLog(@"End addItem");
                } //end if
            } //end for
        } //end for

        [orderCart saveOrder];
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"No new payment received for order %@. New closed line has been returned.", currentOrder.orderId] withTitle:@"iPOS"];
    }//end else

    [self.navigationController popToRootViewControllerAnimated:YES];
     */
    
    //Enning Tang 3/28/2013
    Order *order = [orderCart getOrder];
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *setBalanceDue = [[order calcBalanceDue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    NSDecimalNumber *setTotalBalanceDue = [[[order calcOrderSubTotal] decimalNumberByAdding:[order calcOrderTax]] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    OtherPaymentViewController *otherPayment = [[OtherPaymentViewController alloc]initWithBalanceDue:setBalanceDue totalBalanceDue:setTotalBalanceDue];
    [otherPayment.navigationController setNavigationBarHidden:YES animated:YES];
	[self.navigationController pushViewController:otherPayment animated:YES];
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

-(void)handleCashDrawer:(id)sender {
    
    Order *order = [orderCart getOrder];
    
    if ([order purchaseOrderInfoRequiredForCash] && (order.purchaseOrderId == nil || [order.purchaseOrderId isEmpty])) {
        [AlertUtils showModalAlertMessage:@"PO required before accepting this payment, please enter one." withTitle:@"iPOS"];
    } else {
    UIAlertView *cashPaymentWarning = [[UIAlertView alloc] init];
    cashPaymentWarning.title = @"iPOS";
    cashPaymentWarning.message = [NSString stringWithFormat:@"iPOS will create the order and continue to the order payment screen, you may not go return to the previous screen or turn off your device, Continue?"];
    cashPaymentWarning.delegate = self;
    [cashPaymentWarning addButtonWithTitle:@"Cancel"];
    [cashPaymentWarning addButtonWithTitle:@"Continue"];
    [cashPaymentWarning show];
    [cashPaymentWarning release];
    }
}

@end
