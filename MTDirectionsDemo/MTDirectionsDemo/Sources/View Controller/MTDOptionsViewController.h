//
//  MTDOptionsViewController.h
//  MTDirectionsKitDemo
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MTDirectionsKit/MTDirectionsKit.h>


@protocol MTDOptionsViewControllerDelegate;


@interface MTDOptionsViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<MTDOptionsViewControllerDelegate> delegate;

+ (instancetype)viewController;

@end


@protocol MTDOptionsViewControllerDelegate <NSObject>

- (void)optionsViewController:(MTDOptionsViewController *)optionsViewController didActivateAPI:(MTDDirectionsAPI)API;
- (void)optionsViewController:(MTDOptionsViewController *)optionsViewController didChangeOverlayType:(BOOL)useCustomOverlay;
- (void)optionsViewController:(MTDOptionsViewController *)optionsViewController didChangeAvoidanceOfTollRoads:(BOOL)avoidTollRoads;

@end