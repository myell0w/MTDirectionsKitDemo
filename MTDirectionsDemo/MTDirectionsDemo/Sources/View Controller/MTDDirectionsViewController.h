//
//  MTDDirectionsViewController.h
//  MTDirectionsKitDemo
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <MTDirectionsKit/MTDirectionsKit.h>


@interface MTDDirectionsViewController : UIViewController <MTDDirectionsDelegate, MKMapViewDelegate>

@property (nonatomic, strong) id mapView;

// Use these to customize
@property (nonatomic, copy) NSArray *intermediateGoals;
@property (nonatomic, assign) MTDDirectionsRouteType routeType;
@property (nonatomic, assign) MTDMeasurementSystem measurementSystem;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, copy) NSDictionary *overriddenClassNames;
@property (nonatomic, strong) UIColor *overlayColor;
@property (nonatomic, assign) CGFloat overlayLineWidthFactor;

@property (nonatomic, assign) BOOL showsAnnotations;
@property (nonatomic, assign) BOOL showsUserLocation;

@property (nonatomic, assign) BOOL reloadIfUserLocationDeviatesFromRoute;


- (id)initWithAPI:(MTDDirectionsAPI)API from:(MTDWaypoint *)from to:(MTDWaypoint *)to loadAlternatives:(BOOL)loadAlternatives;

- (void)registerCustomRequestClass:(Class)requestClass parserClass:(Class)parserClass;

@end
