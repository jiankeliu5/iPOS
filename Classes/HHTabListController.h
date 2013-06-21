//
//  HHTabListController.h
//  iPOS
//
//  Created by Enning Tang on 2/8/13.
//
//

#import <UIKit/UIKit.h>

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define HH_ARC_ENABLED 1
#endif

@protocol HHTabListControllerDelegate;


@interface HHTabListController : UIViewController

- (id)initWithViewControllers:(NSArray*)viewControllers;

@property (nonatomic, copy, readonly) NSArray *viewControllers;
@property (nonatomic, assign, getter = isTabListRevealed, readonly) BOOL tabListRevealed;

#if HH_ARC_ENABLED
@property (nonatomic, weak) id<HHTabListControllerDelegate> delegate;
#else
@property (nonatomic, assign) id<HHTabListControllerDelegate> delegate;
#endif


- (UIViewController *)selectedViewController;
- (void)setSelectedViewController:(UIViewController *)newSelectedViewController;
- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated;

- (void)setTabListRevealed:(BOOL)tabListRevealed animated:(BOOL)animated;

- (UIBarButtonItem*)revealTabListBarButtonItem;
- (IBAction)revealTabList:(id)sender;

@end


@protocol HHTabListControllerDelegate <NSObject>

- (BOOL)tabListController:(HHTabListController*)tabListController shouldSelectViewController:(UIViewController*)viewController;
- (BOOL)tabListController:(HHTabListController*)tabListController didSelectViewController:(UIViewController*)viewController;

@end


@interface UIViewController (HHTabListController)

- (HHTabListController*)tabListController;

@end
