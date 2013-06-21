//
//  ShipToViewController.m
//  iPOS
//
//  Created by Enning Tang on 10/30/12.
//
//

#import "ShipToViewController.h"
#import "ProductItem.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"
#import "iPOSFacade.h"
#import "ProductItem.h"

@interface ShipToViewController ()

@end

@implementation ShipToViewController

@synthesize stores;

@synthesize ShipToStoreID;

@synthesize currentStoreID;

@synthesize editItem;

- (id)initWithOrderItem:(OrderItem *)editOrderItem
{
    // Custom initialization
    orderCart = [OrderCart sharedInstance];
    NSLog(@"EditOrderItem: %@", editOrderItem.item.itemId);
    self.editItem = editOrderItem;
    [self setTitle:@"Shipping Options"];
    StorePicker = [[UIPickerView alloc] init];
    //StorePicker.frame = CGRectMake(CGRectZero.size.width - BUTTON_SIZE - BUTTON_SPACING/2 + 100,
    //                                 (CGRectZero.size.height - BUTTON_SIZE/2),
    //                               BUTTON_SIZE + 150, BUTTON_SIZE + 100);

    CGRect frame = self.view.frame;
    StorePicker.frame = CGRectMake(frame.origin.x/2, 0.f + 60.f, 0.f, 0.f - 50.f);
    //CGRect pickerFrame = StorePicker.frame;
    //pickerFrame.size.width = 10;
    //pickerFrame.size.height = 20;
    StorePicker.transform = CGAffineTransformMakeScale(0.8, 0.8);
    facade = [iPOSFacade sharedInstance];
    self.stores = [facade storelookup];
    //NSLog(@"Done");
    self.currentStoreID = [facade storelookupbysalesperson:facade.sessionInfo.loginUserName];
    //[StorePicker selectedRowInComponent:10];
    //NSLog(@"Get ------ %@",);

    
    StorePicker.delegate = self;
    StorePicker.showsSelectionIndicator = YES;
    
    //Set default value
    NSInteger temp = [self.currentStoreID integerValue];
    int getstoreidint = temp;
    int rows = getstoreidint/100 - 2;
    [StorePicker selectRow:rows inComponent:0 animated:YES];
    self.ShipToStoreID = [NSString stringWithFormat:@"%d", temp];
    [self.view addSubview:StorePicker];
    
    CGRect viewBounds = self.view.bounds;
    CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
    
    shipTo = [[UILabel alloc] initWithFrame:CGRectZero];
	shipTo.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	shipTo.textColor = [UIColor blackColor];
    shipTo.backgroundColor = [UIColor grayColor];
	shipTo.text = @"-- SHIP TO --";
	shipTo.textAlignment = NSTextAlignmentCenter;
    
    shipTo.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
    shipTo.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing - 30.f);
    
	[self.view addSubview:shipTo];
	[shipTo release];
    
    shipItem = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [shipItem setupAsBlueButton];
    shipItem.titleLabel.textAlignment = NSTextAlignmentCenter;
    shipItem.titleLabel.font = [UIFont systemFontOfSize:15];
    [shipItem setTitle:@"Ship this ITEM to this location" forState:UIControlStateNormal];
    
    shipItem.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 120.f, 60.0f);
    shipItem.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing + 200.f);
    [shipItem addTarget:self action:@selector(handleShipItemButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shipItem];
    [shipItem release];
    
    shipOrder = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [shipOrder setupAsGreenButton];
    shipOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *shipOrderStr = [NSString stringWithFormat:@"%@\n%@", @"Ship this ENTIRE ORDER", @"to this location"];
    shipOrder.titleLabel.font = [UIFont systemFontOfSize:15];
    [shipOrder setTitle:shipOrderStr forState:UIControlStateNormal];
    shipOrder.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth + 120.f, 60.0f);
    shipOrder.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing + 290.f);
    [shipOrder addTarget:self action:@selector(handleShipOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shipOrder];
    [shipOrder release];
    
    
    return self;
}

- (void)loadView {
    UIView *bgView = [[UIView alloc] initWithFrame:[self rectForNav]];
	bgView.backgroundColor = [UIColor grayColor];
	[self setView:bgView];
	[bgView release];
}

//Enning Tang Add PickerView Functionalities
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    NSArray *getstoreid = [[self.stores objectAtIndex:row] componentsSeparatedByString:@","];
    self.ShipToStoreID = getstoreid[0];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //NSUInteger numRows = sizeof(stores);
    
    return [self.stores count];
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
    return [self.stores objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

//=================================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//Enning Tang add handleShipItemButton
- (void) handleShipItemButton:(id)sender {
    NSLog(@"ShipItemButton Called");
    facade = [iPOSFacade sharedInstance];
    NSString *changedStore;
    Customer *cust = [orderCart getCustomerForOrder];
    
    for (OrderItem *item in [[orderCart getOrder] getOrderItems]) {
        NSLog(@"Order Item: %@", item.item.sku);
        NSLog(@"item quantity: %@", item.quantityPrimary);
        if ([item.item.sku isEqualToString:editItem.item.sku])
        {
            NSInteger row = [StorePicker selectedRowInComponent:0];
            NSArray *split = [[self.stores objectAtIndex:row] componentsSeparatedByString:@","];
            item.item.ShipToStoreID = split[0];
            changedStore = split[0];
            if (cust != nil) {
                if (cust.taxExempt == TRUE)
                {
                    NSLog(@"Set tax rate to zero, customer is tax exempt");
                    item.item.taxRate = [NSDecimalNumber zero];
                }
                else
                {
                    NSLog(@"Customer is not tax exempt, set tax");
                    item.item.taxRate = (NSDecimalNumber *)[facade taxratelookupbystoreid:split[0]];
                }
            }
            else
                item.item.taxRate = (NSDecimalNumber *)[facade taxratelookupbystoreid:split[0]];
        }
        //[self.navigationController popToRootViewControllerAnimated:YES];
        
        /*
         itemToAdd = [[iPOSFacade sharedInstance] lookupProductItem:@"615610"];
         NSDecimalNumber *qty = [NSDecimalNumber decimalNumberWithString:@"99.0"];
         NSInteger temp = [self.currentStoreID integerValue];
         int getstoreidint = temp;
         int rows = getstoreidint/100 - 2;
         [StorePicker selectRow:rows inComponent:0 animated:YES];
         self.ShipToStoreID = [NSString stringWithFormat:@"%d", temp];
         [orderCart addItem:itemToAdd withQuantity:qty];
         */
    }
    NSLog(@"changed");
    UIAlertView *confirm = [[UIAlertView alloc] init];
    confirm.title = @"Message";
    confirm.message = [NSString stringWithFormat:@"ShipToStore has been changed to %@ for this ITEM.", changedStore];
    [confirm addButtonWithTitle:@"OK"];
    [confirm show];
    [confirm release];
    //[[self parentViewController] dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
}

//Enning Tang add handleShipOrderButton
- (void) handleShipOrderButton:(id)sender {
    NSLog(@"ShipOrderButton Called");
    facade = [iPOSFacade sharedInstance];
    NSString *changedStore;
    Customer *cust = [orderCart getCustomerForOrder];
    
    for (OrderItem *item in [[orderCart getOrder] getOrderItems]) {
        NSLog(@"Order Item: %@", item.item.sku);
        NSLog(@"item quantity: %@", item.quantityPrimary);
        NSInteger row = [StorePicker selectedRowInComponent:0];
        NSArray *split = [[self.stores objectAtIndex:row] componentsSeparatedByString:@","];
        item.item.ShipToStoreID = split[0];
        changedStore = split[0];
        if (cust != nil) {
            if (cust.taxExempt == TRUE)
            {
                NSLog(@"Set tax rate to zero, customer is tax exempt");
                item.item.taxRate = [NSDecimalNumber zero];
            }
            else
            {
                NSLog(@"Customer is not tax exempt, set tax");
                item.item.taxRate = (NSDecimalNumber *)[facade taxratelookupbystoreid:split[0]];
            }
        }
        else
            item.item.taxRate = (NSDecimalNumber *)[facade taxratelookupbystoreid:split[0]];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        
        /*
         itemToAdd = [[iPOSFacade sharedInstance] lookupProductItem:@"615610"];
         NSDecimalNumber *qty = [NSDecimalNumber decimalNumberWithString:@"99.0"];
         NSInteger temp = [self.currentStoreID integerValue];
         int getstoreidint = temp;
         int rows = getstoreidint/100 - 2;
         [StorePicker selectRow:rows inComponent:0 animated:YES];
         self.ShipToStoreID = [NSString stringWithFormat:@"%d", temp];
         [orderCart addItem:itemToAdd withQuantity:qty];
         */
    }
    NSLog(@"changed");
    UIAlertView *confirm = [[UIAlertView alloc] init];
    confirm.title = @"Message";
    confirm.message = [NSString stringWithFormat:@"ShipToStore has been changed to %@ for this ENTIRE ORDER.", changedStore];
    [confirm addButtonWithTitle:@"OK"];
    [confirm show];
    [confirm release];
    //[[self parentViewController] dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
