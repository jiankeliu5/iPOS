//
//  CustomerViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPOSFacade.h"
#import "CustomerView.h"

@interface CustomerViewController : UIViewController {
	
	iPOSFacade *facade;
	CustomerView *custView;
	
}

@end
