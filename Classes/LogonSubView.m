//
//  LogonSubView.m
//  iPOS
//
//  Created by Enning Tang on 4/12/13.
//
//

#import "LogonSubView.h"
#import "AmountPaymentView.h"
#import "NSString+StringFormatters.h"
#import "UIView+ViewLayout.h"
#import "AlertUtils.h"

#import "UIViewController+ViewControllerLayout.h"
#import "UIScreen+Helpers.h"

@interface LogonSubView ()

@end

@implementation LogonSubView

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

- (void)viewDidLoad
{
    //[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) layoutSubviews {
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    //CGFloat width = self.bounds.size.width;
    
    // Add the rounded view
    //CGRect roundedViewRect = CGRectMake((width-OVERLAY_VIEW_WIDTH)/2, OVERLAY_VIEW_Y + 50.f, OVERLAY_VIEW_WIDTH, OVERLAY_VIEW_HEIGHT - 100.f);
    
    [mainRoundedView setFrame:CGRectMake(0.0f, 480.0f, 320.0f, 480.0f)];
    [UIView beginAnimations:@"animationTableView" context:nil];
    [UIView setAnimationDuration:1.0];
    //[mainRoundedView setFrame:roundedViewRect];
    [UIView commitAnimations];
    
    if (!mainRoundedView) {
        mainRoundedView = [[UIView alloc] init];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:mainRoundedView cache:YES];
        [self addSubview:mainRoundedView];
        [UIView commitAnimations];
        [mainRoundedView release];
    } else {
        //mainRoundedView.frame = roundedViewRect;
    }
    
    [mainRoundedView applyRoundedStyle:[UIColor blackColor] withShadow:YES];
	[mainRoundedView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                                                    endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    [mainRoundedView setBackgroundColor:[UIColor clearColor]];
	
}

@end
