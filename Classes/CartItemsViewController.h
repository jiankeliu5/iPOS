//
//  CartItemsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"
#import "iPOSFacade.h"
#import "AddItemView.h"

@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate> {
	iPOSFacade *facade;
    
    Linea *linea;
}

@end
