//
//  AmountPaymentView.m
//  iPOS
//
//  Created by Enning Tang on 3/28/13.
//
//

#import "AmountPaymentView.h"
#import "NSString+StringFormatters.h"
#import "UIView+ViewLayout.h"
#import "AlertUtils.h"

#import "UIViewController+ViewControllerLayout.h"
#import "UIScreen+Helpers.h"



#define OVERLAY_VIEW_X 20.0f
#define OVERLAY_VIEW_Y 10.0f
#define OVERLAY_VIEW_WIDTH 280.0f
#define OVERLAY_VIEW_HEIGHT 260.0f

#define LABEL_SMALL_FONT_SIZE 12.0f
#define LABEL_FONT_SIZE 16.0f
#define LABEL_LARGE_FONT_SIZE 20.0f
#define LABEL_HEIGHT 18.0f
#define LABEL_WIDTH 120.0f

#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 100.0f

// Margins
#define MARGIN_TOP 10.0f
#define MARGIN_LEFT 20.0f
#define MARGIN_RIGHT 20.0f
#define MARGIN_BOTTOM 10.0f

#define STRIP_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define STRIP_HEIGHT 60.0f
#define AMOUNT_LABEL_WIDTH 20.0f
#define AMOUNT_LABEL_HEIGHT 40.0f
#define AMOUNT_TEXT_FIELD_HEIGHT 40.0f
#define AMOUNT_TEXT_FIELD_WIDTH 180.0f
#define CHARGE_AMOUNT_VIEW_HEIGHT 142.0f
#define ENTER_CHARGE_AMT_WIDTH 240.0f
#define ENTER_CHARGE_AMT_HEIGHT 60.0f

#define SWIPE_MSG_VIEW_HEIGHT 142.0f

#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f

@interface AmountPaymentView()
- (void) handleConfirmButton:(id) sender;

@end

@implementation AmountPaymentView

@synthesize balanceDue, totalBalance, viewDelegate, paymentType;

@synthesize keyboardCancelled;

@synthesize currentFirstResponder;

@synthesize originalCenter;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id) initWithBalanceDue:(CGRect)frame balanceDue:(NSDecimalNumber *) setBalanceDue totalBalance:(NSDecimalNumber *) setTotalBalance{
    
    self = [super initWithFrame:frame];
    if (self) {
        balanceDue = setBalanceDue;
        totalBalance = setTotalBalance;
    }
    
    return self;
}

- (void)dealloc {
    [balanceDue release];
    [totalBalance release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors & Methods
- (ExtUITextField *) getChargeAmountTextField {
    return chargeAmountTextField;
}


#pragma mark -
- (void) layoutSubviews {
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    CGFloat width = self.bounds.size.width;
    
    // Add the rounded view
    CGRect roundedViewRect = CGRectMake((width-OVERLAY_VIEW_WIDTH)/2, OVERLAY_VIEW_Y, OVERLAY_VIEW_WIDTH, OVERLAY_VIEW_HEIGHT);
    if (!mainRoundedView) {
        mainRoundedView = [[UIView alloc] initWithFrame:roundedViewRect];
        [self addSubview:mainRoundedView];
        [mainRoundedView release];
    } else {
        mainRoundedView.frame = roundedViewRect;
    }
    
    [mainRoundedView applyRoundedStyle:[UIColor blackColor] withShadow:YES];
	[mainRoundedView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                                                    endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    
    // Add balance due 
    balanceDueTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    balanceDueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    
    balanceDueTitle.textAlignment = NSTextAlignmentLeft;
    balanceDueTitle.text = @"Balance Due";
    balanceDueTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    
    balanceDueLabel.textAlignment = NSTextAlignmentRight;
    balanceDueLabel.textColor = [UIColor blueColor];
    balanceDueLabel.text = [NSString stringWithFormat:@"$%@", self.balanceDue.stringValue];
    balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    
    [mainRoundedView addSubview:balanceDueTitle];
    [mainRoundedView addSubview:balanceDueLabel];
    
    balanceDueTitle.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    balanceDueLabel.frame = CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    
    // Add totalBalance
    totalBalanceDueTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + 30.0f, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    totalBalanceDueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP + 30.0f, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    
    totalBalanceDueTitle.textAlignment = NSTextAlignmentLeft;
    totalBalanceDueTitle.text = @"Sale Total";
    totalBalanceDueTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    
    totalBalanceDueLabel.textAlignment = NSTextAlignmentRight;
    totalBalanceDueLabel.textColor = [UIColor blueColor];
    totalBalanceDueLabel.text = [NSString stringWithFormat:@"$%@", self.totalBalance.stringValue];
    totalBalanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    
    [mainRoundedView addSubview:totalBalanceDueTitle];
    [mainRoundedView addSubview:totalBalanceDueLabel];
    
    balanceDueTitle.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    balanceDueLabel.frame = CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    
    // Add Amount to be charged view
    UILabel *enterAmountText = [[[UILabel alloc] initWithFrame:CGRectMake(0, MARGIN_TOP + 70.0f, OVERLAY_VIEW_WIDTH, LABEL_SMALL_FONT_SIZE)] autorelease];
    UILabel *creditCardText = [[[UILabel alloc]
                                initWithFrame:CGRectMake(0, STRIP_HEIGHT - LABEL_LARGE_FONT_SIZE - MARGIN_BOTTOM + 70.0f, OVERLAY_VIEW_WIDTH, LABEL_LARGE_FONT_SIZE)]
                               autorelease];
    
    enterAmountText.backgroundColor = [UIColor clearColor];
    enterAmountText.textColor = [UIColor blackColor];
    enterAmountText.textAlignment = NSTextAlignmentCenter;
    enterAmountText.font = [UIFont systemFontOfSize:LABEL_SMALL_FONT_SIZE];
    enterAmountText.text = @"ENTER AMOUNT TO BE CHARGED VIA";
    creditCardText.backgroundColor = [UIColor clearColor];
    creditCardText.textColor = [UIColor blackColor];
    creditCardText.textAlignment = NSTextAlignmentCenter;
    creditCardText.font = [UIFont boldSystemFontOfSize:LABEL_LARGE_FONT_SIZE];
    creditCardText.text = paymentType;
    
    [mainRoundedView addSubview:enterAmountText];
    [mainRoundedView addSubview:creditCardText];
    
    //=====================================
    
    // Add text field
    UIView *enterChargeAmountView = [[[UIView alloc]
                                      initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP+STRIP_HEIGHT + 60.0f, ENTER_CHARGE_AMT_WIDTH, ENTER_CHARGE_AMT_HEIGHT)]
                                     autorelease];
    
    [enterChargeAmountView applyRoundedStyle:[UIColor blackColor] withShadow:NO];
    [enterChargeAmountView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:96.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1.0]
                                                          endColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    
    UILabel *dollarSignLabel = [[[UILabel alloc]
                                 initWithFrame:CGRectMake(floorf(MARGIN_LEFT/2), MARGIN_TOP, AMOUNT_LABEL_WIDTH, AMOUNT_LABEL_HEIGHT)]
                                autorelease];
    
    dollarSignLabel.backgroundColor = [UIColor clearColor];
    dollarSignLabel.textColor = [UIColor whiteColor];
    dollarSignLabel.textAlignment = NSTextAlignmentCenter;
    dollarSignLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    dollarSignLabel.text = @"$";
    
    chargeAmountTextField = [[[ExtUITextField alloc]
                              initWithFrame:CGRectMake(floorf(MARGIN_LEFT/2)+AMOUNT_LABEL_WIDTH, MARGIN_TOP, AMOUNT_TEXT_FIELD_WIDTH, AMOUNT_TEXT_FIELD_HEIGHT)]
                             autorelease];
    chargeAmountTextField.textColor = [UIColor blackColor];
    chargeAmountTextField.borderStyle = UITextBorderStyleRoundedRect;
    chargeAmountTextField.textAlignment = NSTextAlignmentLeft;
    chargeAmountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    chargeAmountTextField.clearsOnBeginEditing = YES;
    //chargeAmountTextField.tagName = @"ChargeAmount";
    chargeAmountTextField.tagName = @"credit";
    [chargeAmountTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    chargeAmountTextField.returnKeyType = UIReturnKeyDone;
    chargeAmountTextField.delegate = self;
    [self addDoneAndCancelToolbarForTextField:chargeAmountTextField];
    
    [enterChargeAmountView addSubview:dollarSignLabel];
    [enterChargeAmountView addSubview:chargeAmountTextField];
    [mainRoundedView addSubview:enterChargeAmountView];
    
    //=====================================
    
    // Add a confirm button
    confirmButton = [[[MOGlassButton alloc]
                      initWithFrame:CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f),
                                               mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)]
                     autorelease];
    [confirmButton setupAsSmallRedButton];
    [mainRoundedView addSubview:confirmButton];
    confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(handleConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f - 70.0f),
                                     mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    //Add cancel button
    cancellButton = [[[MOGlassButton alloc]
                      initWithFrame:CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f),
                                               mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)]
                     autorelease];
    [cancellButton setupAsGrayButton];
    [mainRoundedView addSubview:cancellButton];
    cancellButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancellButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancellButton addTarget:self action:@selector(handleCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    cancellButton.frame = CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f + 70.0f),
                                     mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
	
}

#pragma mark -
#pragma mark Private Interface
- (void) layoutBalanceDueLabels: (UIView *) parentView {
    if (!balanceDueTitle) {
        balanceDueTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
        balanceDueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
        
        balanceDueTitle.textAlignment = NSTextAlignmentLeft;
        balanceDueTitle.text = @"Balance Due";
        balanceDueTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        balanceDueLabel.textAlignment = NSTextAlignmentRight;
        balanceDueLabel.textColor = [UIColor blueColor];
        balanceDueLabel.text = self.balanceDue.stringValue;
        balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        [parentView addSubview:balanceDueTitle];
        [parentView addSubview:balanceDueLabel];
    }
    
    balanceDueTitle.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    balanceDueLabel.frame = CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
}

- (void) handleConfirmButton: (id) sender {
    facade = [iPOSFacade sharedInstance];
    orderCart = [OrderCart sharedInstance];
    Order *order = [orderCart getOrder];
    NSDecimalNumber *change = [[NSDecimalNumber alloc] autorelease];
    change = 0;
    
    if (self.viewDelegate) {
        NSLog(@"Confirm Button called");
        NSLog(@"Payment Type: %@", paymentType);
    }
    
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *amount = [[NSDecimalNumber decimalNumberWithString:chargeAmountTextField.text] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    
    NSDecimalNumber *OwingString = [order calcBalanceOwing];
    //NSDecimalNumber *PaidString = [order calcBalancePaid];
    
    NSDecimalNumber *Owing = [[NSDecimalNumber decimalNumberWithString:OwingString.stringValue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    //NSDecimalNumber *Paid = [[NSDecimalNumber decimalNumberWithString:PaidString.stringValue] decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    
    NSLog(@"Total balance: %@", totalBalance.stringValue);
    NSLog(@"balanceDue: %@", balanceDue.stringValue);
    NSLog(@"Paid: %@", [NSString formatDecimalNumberAsMoney:[order calcBalancePaid]]);
    NSLog(@"Owing: %@", Owing.stringValue);
    
    
    if ([amount compare:balanceDue] == NSOrderedAscending) {
        [AlertUtils showModalAlertMessage:@"Cannot charge less than the balance due." withTitle:@"iPOS"];
        return;
    } else if ([amount compare:totalBalance] == NSOrderedDescending) {
        if ([paymentType isEqualToString:@"Cash"])
        {
            change = [amount decimalNumberBySubtracting:totalBalance];
            amount = totalBalance;
        }else
        {
            [AlertUtils showModalAlertMessage:@"Cannot charge more than the order total balance." withTitle:@"iPOS"];
            return;
        }
    }else if ([amount compare:Owing] == NSOrderedDescending && ![paymentType isEqualToString:@"Cash"]) {
        [AlertUtils showModalAlertMessage:@"Cannot charge more than owing." withTitle:@"iPOS"];
        return;
    }
    
    //======
    
    NSString *paymentTypeID = @"1";
    if ([paymentType isEqualToString:@"Cash"])
    {
        paymentTypeID = @"1";
    }else if ([paymentType isEqualToString:@"Check"])
    {
        paymentTypeID = @"2";
    }else if ([paymentType isEqualToString:@"VISA"])
    {
        paymentTypeID = @"3";
    }else if ([paymentType isEqualToString:@"MC"])
    {
        paymentTypeID = @"4";
    }else if ([paymentType isEqualToString:@"DISC"])
    {
        paymentTypeID = @"5";
    }else if ([paymentType isEqualToString:@"AMEX"])
    {
        paymentTypeID = @"6";
    }else if ([paymentType isEqualToString:@"Same Day Credit"])
    {
        paymentTypeID = @"8";
    }else if ([paymentType isEqualToString:@"Gift Card"])
    {
        paymentTypeID = @"12";
    }else if ([paymentType isEqualToString:@"Google"])
    {
        paymentTypeID = @"13";
    }else if ([paymentType isEqualToString:@"TS Home Design Card"])
    {
        paymentTypeID = @"14";
    }else if ([paymentType isEqualToString:@"PayPal"])
    {
        paymentTypeID = @"16";
    }
    
    //Enter Payment
    NSLog(@"orderid: %@", order.orderId.stringValue);
    NSLog(@"storeid: %@", order.store.storeId.stringValue);
    NSLog(@"customerid %@", order.customer.customerId.stringValue);
    NSLog(@"salespersonid %@", order.salesPersonEmployeeId.stringValue);
    NSLog(@"amoutpay %@", amount.stringValue);
    
    BOOL success = [facade insertOtherPayment:order amountPayment:amount paymentType:paymentTypeID];
    NSLog(@"insertOtherPayment success: %i", success);
    if (success)
    {
        if (change > 0)
        {
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Change: $%@. Payment saved for order %@.", change.stringValue, order.orderId] withTitle:@"iPOS"];
        }
        else{
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Payment saved for order %@. Please ask customer to pay at cash drawer.", order.orderId] withTitle:@"iPOS"];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else
    {
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Payment fails for order %@. Please Try again.", order.orderId] withTitle:@"iPOS"];
        return;
    }
}

- (void) handleCancelButton: (id) sender{
    [self.viewDelegate cancelSearchItem:self];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.originalCenter = self.viewForBaselineLayout.center;
    self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 40.0f);
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.currentFirstResponder = textField;
	/*if ([loginTableView indexPathsForVisibleRows].count) {
		[self setTopRowBeforeKeyboardShown:(NSIndexPath *) [[loginTableView indexPathsForVisibleRows] objectAtIndex:0]];
	} else {
        [self setTopRowBeforeKeyboardShown:[NSIndexPath indexPathForRow:0 inSection:0]];
		[textField resignFirstResponder];
	}*/
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
	self.currentFirstResponder = nil;
    
    self.keyboardCancelled = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

// These come from a StackOverflow answered question http://stackoverflow.com/questions/594181/uitableview-and-keyboard-scrolling-problem/672003#672003
// and are from the InAppSettingsKit open source project.

- (void) addDoneAndCancelToolbarForTextField:(UITextField *)textField {
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAndDismissKeyboard:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, cancelButton, nil] autorelease];
    
    [keyboardToolbar setItems:items];
	[textField setInputAccessoryView:keyboardToolbar];
}

- (void) dismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// The toolbar done button calls this.  Allows the delegate to be called.
		self.keyboardCancelled = NO;
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void) cancelAndDismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
		[self.currentFirstResponder resignFirstResponder];
	}
}

@end
