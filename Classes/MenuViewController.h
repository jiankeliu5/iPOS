//
//  MenuViewController.h
//  iPOS
//
//  Created by Enning Tang on 5/1/13.
//
//

#import <UIKit/UIKit.h>

@class MenuViewController;
#import "MenuPickerViewController.h"

@interface RightViewController : UIViewController <UISplitViewControllerDelegate, MenuPickerDelegate>

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) MenuPickerViewController *colorPicker;
@property (nonatomic, strong) UIPopoverController *colorPickerPopover;

-(IBAction)chooseColorButtonTapped:(id)sender;
@end
