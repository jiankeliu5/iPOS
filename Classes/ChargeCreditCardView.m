//
//  ChargeCreditCardAmountView.m
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ChargeCreditCardView.h"
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

@interface ChargeCreditCardView()
- (void) layoutBalanceDueLabels: (UIView *) parentView;
- (void) layoutChargeAmountView: (UIView *) parentView;
- (void) layoutSwipeMsgView: (UIView *) parentView;
- (void) handleCancelButton:(id) sender;

@end


@implementation ChargeCreditCardView

@synthesize balanceDue, totalBalance, viewDelegate;
@synthesize refundInfo;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        balanceDue = @"$0.00";
        totalBalance = @"0.00";
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame andRefundInfo:(Refund *) refund {
    self = [self initWithFrame:frame];
    
    if (self) {
        refundInfo = refund;
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

- (void) switchCardSwipeToReady {
    // Only valid for card charges.  There is no data entry for refunds.
    if (refundInfo == nil) {
        amountToChargeLabel.text = [NSString formatDecimalNumberAsMoney:[NSDecimalNumber decimalNumberWithString:chargeAmountTextField.text]];
        
        balanceDueTitle.hidden = YES;
        balanceDueLabel.hidden = YES;
        ccChargeAmountView.hidden = YES;
        ccSwipeMsgView.hidden = NO;
        
        NSLog(@"Amount to charge: %@", amountToChargeLabel.text);
    }
    
    NSString *chargeAmt = @"0.00";
    chargeAmt = chargeAmountTextField.text;
    [viewDelegate readyForCardSwipe:[NSDecimalNumber decimalNumberWithString:chargeAmt] fromView:self];
    
    if (viewDelegate) {
        
        NSString *chargeAmt = @"0.00";
        
        if (chargeAmountTextField) {
            chargeAmt =  chargeAmountTextField.text;
        }
        
        [viewDelegate readyForCardSwipe:[NSDecimalNumber decimalNumberWithString:chargeAmt] fromView:self];
        
    }
    
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
    
    // Add balance due labels and charge amount if this is not for a refund
    if ( refundInfo == nil) {
        [self layoutBalanceDueLabels:mainRoundedView];
        [self layoutChargeAmountView:mainRoundedView];
        // Add totalBalance
        totalBalanceDueTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + 30.0f, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
        totalBalanceDueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP + 30.0f, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
        
        totalBalanceDueTitle.textAlignment = NSTextAlignmentLeft;
        totalBalanceDueTitle.text = @"Sale Total";
        totalBalanceDueTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        totalBalanceDueLabel.textAlignment = NSTextAlignmentRight;
        totalBalanceDueLabel.textColor = [UIColor blueColor];
        totalBalanceDueLabel.text = [NSString stringWithFormat:@"%@", self.totalBalance];
        totalBalanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        [mainRoundedView addSubview:totalBalanceDueTitle];
        [mainRoundedView addSubview:totalBalanceDueLabel];
    }
    // Add subviews
    [self layoutSwipeMsgView:mainRoundedView];
       
    // Add a cancel button
    if (!cancelButton) {
        cancelButton = [[[MOGlassButton alloc] 
                         initWithFrame:CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), 
                                                        mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)] 
                        autorelease];
        [cancelButton setupAsSmallRedButton];
        [mainRoundedView addSubview:cancelButton];
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(handleCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    cancelButton.frame = CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f), 
                                    mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
	
    // Setup keyboard support or ready for swipe
    if (refundInfo == nil) {
        if (viewDelegate) {
            [viewDelegate setupKeyboardSupport:self];
        }
    } else {
        [self switchCardSwipeToReady];
    }
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
        balanceDueLabel.text = self.balanceDue;
        balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];    
        
        [parentView addSubview:balanceDueTitle];
        [parentView addSubview:balanceDueLabel];
    }
    
    balanceDueTitle.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    balanceDueLabel.frame = CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
}

- (void) layoutChargeAmountView: (UIView *) parentView {
    if (!ccChargeAmountView) {
        ccChargeAmountView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, MARGIN_TOP+MARGIN_BOTTOM+LABEL_HEIGHT + 10.0f, OVERLAY_VIEW_WIDTH, CHARGE_AMOUNT_VIEW_HEIGHT)] autorelease];
    
        // Add the strip message
        UIView *stripView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0 + 10.f, OVERLAY_VIEW_WIDTH, STRIP_HEIGHT)] autorelease];
        stripView.backgroundColor = STRIP_COLOR;
        [stripView.layer setBorderWidth:1.0f];
        [stripView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        UILabel *enterAmountText = [[[UILabel alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, OVERLAY_VIEW_WIDTH, LABEL_SMALL_FONT_SIZE)] autorelease];
        UILabel *creditCardText = [[[UILabel alloc] 
                                    initWithFrame:CGRectMake(0, STRIP_HEIGHT - LABEL_LARGE_FONT_SIZE - MARGIN_BOTTOM, OVERLAY_VIEW_WIDTH, LABEL_LARGE_FONT_SIZE)]
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
        creditCardText.text = @"CREDIT CARD";
        
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
        
        [enterChargeAmountView addSubview:dollarSignLabel];
        [enterChargeAmountView addSubview:chargeAmountTextField];
        [ccChargeAmountView addSubview:enterChargeAmountView];
        
        [parentView addSubview:ccChargeAmountView];
    }
}

- (void) layoutSwipeMsgView: (UIView *) parentView {
    if (!ccSwipeMsgView) {
        ccSwipeMsgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, MARGIN_TOP+MARGIN_BOTTOM+LABEL_HEIGHT, OVERLAY_VIEW_WIDTH, SWIPE_MSG_VIEW_HEIGHT)] autorelease];
        ccSwipeMsgView.hidden = YES;
        
        UILabel *swipeText1 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 5*MARGIN_TOP, OVERLAY_VIEW_WIDTH, LABEL_LARGE_FONT_SIZE)] autorelease];
        UILabel *swipeText2 = [[[UILabel alloc] 
                                    initWithFrame:CGRectMake(0, 6*MARGIN_TOP + LABEL_LARGE_FONT_SIZE, OVERLAY_VIEW_WIDTH, LABEL_LARGE_FONT_SIZE)]
                                   autorelease];
        amountToChargeLabel = [[[UILabel alloc] 
                                initWithFrame:CGRectMake(0, 7*MARGIN_TOP + 2*LABEL_LARGE_FONT_SIZE, OVERLAY_VIEW_WIDTH, LABEL_LARGE_FONT_SIZE)]
                                autorelease];
                                   
        swipeText1.backgroundColor = [UIColor clearColor];
        swipeText1.textColor = [UIColor blackColor];
        swipeText1.textAlignment = NSTextAlignmentCenter;
        swipeText1.font = [UIFont boldSystemFontOfSize:LABEL_LARGE_FONT_SIZE];
        swipeText1.text = @"SWIPE CREDIT CARD";
        swipeText2.backgroundColor = [UIColor clearColor];
        swipeText2.textColor = [UIColor blackColor];
        swipeText2.textAlignment = NSTextAlignmentCenter;
        swipeText2.font = [UIFont boldSystemFontOfSize:LABEL_LARGE_FONT_SIZE];
        swipeText2.text = @"TO CHARGE AMOUNT";
        amountToChargeLabel.backgroundColor = [UIColor clearColor];
        amountToChargeLabel.textColor = [UIColor blueColor];
        amountToChargeLabel.textAlignment = NSTextAlignmentCenter;
        amountToChargeLabel.font = [UIFont boldSystemFontOfSize:LABEL_LARGE_FONT_SIZE];
        amountToChargeLabel.text = @"$0.00";
        
        [ccSwipeMsgView addSubview:swipeText1];
        [ccSwipeMsgView addSubview:swipeText2];
        [ccSwipeMsgView addSubview:amountToChargeLabel];
        
        
        [parentView addSubview:ccSwipeMsgView];
    }
}

- (void) handleCancelButton: (id) sender {
    if (self.viewDelegate) {
        [self.viewDelegate cancelCardSwipe:self];
    }
}


@end
