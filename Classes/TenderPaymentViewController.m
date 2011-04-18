//
//  TenderPaymentViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TenderPaymentViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "GradientView.h"
#import "SSLineView.h"

#import "NSString+StringFormatters.h"


#define TOOLBAR_HEIGHT 44.0f
#define SEPARATOR_HEIGHT 5.0f;

#define LABEL_STARTY 30.0f
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

@interface TenderPaymentViewController()

- (UIView *) buildTenderTotalView;
- (UIView *) buildSeparatorView;

- (void) handleCreditCardPayment:(id)sender;
- (void) handleSuspendOrder: (id) sender;

- (void) updateViewLayout;
@end

@implementation TenderPaymentViewController

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
    
    [self.view addSubview:[self buildTenderTotalView]];
    [self.view addSubview:[self buildSeparatorView]];
       
    // Add Balance Due
    CGFloat balanceDueY = rectForView.size.height - [self navBarHeight] - LABEL_SPACING - LABEL_HEIGHT;
    UILabel *balanceDueTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_BALDUE_STARTX, balanceDueY, LABEL_BALDUE_WIDTH, LABEL_HEIGHT)];
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
    UIBarButtonItem *creditCardButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CreditCard.png"] 
                                                                    style:UIBarButtonItemStylePlain 
                                                                   target:self 
                                                                   action:@selector(handleCreditCardPayment:)] autorelease];
    NSArray *paymentToolbarItems = [[[NSArray alloc] initWithObjects:tbFlex, creditCardButton, nil] autorelease];
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
	
}

- (void) viewWillAppear:(BOOL)animated {
    [self updateViewLayout];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
#pragma mark Private Interface
- (UIView *) buildTenderTotalView {
    CGRect rect = [self rectForNavAndStatus];
    UIColor *bgColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    rect.size.height = rect.size.height - (3 * TOOLBAR_HEIGHT);
    GradientView *tenderTotalView = [[[GradientView alloc] initWithFrame:rect] autorelease];
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
    
    GradientView *separatorView = [[[GradientView alloc] initWithFrame:rect] autorelease];
	separatorView.backgroundColor = bgColor;
    
    [separatorView setStart:[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] andEndColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    return separatorView;
}

- (void) updateViewLayout {
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
        balanceDueLabel.text = [NSString formatDecimalNumberAsMoney:[order calcBalanceDue]];
    } else {
        retailTotalLabel.text = @"0.00";
        discountTotalLabel.text =  @"(0.00)";
        subTotalLabel.text = @"0.00";
        taxTotalLabel.text = @"0.00";
        balanceDueLabel.text = @"0.00";
    }
}

- (void) handleCreditCardPayment:(id)sender {
    
}

- (void) handleSuspendOrder:(id) sender {
    // Cancel the order and completely Logoff
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
