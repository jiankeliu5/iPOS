//
//  DemoTableControllerViewController.m
//  FPPopoverDemo
//
//  Created by Alvise Susmel on 4/13/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//

#import "DemoTableController.h"
#import "FPViewController.h"
@interface DemoTableController ()

@end

@implementation DemoTableController
@synthesize delegate=_delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"iPOS Menu";
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"New Order"];
    }else if (indexPath.row == 1)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Lookup Order"];
    }else if (indexPath.row == 2)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Current Order"];
    }else if (indexPath.row == 3)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Customer"];
    }else if (indexPath.row == 4)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Selections"];
    }//else if (indexPath.row == 5)
    //{
    //    cell.textLabel.text = [NSString stringWithFormat:@"My Orders"];
    //}
    /*else if (indexPath.row == 5)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"My Info"];
    }*/else if (indexPath.row == 5)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"E-mail Receipt"];
    }else if (indexPath.row == 6)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Logout"];
    }
    //cell.textLabel.text = [NSString stringWithFormat:@"cell %d",indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.delegate respondsToSelector:@selector(selectedTableRow:)])
    {
        [self.delegate selectedTableRow:indexPath.row];
    }
}




@end
