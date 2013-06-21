//
//  HHTabListTabsView.m
//  iPOS
//
//  Created by Enning Tang on 2/8/13.
//
//

#import "HHTabListTabsView.h"

@implementation HHTabListTabsView

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    
    if (self) {
		self.backgroundView = nil;
        
        // darkPattern.png obtained from http://subtlepatterns.com/classy-fabric/
        // Made by Richard Tabor http://www.purtypixels.com/
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkPattern"]];
		self.separatorColor = [UIColor clearColor];
    }
    
	return self;
}


#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
	
	id<UITableViewDataSource> dataSource = self.dataSource;
	NSUInteger count = [dataSource tableView:self numberOfRowsInSection:0];
	
    self.scrollEnabled = (self.rowHeight * count) > self.bounds.size.height;
}

@end
