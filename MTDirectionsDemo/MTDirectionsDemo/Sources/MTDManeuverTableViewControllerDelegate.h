//
//  MTDManeuverTableViewControllerDelegate.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <Foundation/Foundation.h>


@class MTDManeuverTableViewController;


@protocol MTDManeuverTableViewControllerDelegate <NSObject>

- (void)maneuverTableViewController:(MTDManeuverTableViewController *)maneuverTableViewController didSelectManeuverAtIndexPath:(NSIndexPath *)indexPath;

@end
