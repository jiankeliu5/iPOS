//
//  SpecialItem.h
//  iPOS
//
//  Created by Enning Tang on 6/5/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "MOGlassButton.h"
#import "ExtUITextField.h"

#import "ItemDetailView.h"
#import "ItemListView.h"
#import "AvailabilityView.h"

#import "ProductItem.h"
#import "iPOSFacade.h"
#import "OrderCart.h"

@class SpecialItem;

@protocol SpecialItemDelegate

//- (void) setupKeyboardSupport:(id) chargeCCView;
- (void) addSpecialItem:(ProductItem *)Item orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;

@end

@interface SpecialItem : UIView <UITextFieldDelegate>{
	MOGlassButton *cancelItemButton;
    MOGlassButton *acceptItemButton;
    
    UIView *mainRoundedView;
    
    ExtUITextField *description;
    ExtUITextField *amount;
    ExtUITextField *managerId;
    ExtUITextField *managerPass;
    
    UILabel *descriptionLbl;
    UILabel *amountLbl;
    UILabel *managerIdPassLbl;
    UILabel *infoLbl;
    
    ProductItem *itemToAdd;
    
    id currentFirstResponder;
	BOOL keyboardCancelled;
    CGPoint originalCenter;
    
    NSObject <SpecialItemDelegate>* viewDelegate;
    OrderCart *orderCart;
    iPOSFacade *facade;
}

@property (nonatomic, retain) ProductItem *itemToAdd;
@property (nonatomic, retain) id currentFirstResponder;
@property (nonatomic, assign) BOOL keyboardCancelled;
@property (nonatomic, assign) NSObject<SpecialItemDelegate>* viewDelegate;
@property (nonatomic, assign) CGPoint originalCenter;

@end


