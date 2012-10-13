//
//  MTDManeuverTableViewController.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import <UIKit/UIKit.h>


@class MTDRoute;
@class MTDManeuver;
@protocol MTDManeuverTableViewControllerDelegate;


@interface MTDManeuverTableViewController : UITableViewController

@property (nonatomic, readonly) MTDRoute *route;
@property (nonatomic, mtd_weak) id<MTDManeuverTableViewControllerDelegate> maneuverDelegate;

- (id)initWithRoute:(MTDRoute *)route;

- (MTDManeuver *)maneuverAtIndexPath:(NSIndexPath *)indexPath;

@end
