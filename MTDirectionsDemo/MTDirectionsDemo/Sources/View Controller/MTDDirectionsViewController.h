//
//  MTDDirectionsViewController.h
//  MTDirectionsKitDemo
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <MTDirectionsKit/MTDirectionsKit.h>
#import "MTDSearchView.h"


@interface MTDDirectionsViewController : UIViewController <MTDDirectionsDelegate> {
    BOOL _loadAlternatives;
    NSMutableArray *_intermediateGoals;
}

@property (nonatomic, strong) UIView<MTDMapView> *mapView;

// Use these to customize
@property (nonatomic, readonly) MTDDirectionsAPI API;
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


@property (nonatomic, strong) MTDWaypoint *from;
@property (nonatomic, strong) MTDWaypoint *to;
@property (nonatomic, strong) MKPointAnnotation *fromAnnotation;
@property (nonatomic, strong) MKPointAnnotation *toAnnotation;
@property (nonatomic, strong) MTDSearchView *searchView;


- (id)initWithAPI:(MTDDirectionsAPI)API from:(MTDWaypoint *)from to:(MTDWaypoint *)to loadAlternatives:(BOOL)loadAlternatives;

- (void)registerCustomRequestClass:(Class)requestClass parserClass:(Class)parserClass;
- (void)loadDirectionsAndZoom:(BOOL)zoomToShowDirections;

@end
