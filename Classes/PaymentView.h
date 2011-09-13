//
//  PaymentView.h
//  iPOS
//
//  Created by Dan C on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ExtUITextField.h"


@protocol PaymentView

- (ExtUITextField *) getChargeAmountTextField;

@end
