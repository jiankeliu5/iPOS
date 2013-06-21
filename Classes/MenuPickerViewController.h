//
//  MenuPickerViewController.h
//  iPOS
//
//  Created by Enning Tang on 5/1/13.
//
//

#import <UIKit/UIKit.h>

@protocol MenuPickerDelegate <NSObject>
@required
-(void)selectedColor:(UIColor *)newColor;
@end

@interface MenuPickerViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *colorNames;
@property (nonatomic, strong) id<MenuPickerDelegate> delegate;
@end
