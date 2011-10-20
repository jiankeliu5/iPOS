//
//  AccountPaymentView.m
//  iPOS
//
//  Created by Dan C on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountPaymentView.h"
#import "NSString+StringFormatters.h"
#import "UIView+ViewLayout.h"

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

@interface AccountPaymentView()
- (void) layoutSubviews;
- (void) layoutBalanceDueLabels: (UIView *) parentView;
- (void) layoutCreditAvailableLabels: (UIView *) parentView;
- (void) layoutChargeAmountView: (UIView *) parentView;
- (void) handleCancelButton:(id) sender;

@end

@implementation AccountPaymentView

@synthesize viewDelegate, balanceDue, totalAccountBalance;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    orderCart = [OrderCart sharedInstance];
        
    }
    return self;
}

- (ExtUITextField *) getChargeAmountTextField {
    return chargeAmountTextField;
}

#pragma mark -
- (void) layoutSubviews {
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    
    // Add the rounded view
    UIView *mainRoundedView = [[[UIView alloc] initWithFrame:CGRectMake(OVERLAY_VIEW_X, OVERLAY_VIEW_Y, OVERLAY_VIEW_WIDTH, OVERLAY_VIEW_HEIGHT)] autorelease];
    
    [mainRoundedView applyRoundedStyle:[UIColor blackColor] withShadow:YES];
	[mainRoundedView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] 
                                                    endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    [self addSubview:mainRoundedView];
    
    // Add balance due labels
    [self layoutCreditAvailableLabels: mainRoundedView];
    [self layoutBalanceDueLabels: mainRoundedView];
    
    // Add subviews
    [self layoutChargeAmountView:mainRoundedView];
    
    // Add a cancel button
    cancelButton = [[[MOGlassButton alloc] 
                     initWithFrame:CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), 
                                              mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)] 
                    autorelease];
	[cancelButton setupAsSmallRedButton];
	cancelButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(handleCancelButton:) forControlEvents:UIControlEventTouchUpInside];

    [mainRoundedView addSubview:cancelButton];    
    
    // Setup keyboard support
    if (viewDelegate) {
        [viewDelegate setupKeyboardSupport:self];
    }
}

- (void) layoutCreditAvailableLabels: (UIView *) parentView {
    creditAvailableTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    creditAvailableLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    
    creditAvailableTitle.textAlignment = UITextAlignmentLeft;
    creditAvailableTitle.text = @"Credit Available";
    creditAvailableTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];    
    
    creditAvailableLabel.textAlignment = UITextAlignmentRight;
    creditAvailableLabel.textColor = [UIColor blueColor];
    creditAvailableLabel.text = self.totalAccountBalance;
    creditAvailableLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];   
    
    [parentView addSubview:creditAvailableTitle];
    [parentView addSubview:creditAvailableLabel];
}

- (void) layoutBalanceDueLabels: (UIView *) parentView {
    balanceDueTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + 20, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    balanceDueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP + 20, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    
    balanceDueTitle.textAlignment = UITextAlignmentLeft;
    balanceDueTitle.text = @"Balance Due";
    balanceDueTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];    
    
    balanceDueLabel.textAlignment = UITextAlignmentRight;
    balanceDueLabel.textColor = [UIColor blueColor];
    balanceDueLabel.text = self.balanceDue;
    balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];    

    [parentView addSubview:balanceDueTitle];
    [parentView addSubview:balanceDueLabel];
}


- (void) layoutChargeAmountView: (UIView *) parentView {
    ccChargeAmountView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, MARGIN_TOP+MARGIN_BOTTOM+LABEL_HEIGHT+LABEL_HEIGHT, OVERLAY_VIEW_WIDTH, CHARGE_AMOUNT_VIEW_HEIGHT)] autorelease];
    
    // Add the strip message
    UIView *stripView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0, OVERLAY_VIEW_WIDTH, STRIP_HEIGHT)] autorelease];
    stripView.backgroundColor = STRIP_COLOR;
	[stripView.layer setBorderWidth:1.0f];
	[stripView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    UILabel *enterAmountText = [[[UILabel alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, OVERLAY_VIEW_WIDTH, LABEL_SMALL_FONT_SIZE)] autorelease];
    UILabel *creditCardText = [[[UILabel alloc] 
                                initWithFrame:CGRectMake(0, STRIP_HEIGHT - LABEL_LARGE_FONT_SIZE - MARGIN_BOTTOM, OVERLAY_VIEW_WIDTH, LABEL_LARGE_FONT_SIZE)] 
                               autorelease];
    
    enterAmountText.backgroundColor = [UIColor clearColor];
    enterAmountText.textColor = [UIColor blackColor];
    enterAmountText.textAlignment = UITextAlignmentCenter;
    enterAmountText.font = [UIFont systemFontOfSize:LABEL_SMALL_FONT_SIZE];
    enterAmountText.text = @"ENTER AMOUNT TO BE CHARGED VIA";
    creditCardText.backgroundColor = [UIColor clearColor];
    creditCardText.textColor = [UIColor blackColor];
    creditCardText.textAlignment = UITextAlignmentCenter;
    creditCardText.font = [UIFont boldSystemFontOfSize:LABEL_LARGE_FONT_SIZE];
    creditCardText.text = @"ACCOUNT";
    
    [stripView addSubview:enterAmountText];
    [stripView addSubview:creditCardText];
    [ccChargeAmountView addSubview:stripView];
    
    // Add the text field
    UIView *enterChargeAmountView = [[[UIView alloc] 
                                      initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP+STRIP_HEIGHT, ENTER_CHARGE_AMT_WIDTH, ENTER_CHARGE_AMT_HEIGHT)]
                                     autorelease];
    
    [enterChargeAmountView applyRoundedStyle:[UIColor blackColor] withShadow:NO];
    [enterChargeAmountView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:96.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1.0] 
                                                          endColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    
    UILabel *dollarSignLabel = [[[UILabel alloc] 
                                 initWithFrame:CGRectMake(floorf(MARGIN_LEFT/2), MARGIN_TOP, AMOUNT_LABEL_WIDTH, AMOUNT_LABEL_HEIGHT)] 
                                autorelease];
    
    dollarSignLabel.backgroundColor = [UIColor clearColor];
    dollarSignLabel.textColor = [UIColor whiteColor];
    dollarSignLabel.textAlignment = UITextAlignmentCenter;
    dollarSignLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
    dollarSignLabel.text = @"$";
    
    chargeAmountTextField = [[[ExtUITextField alloc] 
                              initWithFrame:CGRectMake(floorf(MARGIN_LEFT/2)+AMOUNT_LABEL_WIDTH, MARGIN_TOP, AMOUNT_TEXT_FIELD_WIDTH, AMOUNT_TEXT_FIELD_HEIGHT)] 
                             autorelease];
    chargeAmountTextField.tagName =@"account";
	chargeAmountTextField.textColor = [UIColor blackColor];
	chargeAmountTextField.borderStyle = UITextBorderStyleRoundedRect;
	chargeAmountTextField.textAlignment = UITextAlignmentLeft;
    chargeAmountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	chargeAmountTextField.clearsOnBeginEditing = YES;
	//chargeAmountTextField.tagName = @"ChargeAmount";    
    
    [enterChargeAmountView addSubview:dollarSignLabel];
    [enterChargeAmountView addSubview:chargeAmountTextField];
    [ccChargeAmountView addSubview:enterChargeAmountView];
    
    [parentView addSubview:ccChargeAmountView];
}

- (void) handleCancelButton: (id) sender {
    if (self.viewDelegate) {
        [self.viewDelegate cancelAccountPayment:self];
    }
}


@end
