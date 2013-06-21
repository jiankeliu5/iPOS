//
//  MenuViewController.m
//  iPOS
//
//  Created by Enning Tang on 5/1/13.
//
//

#import "MenuViewController.h"

@implementation RightViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Update the UI to reflect the monster set on initial load.
    [self refreshUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated, in this case the IBOutlets.
}

#pragma mark - New Methods
-(void)refreshUI
{
    /*
    _nameLabel.text = _monster.name;
    _iconImageView.image = [UIImage imageNamed:_monster.iconName];
    _descriptionLabel.text = _monster.description;
    _weaponImageView.image = [_monster weaponImage];
     */
}


#pragma mark - UISplitViewDelegate methods
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    //Grab a reference to the popover
    self.popover = pc;
    
    //Set the title of the bar button item
    barButtonItem.title = @"Monsters";
    
    //Set the bar button item as the Nav Bar's leftBarButtonItem
    [_tabBarItem setLeftBarButtonItem:barButtonItem animated:YES];
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //Remove the barButtonItem.
    [_tabBarItem setLeftBarButtonItem:nil animated:YES];
    
    //Nil out the pointer to the popover.
    _popover = nil;
}

#pragma mark - IBActions
-(IBAction)chooseColorButtonTapped:(id)sender
{
    if (_colorPicker == nil) {
        //Create the ColorPickerViewController.
        _colorPicker = [[MenuPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _colorPicker.delegate = self;
    }
    
    if (_colorPickerPopover == nil) {
        //The color picker popover is not showing. Show it.
        _colorPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_colorPicker];
        [_colorPickerPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *) sender  permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_colorPickerPopover dismissPopoverAnimated:YES];
        _colorPickerPopover = nil;
    }
}

#pragma mark - ColorPickerDelegate method
-(void)selectedColor:(UIColor *)newColor
{
    _nameLabel.textColor = newColor;
    
    //Dismiss the popover if it's showing.
    if (_colorPickerPopover) {
        [_colorPickerPopover dismissPopoverAnimated:YES];
        _colorPickerPopover = nil;
    }
}


@end
