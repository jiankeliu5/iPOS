//
//  SearchItemView.h
//  iPOS
//
//  Created by Steven McCoole on 4/2/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "ExtUITextField.h"

@class SearchItemView;

@protocol SearchItemViewDelegate

- (void) searchItem:(SearchItemView *)aSearchItemView withSku:(NSString *)aSku;
- (void) cancelSearchItem:(SearchItemView *)aSearchItemView;					 

@end


@interface SearchItemView : UIView <UITextFieldDelegate>
{
	NSObject <SearchItemViewDelegate>* delegate;
	
	GradientView *roundedView;
	UILabel *lookupSkuLabel;
	ExtUITextField *lookupSkuField;
	
	id currentFirstResponder;
	BOOL keyboardCancelled;
}

@property (nonatomic, assign) NSObject<SearchItemViewDelegate>* delegate;
@property (nonatomic, retain) id currentFirstResponder;
@property					  BOOL keyboardCancelled;

@end
