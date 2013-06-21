//
//  SSSearchItemView.h
//  iPOS
//
//  Created by Enning Tang on 8/8/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "ExtUITextField.h"

@class SSSearchItemView;

@protocol SSSearchItemViewDelegate

- (void) searchItem:(SSSearchItemView *)aSearchItemView withSku:(NSString *)aSku;
- (void) searchItem:(SSSearchItemView *)aSearchItemView withName:(NSString *)aName;
- (void) cancelSearchItem:(SSSearchItemView *)aSearchItemView;					 

@end


@interface SSSearchItemView : UIView <UITextFieldDelegate>
{
	NSObject <SSSearchItemViewDelegate>* delegate;
	
	GradientView *roundedView;
	UILabel *lookupSkuLabel;
	ExtUITextField *lookupNameField;
    ExtUITextField *lookupSkuField;
	
	id currentFirstResponder;
	BOOL keyboardCancelled;
}

@property (nonatomic, assign) NSObject<SSSearchItemViewDelegate>* delegate;
@property (nonatomic, retain) id currentFirstResponder;
@property					  BOOL keyboardCancelled;

@end
