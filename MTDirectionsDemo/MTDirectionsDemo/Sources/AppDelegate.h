//
//  AppDelegate.h
//  MTDirectionsKitDemo
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, readonly) NSString *bingAPIKey;
@property (nonatomic, readonly) NSString *googleAPIKey;

@end
