//
//  PriceAdjustViewController.m
//  iPOS
//
//  Created by Steven McCoole on 4/14/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PriceAdjustViewController.h"
#import "UIView+ViewLayout.h"

#import "NSString+StringFormatters.h"
#import "UIScreen+Helpers.h"

#import "AlertUtils.h"
#import "ManagerInfo.h"

#define ROUND_VIEW_X 20.0f
#define ROUND_VIEW_Y 7.0f
#define ROUND_VIEW_WIDTH 280.0f
#define ROUND_VIEW_HEIGHT 270.0f
#define LABEL_HEIGHT 30.0f
#define LABEL_WIDTH 120.0f
#define TEXT_FIELD_HEIGHT 30.0f
#define TEXT_FIELD_WIDTH 120.0f
#define SPACING_HEIGHT 10.0f
#define SPACING_WIDTH 10.0f
#define LINE_HEIGHT 2.0f
#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 80.0f

@interface PriceAdjustViewController()
- (void) layoutView: (UIInterfaceOrientation) interfaceOrientation;
- (void) updateViewLayout;
- (void) submitPriceAdjustment:(id)sender;
@end

@implementation PriceAdjustViewController

@synthesize orderItem;

#pragma mark Constructors
- (id) init {
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	[[self navigationItem] setTitle:@"Adjust Price"];
	[self setTitle:@"Adjust Price"];
	
	orderCart = [OrderCart sharedInstance];
	facade = [iPOSFacade sharedInstance];
	
	discountFormatter = [[NSNumberFormatter alloc] init];
	[discountFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[discountFormatter setMaximumFractionDigits:2];
	[discountFormatter setGeneratesDecimalNumbers:YES];
	
	return self;
}

- (id) initWithOrderItem:(OrderItem *)adjustOrderItem {
	self = [self init];
	if (self == nil) {
		return nil;
	}
	
	[self setOrderItem:adjustOrderItem];
	
	return self;
}

- (void) dealloc {
	[discountFormatter release];
	discountFormatter = nil;
	[super dealloc];
}

- (void)loadView {
	UIView *bgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	bgView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	[self setView:bgView];
	
	roundView = [[[UIView alloc] initWithFrame:CGRectMake(ROUND_VIEW_X, ROUND_VIEW_Y, ROUND_VIEW_WIDTH, ROUND_VIEW_HEIGHT)] autorelease];
	[roundView applyDefaultRoundedStyle];
	[roundView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] 
											  endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
	[self.view addSubview:roundView];
	
	retailTotalLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	retailTotalLabel.backgroundColor = [UIColor clearColor];
	retailTotalLabel.textColor = [UIColor blackColor];
	retailTotalLabel.text = @"Retail Total";
	retailTotalLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:retailTotalLabel];
	
	retailTotalValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	retailTotalValueLabel.backgroundColor = [UIColor clearColor];
	retailTotalValueLabel.textColor = [UIColor blackColor];
	retailTotalValueLabel.text = @"$0.00";
	retailTotalValueLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:retailTotalValueLabel];
	
	sellingTotalLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	sellingTotalLabel.backgroundColor = [UIColor clearColor];
	sellingTotalLabel.textColor = [UIColor blackColor];
	sellingTotalLabel.text = @"Total";
	sellingTotalLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:sellingTotalLabel];
	
	sellingTotalValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	sellingTotalValueLabel.backgroundColor = [UIColor clearColor];
	sellingTotalValueLabel.textColor = [UIColor blackColor];
	sellingTotalValueLabel.text = @"$0.00";
	sellingTotalValueLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:sellingTotalValueLabel];
	
	discountLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	discountLabel.backgroundColor = [UIColor clearColor];
	discountLabel.textColor = [UIColor blackColor];
	discountLabel.text = @"Discount";
	discountLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:discountLabel];
	
	discountField = [[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease];
	discountField.textColor = [UIColor blackColor];
	discountField.borderStyle = UITextBorderStyleLine;
	discountField.textAlignment = UITextAlignmentLeft;
    discountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	discountField.clearsOnBeginEditing = YES;
	discountField.tagName = @"DiscountAmount";
	discountField.returnKeyType = UIReturnKeyDone;
	discountField.keyboardType = UIKeyboardTypeDecimalPad;
	[self addDoneAndCancelToolbarForTextField:discountField];
	[roundView addSubview:discountField];
	
	lineView = [[[SSLineView alloc] initWithFrame:CGRectZero] autorelease];
	[roundView addSubview:lineView];
	
	mgrIdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	mgrIdLabel.backgroundColor = [UIColor clearColor];
	mgrIdLabel.textColor = [UIColor blackColor];
	mgrIdLabel.text = @"Manager Id";
	mgrIdLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:mgrIdLabel];
	
	mgrIdField = [[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease];
	mgrIdField.textColor = [UIColor blackColor];
	mgrIdField.borderStyle = UITextBorderStyleLine;
	mgrIdField.textAlignment = UITextAlignmentLeft;
    mgrIdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	mgrIdField.clearsOnBeginEditing = YES;
	mgrIdField.tagName = @"ManagerId";
	mgrIdField.returnKeyType = UIReturnKeyDone;
	mgrIdField.keyboardType = UIKeyboardTypeNumberPad;
	[self addDoneAndCancelToolbarForTextField:mgrIdField];
	[roundView addSubview:mgrIdField];
	
	mgrPasswordLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	mgrPasswordLabel.backgroundColor = [UIColor clearColor];
	mgrPasswordLabel.textColor = [UIColor blackColor];
	mgrPasswordLabel.text = @"Password";
	mgrPasswordLabel.textAlignment = UITextAlignmentLeft;
	[roundView addSubview:mgrPasswordLabel];
	
	mgrPasswordField = [[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease];
	mgrPasswordField.textColor = [UIColor blackColor];
	mgrPasswordField.borderStyle = UITextBorderStyleLine;
	mgrPasswordField.textAlignment = UITextAlignmentLeft;
    mgrPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	mgrPasswordField.clearsOnBeginEditing = YES;
	mgrPasswordField.tagName = @"ManagerPassword";
	mgrPasswordField.returnKeyType = UIReturnKeyDone;
	mgrPasswordField.keyboardType = UIKeyboardTypeNumberPad;
	mgrPasswordField.secureTextEntry = YES;
	[self addDoneAndCancelToolbarForTextField:mgrPasswordField];
	[roundView addSubview:mgrPasswordField];
	
	submitButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[submitButton setupAsSmallBlackButton];
	[submitButton setTitle:@"Submit" forState:UIControlStateNormal];
	[submitButton addTarget:self action:@selector(submitPriceAdjustment:) forControlEvents:UIControlEventTouchUpInside];
	[roundView addSubview:submitButton];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	discountField.delegate = self;
	mgrIdField.delegate = self;
	mgrPasswordField.delegate = self;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self updateViewLayout];
    
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
	
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    
    roundView.frame = CGRectMake((viewBounds.size.width - ROUND_VIEW_WIDTH)/2, 
                                 (viewBounds.size.height - ROUND_VIEW_HEIGHT)/2, 
                                 ROUND_VIEW_WIDTH, ROUND_VIEW_HEIGHT);
	[roundView applyDefaultRoundedStyle];
	[roundView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] 
											  endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark ExtUIViewController delegates

- (void) extTextFieldFinishedEditing:(ExtUITextField *) textField {
	// We could submit the price adjustment from here since we will be
	// called if the keyboard toolbar done button is pressed but that
	// might be confusing to the user?

	//[self submitPriceAdjustment:nil];
	
}

#pragma mark UIButton targets
- (void) submitPriceAdjustment:(id)sender {
	NSDecimalNumber *discount;
	ManagerInfo *mgr = nil;
	
	[self resignFirstResponderIfPossible];
	
	if ([discountField.text length] == 0) {
		[AlertUtils showModalAlertMessage:@"Please enter discount amount." withTitle:@"iPOS"];
		return;
	} else {
		discount = (NSDecimalNumber *)[discountFormatter numberFromString:discountField.text];
		if (discount == nil) {
			[AlertUtils showModalAlertMessage:@"Incorrect format entered for discount." withTitle:@"iPOS"];
			return;
		}
		if ([mgrIdField.text length] > 0) {
			if ([mgrPasswordField.text length] == 0) {
				[AlertUtils showModalAlertMessage:@"Password must be entered with Id." withTitle:@"iPOS"];
				return;
			} else {
				mgr = [[ManagerInfo alloc] init];
				mgr.managerUserName = [NSString stringWithString:mgrIdField.text];
				mgr.managerPassword = [NSString stringWithString:mgrPasswordField.text];
			}
		}
	}

	if ([facade adjustSellingPriceFor:self.orderItem withDiscountAmount:discount managerApproval:mgr] == NO) {
		[AlertUtils showModalAlertMessage:@"Discount adjustment was rejected.  Please enter a different value or manager credentials." withTitle:@"iPOS"];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
	[mgr release];
	mgr = nil;
}

- (void) updateViewLayout {
	
	CGRect rect = CGRectMake(SPACING_WIDTH, SPACING_HEIGHT, LABEL_WIDTH, LABEL_HEIGHT);
	retailTotalLabel.frame = rect;
	retailTotalValueLabel.frame = CGRectOffset(rect, LABEL_WIDTH + SPACING_WIDTH, 0.0f);
	
	sellingTotalLabel.frame = CGRectOffset(rect, 0.0f, LABEL_HEIGHT + SPACING_HEIGHT);
	sellingTotalValueLabel.frame = CGRectOffset(sellingTotalLabel.frame, LABEL_WIDTH + SPACING_WIDTH, 0.0f);
	
	discountLabel.frame = CGRectOffset(sellingTotalLabel.frame, 0.0f, LABEL_HEIGHT + SPACING_HEIGHT);
	discountField.frame = CGRectOffset(discountLabel.frame, LABEL_WIDTH + SPACING_WIDTH, 0.0f);
	
	rect = CGRectOffset(discountLabel.frame, 0.0f, LABEL_HEIGHT + (SPACING_HEIGHT - LINE_HEIGHT / 2.0f));
	rect.size.height = LINE_HEIGHT;
	rect.size.width = (LABEL_WIDTH * 2.0f) + SPACING_WIDTH;
	lineView.frame = rect;
	
	rect = CGRectOffset(lineView.frame, 0.0f, LINE_HEIGHT + (SPACING_WIDTH - (LINE_HEIGHT / 2.0f)));
	rect.size.width = LABEL_WIDTH;
	rect.size.height = LABEL_HEIGHT;
	mgrIdLabel.frame = rect;
	mgrIdField.frame = CGRectOffset(mgrIdLabel.frame, LABEL_WIDTH + SPACING_WIDTH, 0.0f);
	
	mgrPasswordLabel.frame = CGRectOffset(mgrIdLabel.frame, 0.0f, LABEL_HEIGHT + SPACING_HEIGHT);
	mgrPasswordField.frame = CGRectOffset(mgrPasswordLabel.frame, LABEL_WIDTH + SPACING_WIDTH, 0.0f);
	
	rect = mgrPasswordLabel.frame;
	submitButton.frame = CGRectMake(floorf((roundView.frame.size.width - BUTTON_WIDTH) / 2.0f), 
									rect.origin.y + LABEL_HEIGHT + (SPACING_WIDTH * 2.0f), 
									BUTTON_WIDTH, 
									BUTTON_HEIGHT);
	
	NSDecimalNumber *retailTotal = [self.orderItem calcLineRetailSubTotal];
	retailTotalValueLabel.text = [NSString formatDecimalNumberAsMoney:retailTotal];
	
	NSDecimalNumber *sellingTotal = [self.orderItem calcLineSubTotal];
	sellingTotalValueLabel.text = [NSString formatDecimalNumberAsMoney:sellingTotal];
	
}

@end
