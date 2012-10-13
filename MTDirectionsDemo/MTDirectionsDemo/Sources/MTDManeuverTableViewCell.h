//
//  MTDManeuverTableViewCell.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDManeuver;


@interface MTDManeuverTableViewCell : UITableViewCell

@property (nonatomic, strong) MTDManeuver *maneuver;

+ (CGFloat)neededHeightForManeuver:(MTDManeuver *)maneuver constrainedToWidth:(CGFloat)width;

+ (void)setDistanceFont:(UIFont *)distanceFont;
+ (void)setInstructionsFont:(UIFont *)instructionsFont;

@end
