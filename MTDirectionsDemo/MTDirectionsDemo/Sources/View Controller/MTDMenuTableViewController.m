#import "MTDMenuTableViewController.h"
#import "MTDDirectionsAppleMapsViewController.h"
#import "MTDDirectionsGoogleMapsViewController.h"
#import "MTDSampleParser.h"
#import "MTDSampleRequest.h"
#import "AppDelegate.h"


typedef NS_ENUM(NSUInteger, MTDMenuSection) {
    MTDMenuSectionApple,
    MTDMenuSectionGoogle,
    MTDMenuSectionMapBox,
    MTDMenuSectionCount = 2
};

typedef NS_ENUM(NSUInteger, MTDMenuItem) {
    MTDMenuItemAlternative,
    MTDMenuItemIntermediateGoals,
    MTDMenuItemCurrentLocation,
    MTDMenuItemLongDistance,
    MTDMenuItemCustomProvider,
    MTDMenuItemCount
};


@implementation MTDMenuTableViewController

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)viewController {
    return [[[self class] alloc] initWithStyle:UITableViewStyleGrouped];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"MTDirectionsKit Demo";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Demo" style:UIBarButtonItemStylePlain target:nil action:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MTDMenuSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MTDMenuItemCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case MTDMenuSectionApple:
            return @"MapKit";

        case MTDMenuSectionGoogle:
            return @"Google Maps SDK";

        case MTDMenuSectionMapBox:
            return @"MapBox SDK";
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case MTDMenuSectionApple:
            return @"Samples demonstrating MTDirectionsKit used on Apple's MapKit. Running on iOS 6 this means Apple Maps are used, on previous iOS versions Google Maps.\n\n To test Bing Routes insert your API Key in AppDelegate.m, Line 23.";

        case MTDMenuSectionGoogle:
            return @"Samples demonstrating MTDirectionsKit on Google's Maps SDK. You need to provide your Google Maps SDK Key in AppDelegate.m, Line 26.";

        case MTDMenuSectionMapBox:
            return @"Samples demonstrating MTDirectionsKit on MapBox.";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"MTDMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSString *title = [self titleForIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }

    cell.textLabel.text = title;

    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MTDDirectionsViewController *viewController = nil;
    MTDDirectionsAPI API = MTDDirectionsGetActiveAPI();
    Class viewControllerClass = Nil;

    if (API == MTDDirectionsAPICustom) {
        API = MTDDirectionsAPIMapQuest;
    }

    // Check which class to instantiate
    switch (indexPath.section) {
        case MTDMenuSectionApple: {
            viewControllerClass = [MTDDirectionsAppleMapsViewController class];
            break;
        }

        case MTDMenuSectionGoogle: {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

            if (appDelegate.googleAPIKey.length > 0) {
                viewControllerClass = [MTDDirectionsGoogleMapsViewController class];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"API Key required"
                                                                    message:@"You need to provide your Google API Key in AppDelegate.m, Line 26 to test Google Maps SDK integration."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Rad"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            break;
        }

        case MTDMenuSectionMapBox: {
            break;
        }

        default: {
            break;
        }
    }

    // set properties on viewController
    if (viewControllerClass != Nil) {
        switch (indexPath.row) {
            case MTDMenuItemAlternative: {
                CLLocationCoordinate2D from = CLLocationCoordinate2DMake(40.339885, -75.926577);         // Reading USA
                CLLocationCoordinate2D to = CLLocationCoordinate2DMake(38.895114, -77.036369);           // Washington D.C.

                viewController = [[viewControllerClass alloc] initWithAPI:API
                                                                     from:[MTDWaypoint waypointWithCoordinate:from]
                                                                       to:[MTDWaypoint waypointWithCoordinate:to]
                                                         loadAlternatives:YES];
                break;
            }

            case MTDMenuItemIntermediateGoals: {
                CLLocationCoordinate2D from = CLLocationCoordinate2DMake(51.4554, -0.9742);              // Reading
                CLLocationCoordinate2D to = CLLocationCoordinate2DMake(51.38713, -1.0316);               // NSConference Wokefield Park
                CLLocationCoordinate2D intermediateGoal1 = CLLocationCoordinate2DMake(51.4388, -0.9409); // University
                CLLocationCoordinate2D intermediateGoal2 = CLLocationCoordinate2DMake(51.3765, -1.003);  // Beech Hill

                viewController = [[viewControllerClass alloc] initWithAPI:API
                                                                     from:[MTDWaypoint waypointWithCoordinate:from]
                                                                       to:[MTDWaypoint waypointWithCoordinate:to]
                                                         loadAlternatives:NO];

                viewController.intermediateGoals = @[[MTDWaypoint waypointWithCoordinate:intermediateGoal1], [MTDWaypoint waypointWithCoordinate:intermediateGoal2]];
                viewController.overlayColor = [UIColor brownColor];
                viewController.overlayLineWidthFactor = 1.f;
                viewController.routeType = MTDDirectionsRouteTypePedestrian;

                break;
            }

            case MTDMenuItemCurrentLocation: {
                CLLocationCoordinate2D to = CLLocationCoordinate2DMake(37.474858,-122.218094);

                viewController = [[viewControllerClass alloc] initWithAPI:API
                                                                     from:[MTDWaypoint waypointForCurrentLocation]
                                                                       to:[MTDWaypoint waypointWithCoordinate:to]
                                                         loadAlternatives:YES];

                viewController.reloadIfUserLocationDeviatesFromRoute = YES;
                viewController.showsUserLocation = YES;
                viewController.overlayColor = [UIColor purpleColor];
                viewController.overlayLineWidthFactor = 2.5f;

                break;
            }

            case MTDMenuItemLongDistance: {
                viewController = [[viewControllerClass alloc] initWithAPI:API
                                                                     from:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:@"Portland Oregon"]]
                                                                       to:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:@"San Diego"]]
                                                         loadAlternatives:NO];

                viewController.intermediateGoals = @[[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:@"New York"]]];
                viewController.overlayColor = [UIColor colorWithRed:0.f green:0.4f blue:0.f alpha:1.f];
                viewController.overlayLineWidthFactor = 3.f;

                break;
            }

            case MTDMenuItemCustomProvider: {
                viewController = [[viewControllerClass alloc] initWithAPI:MTDDirectionsAPICustom
                                                                     from:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:@"Güssing"]]
                                                                       to:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:@"Wien"]]
                                                         loadAlternatives:NO];

                viewController.overlayColor = [UIColor colorWithRed:0.4f green:0.1f blue:0.1f alpha:1.f];
                viewController.overlayLineWidthFactor = 1.4f;
                [viewController registerCustomRequestClass:[MTDSampleRequest class] parserClass:[MTDSampleParser class]];
                
                break;
            }

            default: {
                break;
            }
        }
    }

    if (viewController != nil) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;

    switch (row) {
        case MTDMenuItemAlternative:
            return @"Alternative Directions";
            
        case MTDMenuItemIntermediateGoals:
            return @"Intermediate Goals";
            
        case MTDMenuItemCurrentLocation:
            return @"Tracking Current Location";
            
        case MTDMenuItemLongDistance:
            return @"Long Distance";

        case MTDMenuItemCustomProvider:
            return @"Custom API Provider";
    }
    
    return nil;
}

@end
