//
//  main.m
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NSDebug.h"

int main(int argc, char* argv[]) 
{
    /*
    NSZombieEnabled = YES;
    NSDeallocateZombies = NO;

    if (getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled"))
    {
        NSLog(@"Zombie Enabled");
    }*/
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"iPOSAppDelegate");
    [pool release];
    return retVal;
}
