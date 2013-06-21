//
//  HHTabListController.m
//  iPOS
//
//  Created by Enning Tang on 2/8/13.
//
//

#import "HHTabListController.h"

#import <QuartzCore/QuartzCore.h>

#import "HHTabListContainerView.h"
#import "HHTabListTabsView.h"
#import "HHTabListCell.h"

#import <objc/runtime.h>


#if HH_ARC_ENABLED
#define HH_RETAIN(xx)			(xx)
#define HH_RELEASE(xx)			xx = nil
#define HH_AUTORELEASE(xx)		(xx)
#define HH_CLEAN(xx)			xx = nil
#else
#define HH_RETAIN(xx)			[xx retain]
#define HH_RELEASE(xx)			[xx release], xx = nil
#define HH_AUTORELEASE(xx)		[xx autorelease]
#define HH_CLEAN(xx)			xx = nil
#endif


#define HH_TAB_LIST_ANIMATION_DURATION		0.4
#define HH_TAB_LIST_WIDTH					(320 - 80)
#define HH_TAB_LIST_TRIGGER_OFFSET			75

#define HH_STATUS_BAR_TINT_HACK_ENABLED		1

#if HH_STATUS_BAR_TINT_HACK_ENABLED
static NSString * const kBackgroundNavigationControllerKey = @"backgroundNavigationController";
#endif


@interface HHTabListView : UIView
@end


@interface HHTabListWorkaroundViewController : UIViewController
@end


@interface HHTabListController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
	struct {
		BOOL shouldSelectViewController:1;
		BOOL didSelectViewController:1;
	} _delegateFlags;
}

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, getter = isTabListRevealed, assign) BOOL tabListRevealed;
@property (nonatomic, assign) BOOL wasTabListRevealed;
@property (nonatomic, assign) CGFloat panOriginX;
@property (nonatomic, assign) BOOL animationInProgress;

#if HH_ARC_ENABLED
@property (nonatomic, strong) NSMutableSet *gestureRecognizers;
@property (nonatomic, strong) HHTabListTabsView *tabListTabsView;
@property (nonatomic, strong) UIViewController *lastSelectedViewController;
@property (nonatomic, strong) HHTabListContainerView *containerView;
#else
@property (nonatomic, retain) NSMutableSet *gestureRecognizers;
@property (nonatomic, retain) HHTabListTabsView *tabListTabsView;
@property (nonatomic, retain) UIViewController *lastSelectedViewController;
@property (nonatomic, retain) HHTabListContainerView *containerView;
#endif

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)setTabListRevealed:(BOOL)tabListRevealed animated:(BOOL)animated;

- (void)removeGestureRecognizers;

@end


static NSString * const kTitleKey = @"title";
static NSString * const kFrameKey = @"frame";

static UIInterfaceOrientation HHInterfaceOrientation(void);
static CGRect HHCGRectRotate(CGRect rect);
static CGRect HHScreenBounds(void);
static CGFloat HHStatusBarHeight(void);


@implementation HHTabListController

#pragma mark -
#pragma mark Initialization

#if HH_STATUS_BAR_TINT_HACK_ENABLED

static BOOL OSVersion6OrAbove = NO;

+ (void)initialize
{
    if (self == [HHTabListController class]) {
        if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 6)  {
            OSVersion6OrAbove = YES;
        }
    }
}

#endif

- (id)initWithViewControllers:(NSArray*)viewControllers
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
		_selectedIndex = NSNotFound;
		_tabListRevealed = NO;
		_wasTabListRevealed = !_tabListRevealed;
		_gestureRecognizers = [[NSMutableSet alloc] initWithCapacity:5];
        
		self.viewControllers = viewControllers;
        
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		    self.contentSizeForViewInPopover = CGSizeMake(320.0f, 1024.0f);
		}
		else {
			self.wantsFullScreenLayout = YES;
		}
        
		[self view]; // Force view to load
    }
    
	return self;
}

- (void)loadView
{
	CGRect frame = CGRectZero;
    
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		CGSize contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        
		frame = CGRectMake(0.0, 0.0, contentSizeForViewInPopover.width, contentSizeForViewInPopover.height);
	}
	else {
		CGRect applicationFrame = HHScreenBounds();
		CGFloat statusBarHeight = HHStatusBarHeight();
        
		applicationFrame.size.height -= statusBarHeight;
        
		if (self.wantsFullScreenLayout) {
			applicationFrame.origin.y += statusBarHeight;
		}
        
		frame = applicationFrame;
	}
    
    HHTabListView *layoutContainerView = [[HHTabListView alloc] initWithFrame:frame];
    
	layoutContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    layoutContainerView.autoresizesSubviews = YES;
    layoutContainerView.clipsToBounds = YES;
    
	layoutContainerView.backgroundColor = [UIColor underPageBackgroundColor];
    
	self.view = HH_AUTORELEASE(layoutContainerView);
    
	CGRect tableFrame = frame;
	HHTabListTabsView *tabListTabsView = [[HHTabListTabsView alloc] initWithFrame:tableFrame];
    
	tabListTabsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
	tabListTabsView.dataSource = self;
	tabListTabsView.delegate = self;
    
	self.tabListTabsView = HH_AUTORELEASE(tabListTabsView);
    
    [layoutContainerView addSubview:self.tabListTabsView];
    
	[self setTabListRevealed:self.tabListRevealed animated:NO];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidChangeStatusBarFrameNotification:)
												 name:UIApplicationDidChangeStatusBarFrameNotification
											   object:nil];
    
	[self.view addObserver:self forKeyPath:@"frame" options:0 context:( void *)kFrameKey];
}

- (void)viewDidLayoutSubviews
{
	UIView *view = self.view;
	HHTabListTabsView *tabListTabsView = self.tabListTabsView;
	CGRect bounds = [view bounds];
    
	if (self.wantsFullScreenLayout) {
		CGFloat statusBarHeight = HHStatusBarHeight();
        
		bounds.origin.y += statusBarHeight;
	}
    
	[tabListTabsView setFrame:bounds];
}


#pragma mark -
#pragma mark Finalization

- (void)dealloc
{
	for (UIViewController *viewController in _viewControllers) {
		[viewController removeObserver:self forKeyPath:@"title" context:( void*)kTitleKey];
	}
    
	if ([self isViewLoaded]) {
		[self.view removeObserver:self forKeyPath:@"frame" context:( void *)kFrameKey];
	}
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeGestureRecognizers];
    
	HH_CLEAN(_delegate);
    
	HH_RELEASE(_viewControllers);
	HH_RELEASE(_lastSelectedViewController);
	HH_RELEASE(_gestureRecognizers);
	HH_RELEASE(_tabListTabsView);
	HH_RELEASE(_containerView);
    
#if !HH_ARC_ENABLED
    [super dealloc];
#endif
}

#pragma mark -
#pragma mark Accessors

@synthesize viewControllers = _viewControllers;
@synthesize lastSelectedViewController = _lastSelectedViewController;
@synthesize containerView = _containerView;
@synthesize delegate = _delegate;
@synthesize selectedIndex = _selectedIndex;
@synthesize tabListRevealed = _tabListRevealed;
@synthesize wasTabListRevealed = _wasTabListRevealed;
@synthesize panOriginX = _panOriginX;
@synthesize animationInProgress = _animationInProgress;
@synthesize gestureRecognizers = _gestureRecognizers;
@synthesize tabListTabsView = _tabListTabsView;

- (void)setDelegate:(id<HHTabListControllerDelegate>)delegate
{
	_delegate = delegate;
    
	_delegateFlags.shouldSelectViewController = [delegate respondsToSelector:@selector(tabListController:shouldSelectViewController:)];
	_delegateFlags.didSelectViewController = [delegate respondsToSelector:@selector(tabListController:didSelectViewController:)];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    NSLog(@"setViewControllers");
	for (UIViewController *viewController in _viewControllers) {
		[viewController removeObserver:self forKeyPath:@"title" context:( void*)kTitleKey];
	}
    
	UIViewController *oldSelectedViewController = self.selectedViewController;
	NSArray *newViewControllers = [viewControllers copy];
	NSUInteger newIndex = [newViewControllers indexOfObject:oldSelectedViewController];
	NSUInteger newSelectedIndex = 0;
    
	if (newIndex != NSNotFound) {
		newSelectedIndex = newIndex;
	}
	else if (newIndex < [_viewControllers count]) {
		newSelectedIndex = newIndex;
	}
    
	[self willChangeValueForKey:@"viewControllers"];
    
	_viewControllers = newViewControllers;
    
	[self didChangeValueForKey:@"viewControllers"];
    
	for (UIViewController *viewController in _viewControllers) {
		[viewController addObserver:self forKeyPath:@"title" options:0 context:( void*)kTitleKey];
	}
    
	self.selectedIndex = newSelectedIndex;
    
	HHTabListTabsView *tabListTabsView = self.tabListTabsView;
    
	[tabListTabsView reloadData];
	[tabListTabsView selectRowAtIndexPath:[NSIndexPath indexPathForRow:newSelectedIndex inSection:0]
								 animated:NO
						   scrollPosition:UITableViewScrollPositionTop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == ( void*)kTitleKey) {
		HHTabListTabsView *tabListTabsView = self.tabListTabsView;
		NSUInteger selectedIndex = self.selectedIndex;
        
		[tabListTabsView reloadData];
		[tabListTabsView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
									 animated:NO
							   scrollPosition:UITableViewScrollPositionTop];
    } else if (context == ( void*)kFrameKey) {
		[self setTabListRevealed:self.tabListRevealed animated:NO];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -
#pragma mark API

- (UIViewController *)selectedViewController
{
	NSUInteger selectedIndex = self.selectedIndex;
    
	if (selectedIndex != NSNotFound) {
		return [self.viewControllers objectAtIndex:selectedIndex];
	}
    
	return nil;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
	[self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
	NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    
	if (index != NSNotFound) {
		[self setSelectedIndex:index animated:animated];
	}
}


#pragma mark -
#pragma mark Core

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
	self.selectedIndex = selectedIndex;
    
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		// Hack so as to respect the selected view controller's desired orientation
		if (! [[self selectedViewController] shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
			HHTabListWorkaroundViewController *workaroundViewController = [[HHTabListWorkaroundViewController alloc] init];
            
			[self presentModalViewController:workaroundViewController animated:NO];
			[self dismissModalViewControllerAnimated:NO];
            
			[UIViewController attemptRotationToDeviceOrientation];
            
			HH_RELEASE(workaroundViewController);
		}
	}
    
	[self setTabListRevealed:self.tabListRevealed animated:animated];
}

- (CGRect)topViewControllerFrame
{
	BOOL tabListRevealed = self.tabListRevealed;
	CGRect bounds = [self.view bounds];
	CGRect topViewControllerFrame = bounds;
    
	if (tabListRevealed) {
		topViewControllerFrame.origin.x += HH_TAB_LIST_WIDTH;
	}
    
	return topViewControllerFrame;
}

- (void)setTabListRevealed:(BOOL)tabListRevealed animated:(BOOL)animated
{
    NSLog(@"setTabListRevealed called");
	BOOL wasTabListRevealed = self.wasTabListRevealed;
    NSLog(@"1");
	self.tabListRevealed = tabListRevealed;
    NSLog(@"2");
	self.wasTabListRevealed = tabListRevealed;
    NSLog(@"3");
    
	UIView *view = self.view;
    NSLog(@"4");
	HHTabListTabsView *tabListTabsView = self.tabListTabsView;
    NSLog(@"5");
    
	if (tabListRevealed) {
        NSLog(@"6");
		[view insertSubview:tabListTabsView belowSubview:self.containerView];
        NSLog(@"7");
	}
    
	NSUInteger selectedIndex = self.selectedIndex;
    NSLog(@"Selected Index: %d", selectedIndex);
    NSLog(@"8");
    
	[tabListTabsView reloadData];
    NSLog(@"9");
	[tabListTabsView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
								 animated:animated
						   scrollPosition:UITableViewScrollPositionTop];
    NSLog(@"10");
    
	UIViewController *selectedViewController = [self selectedViewController];
    NSLog(@"11");
	UIViewController *lastSelectedViewController = [self lastSelectedViewController];
    NSLog(@"12");
	CGRect topViewControllerFrame = [self topViewControllerFrame];
    NSLog(@"13");
	BOOL didSelectViewController = _delegateFlags.didSelectViewController;
    NSLog(@"14");
    
	if (selectedViewController != lastSelectedViewController) {
        NSLog(@"15");
        
#if HH_STATUS_BAR_TINT_HACK_ENABLED
        // Ugly hack to keep the status bar tint from changing during animation
        
        if (OSVersion6OrAbove && animated && (! tabListRevealed) && ([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault)) {
            UINavigationController *lastSelectedNavigationController = nil;
            
            if ([lastSelectedViewController isKindOfClass:[UINavigationController class]]) {
                lastSelectedNavigationController = (id)lastSelectedViewController;
            }
            else {
                [lastSelectedViewController navigationController];
            }
            
            if (lastSelectedNavigationController != nil) {
                UIColor *tintColor = lastSelectedNavigationController.navigationBar.tintColor;
                UINavigationController *backgroundNavigationController = objc_getAssociatedObject(self, ( void *)kBackgroundNavigationControllerKey);
                
                if (backgroundNavigationController == nil) {
                    UIViewController *dummyViewController = HH_AUTORELEASE([[UIViewController alloc] init]);
                    UINavigationController *navigationController = HH_AUTORELEASE([[UINavigationController alloc] initWithRootViewController:dummyViewController]);
                    
                    [self addChildViewController:navigationController];
                    
                    UIView *navigationView = navigationController.view;
                    
                    [view insertSubview:navigationView atIndex:0];
                    [navigationView setAlpha:0.0f];
                    
                    [navigationController didMoveToParentViewController:self];
                    
                    objc_setAssociatedObject(self, ( void*)kBackgroundNavigationControllerKey, navigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    backgroundNavigationController = navigationController;
                }
                
                backgroundNavigationController.navigationBar.tintColor = tintColor;
            }
        }
#endif
        
		[lastSelectedViewController willMoveToParentViewController:nil];
		[self addChildViewController:selectedViewController];
        
		self.tabListTabsView.userInteractionEnabled = NO;
        
		HHTabListContainerView *lastContainerView = self.containerView;
		HHTabListContainerView *selectedContainerView = nil;
        
		if (selectedViewController != nil) {
			CGRect offscreenFrame = topViewControllerFrame;
            
			offscreenFrame.origin.x = offscreenFrame.size.width;
            
			selectedContainerView = HH_AUTORELEASE([[HHTabListContainerView alloc] initWithFrame:offscreenFrame]);
            
			UIView *selectedView = selectedViewController.view;
            
			[selectedView setFrame:[selectedContainerView bounds]];
			[selectedView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            
			[selectedContainerView addSubview:selectedView];
            
			[view addSubview:selectedContainerView];
            
			self.containerView = selectedContainerView;
		}
        
		void (^animationBlock)(void) = ^{
			self.animationInProgress = YES;
            
			CGRect lastSelectedFrame = [lastContainerView frame];
            
			lastSelectedFrame.origin.x = lastSelectedFrame.size.width;
            
			[lastContainerView setFrame:lastSelectedFrame];
			[selectedContainerView setFrame:topViewControllerFrame];
		};
        
		void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
			self.animationInProgress = NO;
			self.tabListTabsView.userInteractionEnabled = YES;
            
			[selectedViewController didMoveToParentViewController:self];
            
			[lastContainerView removeFromSuperview];
            
			[lastSelectedViewController removeFromParentViewController];
            
			[self attachGestureRecognizersToController:selectedViewController];
            
			self.lastSelectedViewController = selectedViewController;
            
			if (!tabListRevealed) {
				[tabListTabsView removeFromSuperview];
			}
            
			if (didSelectViewController) {
				[self.delegate tabListController:self didSelectViewController:selectedViewController];
			}
		};
        
		if (animated) {
			[UIView animateWithDuration:HH_TAB_LIST_ANIMATION_DURATION
							 animations:animationBlock
							 completion:completionBlock];
		}
		else {
			animationBlock();
			completionBlock(YES);
		}
	}
	else {
		HHTabListContainerView *containerView = self.containerView;
        
		void (^animationBlock)(void) = ^{
			self.animationInProgress = YES;
            
			containerView.frame = topViewControllerFrame;
		};
        
		void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
			self.animationInProgress = NO;
            
			if (!tabListRevealed) {
				[self.tabListTabsView removeFromSuperview];
			}
		};
        
		if (animated) {
			[UIView animateWithDuration:HH_TAB_LIST_ANIMATION_DURATION
							 animations:animationBlock
							 completion:completionBlock];
		}
		else {
			animationBlock();
			completionBlock(YES);
		}
        
		if (tabListRevealed != wasTabListRevealed) {
			[self attachGestureRecognizersToController:[self selectedViewController]];
		}
	}
}

- (void)applicationDidChangeStatusBarFrameNotification:(NSNotification*)notification
{
	[self setTabListRevealed:self.tabListRevealed animated:YES];
}


#pragma mark -
#pragma mark Gestures

- (void)attachPanGestureRecognizerToView:(UIView*)view
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																						action:@selector(gestureRecognizerDidPan:)];
    gestureRecognizer.cancelsTouchesInView = YES;
    gestureRecognizer.delaysTouchesBegan = YES;
    gestureRecognizer.delegate = self;
    
    [view addGestureRecognizer:gestureRecognizer];
    
	[self.gestureRecognizers addObject:gestureRecognizer];
    
    HH_RELEASE(gestureRecognizer);
}

- (void)attachPanGestureRecognizersToController:(UIViewController*)controller
{
	UINavigationController *navigationController = controller.navigationController;
    
	if (navigationController == nil) {
		if ([controller isKindOfClass:[UINavigationController class]]) {
			navigationController = (UINavigationController*)controller;
		}
	}
    
	if (navigationController != nil) {
		[self attachPanGestureRecognizerToView:navigationController.navigationBar];
	}
    
    BOOL tabListRevealed = self.tabListRevealed;
    
    if (tabListRevealed) {
		UIViewController *frontmostController = controller;
        
		if (navigationController != nil) {
			frontmostController = [navigationController.viewControllers lastObject];
		}
        
        [self attachPanGestureRecognizerToView:frontmostController.view];
    }
}

- (void)attachTapGestureRecognizerToView:(UIView*)view
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						action:@selector(gestureRecognizerDidTap:)];
    gestureRecognizer.cancelsTouchesInView = YES;
    gestureRecognizer.delaysTouchesBegan = YES;
    gestureRecognizer.delegate = self;
    
	[view addGestureRecognizer:gestureRecognizer];
    
	[self.gestureRecognizers addObject:gestureRecognizer];
    
	HH_RELEASE(gestureRecognizer);
}

- (void)attachTapGestureRecognizersToController:(UIViewController *)controller
{
    BOOL tabListRevealed = self.tabListRevealed;
    
	if (tabListRevealed) {
		UINavigationController *navigationController = controller.navigationController;
        
		if (navigationController == nil) {
			if ([controller isKindOfClass:[UINavigationController class]]) {
				navigationController = (UINavigationController*)controller;
			}
		}
        
		if (navigationController != nil) {
			[self attachTapGestureRecognizerToView:navigationController.navigationBar];
		}
        
		UIViewController *frontmostController = controller;
        
		if (navigationController != nil) {
			frontmostController = [navigationController.viewControllers lastObject];
		}
        
        [self attachTapGestureRecognizerToView:frontmostController.view];
	}
}

- (void)attachGestureRecognizersToController:(UIViewController*)controller
{
    [self removeGestureRecognizers];
    
    [self attachPanGestureRecognizersToController:controller];
    [self attachTapGestureRecognizersToController:controller];
}

- (void)removeGestureRecognizers
{
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
    }
    
    [self.gestureRecognizers removeAllObjects];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
	BOOL shouldReceiveTouch = (! self.animationInProgress);
	BOOL tabListRevealed = self.tabListRevealed;
    
	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
		if (! tabListRevealed) {
			shouldReceiveTouch = NO;
		}
	}
    
    return shouldReceiveTouch;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
	return YES;
}

- (void)gestureRecognizerDidPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    if (self.animationInProgress) {
		return;
	}
    
	UIGestureRecognizerState state = gestureRecognizer.state;
    
	if (state == UIGestureRecognizerStateBegan) {
		UIView *containerView = self.containerView;
        
		self.panOriginX = containerView.frame.origin.x;
        
		[self.view insertSubview:self.tabListTabsView belowSubview:self.containerView];
	}
	else if (state == UIGestureRecognizerStateChanged) {
		UIView *view = self.view;
		CGPoint translation = [gestureRecognizer translationInView:view];
		UIView *containerView = self.containerView;
		CGRect containerViewFrame = [containerView frame];
		CGFloat totalPanX = translation.x;
        
		containerViewFrame.origin.x = self.panOriginX + totalPanX;
        
		if (containerViewFrame.origin.x <= 0) {
			containerViewFrame.origin.x = 0;
		}
		else if (containerViewFrame.origin.x >= HH_TAB_LIST_WIDTH) {
			containerViewFrame.origin.x = HH_TAB_LIST_WIDTH;
		}
        
		[containerView setFrame:containerViewFrame];
	}
	else if ((state == UIGestureRecognizerStateEnded) || (state == UIGestureRecognizerStateCancelled)) {
		UIView *view = self.view;
		CGPoint translation = [gestureRecognizer translationInView:view];
		CGFloat totalPanX = translation.x;
        
		if (totalPanX < (-1.0 * HH_TAB_LIST_TRIGGER_OFFSET)) {
			[self setTabListRevealed:NO animated:YES];
		}
		else if (totalPanX > HH_TAB_LIST_TRIGGER_OFFSET) {
			[self setTabListRevealed:YES animated:YES];
		}
		else {
			[self setTabListRevealed:self.tabListRevealed animated:YES];
		}
	}
}

- (void)gestureRecognizerDidTap:(UITapGestureRecognizer*)tapGesture
{
    self.tabListRevealed = ! self.tabListRevealed;
    
    [self setTabListRevealed:self.tabListRevealed animated:YES];
}


#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		UIViewController *selectedViewController = [self selectedViewController];
        
		if (selectedViewController != nil) {
			return [selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
		}
	}
    
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
	[self setTabListRevealed:self.tabListRevealed animated:NO];
}


#pragma mark -
#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewControllers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tabList = @"tabList";
    HHTabListCell *cell = [tableView dequeueReusableCellWithIdentifier:tabList];
    
	if (cell == nil) {
        cell = [[HHTabListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tabList];
	}
    
	//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:self.selectionIndicatorImage];
    
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:indexPath.row];
    UITabBarItem *item = [selectedViewController tabBarItem];
    
    cell.textLabel.text = item.title;
	//    cell.iconImage = item.image;
    
    return cell;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    cell.textLabel.textColor = [UIColor darkTextColor];
}


#pragma mark -
#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	self.tabListRevealed = NO;
    
    [self setSelectedIndex:indexPath.row animated:YES];
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL result = YES;
    
    if (_delegateFlags.shouldSelectViewController) {
        UIViewController *viewController = [self.viewControllers objectAtIndex:indexPath.row];
        
		result = [self.delegate tabListController:self shouldSelectViewController:viewController];
    }
    
    if (result) {
        return indexPath;
    }
    else {
        return tableView.indexPathForSelectedRow;
    }
}


#pragma mark -
#pragma mark API

- (UIBarButtonItem*)revealTabListBarButtonItem
{
    NSLog(@"Called revealTableListBarButtonItem");
	UIImage *listImage = [UIImage imageNamed:@"list"];
	UIImage *listLandscapeImage = [UIImage imageNamed:@"list-landscape"];
	UIBarButtonItem *revealTabListBarButtonItem = nil;
    
	if ((listImage != nil) && (listLandscapeImage != nil)) {
		revealTabListBarButtonItem = [[UIBarButtonItem alloc] initWithImage:listImage
														landscapeImagePhone:listLandscapeImage
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(revealTabList:)];
        
        
	}
	else {
		revealTabListBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Tabs", @"Tabs")
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(revealTabList:)];
	}
    
	return revealTabListBarButtonItem;
}

- (IBAction)revealTabList:(id)sender
{
    NSLog(@"revealTabList called");
	[self setTabListRevealed:YES animated:YES];
}

@end


@implementation UIViewController (HHTabListController)

- (HHTabListController*)tabListController
{
    NSLog(@"tabListController");
	if ([self isKindOfClass:[HHTabListController class]]) {
		return (HHTabListController*)self;
	}
    
	return [self.parentViewController tabListController];
}

@end


@implementation HHTabListView

@end


@implementation HHTabListWorkaroundViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end


#pragma mark -
#pragma mark Functions

static UIInterfaceOrientation HHInterfaceOrientation(void)
{
	return [UIApplication sharedApplication].statusBarOrientation;
}

static CGRect HHCGRectRotate(CGRect rect)
{
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

static CGRect HHScreenBounds(void)
{
	CGRect bounds = [UIScreen mainScreen].bounds;
    
	if (UIInterfaceOrientationIsLandscape(HHInterfaceOrientation())) {
		return HHCGRectRotate(bounds);
	}
    
	return bounds;
}

static CGFloat HHStatusBarHeight(void)
{
	UIApplication *application = [UIApplication sharedApplication];
	CGRect statusBarFrame = [application statusBarFrame];
    
    if (UIInterfaceOrientationIsLandscape(HHInterfaceOrientation())) {
        return statusBarFrame.size.width;
	}
    else {
        return statusBarFrame.size.height;
	}
}
