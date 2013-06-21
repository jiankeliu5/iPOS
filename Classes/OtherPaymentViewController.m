//
//  OtherPaymentViewController.m
//  iPOS
//
//  Created by Enning Tang on 3/28/13.
//
//

#import "OtherPaymentViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"
#import "iPOSFacade.h"
#import "AmountPaymentView.h"

@interface OtherPaymentViewController ()

@end

@implementation OtherPaymentViewController

@synthesize PaymentType;

@synthesize balanceDue;

@synthesize getPaymentType;

@synthesize totalBalanceDue;

- (id)initWithBalanceDue:(NSDecimalNumber *)getbalanceDue totalBalanceDue:(NSDecimalNumber *)getTotalBalanceDue
{
    // Custom initialization
    [self setTitle:@"Enter Payments"];
    PaymentTypePicker = [[UIPickerView alloc] init];
    
    CGRect frame = self.view.frame;
    PaymentTypePicker.frame = CGRectMake(frame.origin.x/2, 0.f + 60.f, 0.f, 0.f - 50.f);
    //CGRect pickerFrame = StorePicker.frame;
    //pickerFrame.size.width = 10;
    //pickerFrame.size.height = 20;
    PaymentTypePicker.transform = CGAffineTransformMakeScale(0.8, 0.8);
    facade = [iPOSFacade sharedInstance];
    
    [self.navigationItem setHidesBackButton:YES];
    
    NSString *Cash = @"Cash";
    NSString *Check = @"Check";
    NSString *VISA = @"VISA";
    NSString *MC = @"MC";
    NSString *DISC = @"DISC";
    NSString *AMEX = @"AMEX";
    NSString *SameDayCredit = @"Same Day Credit";
    NSString *GiftCard = @"Gift Card";
    NSString *Google = @"Google";
    NSString *TSHomeDesignCard = @"TS Home Design Card";
    NSString *PayPal = @"PayPal";
    
    self.getPaymentType = @"VISA"; //set default payment type
    self.PaymentType = [[NSArray alloc]initWithObjects:Cash, Check, VISA, MC, DISC, AMEX, SameDayCredit, GiftCard, Google, TSHomeDesignCard, PayPal, nil];
    
    PaymentTypePicker.delegate = self;
    PaymentTypePicker.showsSelectionIndicator = YES;
    [PaymentTypePicker selectRow:2 inComponent:0 animated:YES];
    
    self.balanceDue = getbalanceDue;
    self.totalBalanceDue = getTotalBalanceDue;
    
    [self.view addSubview:PaymentTypePicker];
    
    CGRect viewBounds = self.view.bounds;
    CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
    
    balanceDueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	balanceDueLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	balanceDueLabel.textColor = [UIColor blackColor];
    balanceDueLabel.backgroundColor = [UIColor grayColor];
	balanceDueLabel.text = [NSString stringWithFormat:@"--Select Payment Type--"];
	balanceDueLabel.textAlignment = NSTextAlignmentCenter;
    
    balanceDueLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
    balanceDueLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing - 30.f);
    
	[self.view addSubview:balanceDueLabel];
	[balanceDueLabel release];
    
    Okay = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [Okay setupAsGreenButton];
    Okay.titleLabel.textAlignment = NSTextAlignmentCenter;
    Okay.titleLabel.font = [UIFont systemFontOfSize:15];
    [Okay setTitle:@"Order Payment" forState:UIControlStateNormal];
    
    Okay.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 120.f, 60.0f);
    Okay.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing + 200.f);
    [Okay addTarget:self action:@selector(handleOKButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:Okay];
    [Okay release];
    
    return self;
}

//Enning Tang Add PickerView Functionalities
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    self.getPaymentType = [self.PaymentType objectAtIndex:row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //NSUInteger numRows = sizeof(stores);
    
    return [self.PaymentType count];
    //return 68;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //NSString *title;
    //title = [@"" stringByAppendingFormat:@"%d",row];
    
    
    //return title;
    return [self.PaymentType objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (void)loadView {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    UIView *bgView = [[UIView alloc] initWithFrame:[self rectForNav]];
	bgView.backgroundColor = [UIColor grayColor];
	[self setView:bgView];
	[bgView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Enning Tang add handleShipItemButton
- (void) handleOKButton:(id)sender {
    NSLog(@"OK Called");
    NSLog(@"payment type: %@", self.getPaymentType);
    
    CGRect overlayRect = self.view.bounds;
    amountPaymentView = [[AmountPaymentView alloc] initWithFrame:overlayRect];
    
    amountPaymentView.viewDelegate = self;
    amountPaymentView.balanceDue = balanceDue;
    amountPaymentView.totalBalance = totalBalanceDue;
    amountPaymentView.paymentType = getPaymentType;
    amountPaymentView.navigationController = self.navigationController;
    
    [self.view addSubview:amountPaymentView];
    
    [amountPaymentView release];
    
}

- (void) cancelSearchItem:(AmountPaymentView *)aSearchItemView {
	[aSearchItemView removeFromSuperview];
    
    amountPaymentView = nil;
}

@end
