//
//  LookupOrderUtil.m
//  iPOS
//
//  Created by Torey Lomenda on 10/31/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "LookupOrderUtil.h"
#import "AlertUtils.h"

#import "iPOSFacade.h"
#import "OrderCart.h"

#import "OrderItemsViewController.h"
#import "OrderListViewController.h"
#import "PreviousOrder.h"

@implementation LookupOrderUtil

+ (void) showOrdersFrom:(UIViewController *)parentController withPhone:(NSString *)phoneNumber {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    OrderCart *orderCart = [OrderCart sharedInstance];
    
    
    // Clean the dashes out of the phone number
    NSString *searchString = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // See if we are at least a 10 digit number
    NSString *regex = @"[0-9]{10}";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([regextest evaluateWithObject:searchString] == YES) {
        NSArray *foundOrderList = [facade lookupOrderByPhoneNumber:searchString];
        if (foundOrderList && [foundOrderList count] > 0) {
            if ([foundOrderList count] == 1) {
                // Found one previous order, prep and go to order edit view controller
                PreviousOrder *p = (PreviousOrder *)[foundOrderList objectAtIndex:0];
                NSLog(@"Found one previous order: %@", p.orderId);
                
                Order *order = [facade lookupOrderByOrderId:p.orderId];
                if (order != nil) {
                    // Prep and go to the order edit view controller
                    NSLog(@"Single return from search by phone.  Found Order: %@", order.orderId);
                    [orderCart setPreviousOrder:order];
                    OrderItemsViewController *orderItemsViewController = [[OrderItemsViewController alloc] init];
                    orderItemsViewController.restorationIdentifier = @"orderItemVCID";
                    [[parentController navigationController] pushViewController:orderItemsViewController animated:TRUE];
                    [orderItemsViewController release];
                } else {
                    [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Could not retrieve previous order.  Order Id: %@", p.orderId] withTitle:@"iPOS"];
                }
            } else {
                NSLog(@"Found %d previous orders.", [foundOrderList count]);
                
                // Set the previous order list on the order cart singleton
                [orderCart setPreviousOrderList:foundOrderList];
                
                OrderListViewController *orderListController = [[OrderListViewController alloc] init];
                [orderListController setSearchPhone:phoneNumber];
                [[parentController navigationController] pushViewController:orderListController animated:TRUE];
                [orderListController release];
            }
        } else {
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"No orders found for %@", phoneNumber] withTitle:@"iPOS"]; 
        }
    } else {
        [AlertUtils showModalAlertMessage:@"Please enter a 10 digit phone number" withTitle:@"iPOS"];
    }
}

+ (void) showOrdersFrom:(UIViewController *)parentController withSalesPersonId:(NSString *)salesPersonId {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    OrderCart *orderCart = [OrderCart sharedInstance];
    
    NSArray *foundOrderList = [facade lookupOrderBySalesPersonId:salesPersonId];
    NSLog(@"Found %d previous orders.", [foundOrderList count]);
    
    // Set the previous order list on the order cart singleton
    [orderCart setPreviousOrderList:foundOrderList];
    
    OrderListViewController *orderListController = [[OrderListViewController alloc] init];
    [orderListController setSearchPhone:salesPersonId];
    [[parentController navigationController] pushViewController:orderListController animated:TRUE];
    [orderListController release];
}

@end
