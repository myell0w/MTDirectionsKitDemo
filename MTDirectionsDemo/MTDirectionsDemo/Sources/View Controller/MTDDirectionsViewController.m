#import "MTDDirectionsViewController.h"
#import "MTDOptionsViewController.h"
#import "MTDTitleView.h"
#import "MTDSampleOverlayView.h"
#import <QuartzCore/QuartzCore.h>


#define kMTDSearchViewTop           -80.f


@interface MTDDirectionsViewController () <MTDOptionsViewControllerDelegate> {
    NSUInteger _requestOptions;
}

@property (nonatomic, strong) Class requestClass;
@property (nonatomic, strong) Class parserClass;

@property (nonatomic, strong) MTDTitleView *titleView;
@property (nonatomic, strong) UISegmentedControl *directionsControl;
@property (nonatomic, strong) UIButton *optionsControl;

@property (nonatomic, strong) UIBarButtonItem *showSearchViewItem;
@property (nonatomic, strong) UIBarButtonItem *routeItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation MTDDirectionsViewController

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithAPI:(MTDDirectionsAPI)API from:(MTDWaypoint *)from to:(MTDWaypoint *)to loadAlternatives:(BOOL)loadAlternatives {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _API = API;
        _from = from;
        _to = to;
        _loadAlternatives = loadAlternatives;
        _routeType = MTDDirectionsRouteTypeFastestDriving;
        _measurementSystem = MTDDirectionsGetMeasurementSystem();
        _overlayColor = [UIColor colorWithRed:0.f green:0.25f blue:1.f alpha:1.f];
        _overlayLineWidthFactor = 1.8f;

        _showsAnnotations = YES;
        _requestOptions = MTDDirectionsRequestOptionNone;
        _intermediateGoals = [NSMutableArray array];
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    CLLocationCoordinate2D from = CLLocationCoordinate2DMake(51.4554, -0.9742);              // Reading
    CLLocationCoordinate2D to = CLLocationCoordinate2DMake(51.38713, -1.0316);               // NSConference Wokefield Park
    CLLocationCoordinate2D intermediateGoal1 = CLLocationCoordinate2DMake(51.4388, -0.9409); // University
    CLLocationCoordinate2D intermediateGoal2 = CLLocationCoordinate2DMake(51.3765, -1.003);  // Beech Hill

    if ((self = [self initWithAPI:MTDDirectionsAPIMapQuest
                             from:[MTDWaypoint waypointWithCoordinate:from]
                               to:[MTDWaypoint waypointWithCoordinate:to]
                 loadAlternatives:NO])) {
        self.intermediateGoals = @[[MTDWaypoint waypointWithCoordinate:intermediateGoal1], [MTDWaypoint waypointWithCoordinate:intermediateGoal2]];
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.mapView directionsOverlay] == nil) {
        [self setRegionFromWaypoints:@[self.from, self.to] animated:NO];
    }

    [self updateDirectionsKitProperties];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.mapView directionsOverlay] == nil) {
        [self loadDirectionsAndZoom:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self hideLoadingIndicator];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsViewController
////////////////////////////////////////////////////////////////////////

- (void)registerCustomRequestClass:(Class)requestClass parserClass:(Class)parserClass {
    self.requestClass = requestClass;
    self.parserClass = parserClass;
}

- (void)setIntermediateGoals:(NSArray *)intermediateGoals {
    _intermediateGoals = [NSMutableArray arrayWithArray:intermediateGoals];
}

- (void)setRouteType:(MTDDirectionsRouteType)routeType {
    _routeType = routeType;

    switch (routeType) {
        case MTDDirectionsRouteTypePedestrian:
        case MTDDirectionsRouteTypePedestrianIncludingPublicTransport:
            self.segmentedControl.selectedSegmentIndex = 0;
            break;

        case MTDDirectionsRouteTypeFastestDriving:
        case MTDDirectionsRouteTypeShortestDriving:
            self.segmentedControl.selectedSegmentIndex = 1;

        case MTDDirectionsRouteTypeBicycle:
        default:
            self.segmentedControl.selectedSegmentIndex = NSNotFound;
            break;
    }
}

- (NSArray *)annotations {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)addAnnotation:(id<MKAnnotation>)annotation {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeAnnotations:(NSArray *)annotations {
    [self doesNotRecognizeSelector:_cmd];
}

- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point {
    [self doesNotRecognizeSelector:_cmd];
    return kCLLocationCoordinate2DInvalid;
}

- (void)zoomToMyLocation {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)setRegionFromWaypoints:(NSArray *)waypoints animated:(BOOL)animated {
    [self doesNotRecognizeSelector:_cmd];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDOptionsViewControllerDelegate
////////////////////////////////////////////////////////////////////////

- (void)optionsViewController:(MTDOptionsViewController *)optionsViewController didActivateAPI:(MTDDirectionsAPI)API {
    MTDDirectionsSetActiveAPI(API);

    [self dismissModalViewControllerAnimated:YES];
    [self loadDirectionsAndZoom:YES];
}

- (void)optionsViewController:(MTDOptionsViewController *)optionsViewController didChangeOverlayType:(BOOL)useCustomOverlay {
    if (useCustomOverlay) {
        MTDOverrideClass([MTDDirectionsOverlayView class], [MTDSampleOverlayView class]);
    } else {
        MTDOverrideClass([MTDDirectionsOverlayView class], nil);
    }

    [self dismissModalViewControllerAnimated:YES];
    [self loadDirectionsAndZoom:YES];
}

- (void)optionsViewController:(MTDOptionsViewController *)optionsViewController didChangeAvoidanceOfTollRoads:(BOOL)avoidTollRoads {
    _requestOptions = avoidTollRoads ? MTDDirectionsRequestOptionAvoidTollRoads : MTDDirectionsRequestOptionNone;

    [self dismissModalViewControllerAnimated:YES];
    [self loadDirectionsAndZoom:YES];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsDelegate
////////////////////////////////////////////////////////////////////////

- (void)mapView:(id<MTDMapView>)mapView willStartLoadingDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType {
    NSLog(@"Will start loading directions from '%@' to '%@'", from, to);

    [self showLoadingIndicator];
    self.from = from;
    self.to = to;
    self.directionsControl.hidden = YES;
}

- (MTDDirectionsOverlay *)mapView:(id<MTDMapView>)mapView didFinishLoadingDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    NSLog(@"Did finish loading directions from '%@' to '%@'", directionsOverlay.from, directionsOverlay.to);

    self.directionsControl.hidden = NO;
    [self hideLoadingIndicator];
    [self updateDirectionsInfoFromRoute:directionsOverlay.activeRoute];
    [self updateMapAnnotationsFromDirectionsOverlay:directionsOverlay];

    return directionsOverlay;
}

- (void)mapView:(id<MTDMapView>)mapView didFailLoadingDirectionsOverlayWithError:(NSError *)error {
    NSLog(@"Did fail loading directions with error: %@", error);

    [self hideLoadingIndicator];
    [self removeAllAnnotations];

    [self.titleView setTitle:@"Error" detailText:[error.userInfo objectForKey:MTDDirectionsKitErrorMessageKey]];
}

- (BOOL)mapView:(id<MTDMapView>)mapView shouldActivateRoute:(MTDRoute *)route ofDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    return YES;
}

- (void)mapView:(id<MTDMapView>)mapView didActivateRoute:(MTDRoute *)route ofDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    [self updateDirectionsInfoFromRoute:route];
}

- (UIColor *)mapView:(id<MTDMapView>)mapView colorForRoute:(MTDRoute *)route ofDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    return self.overlayColor;
}

- (CGFloat)mapView:(id<MTDMapView>)mapView lineWidthFactorForDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    return self.overlayLineWidthFactor;
}

- (void)mapView:(id<MTDMapView>)mapView didUpdateUserLocation:(MKUserLocation *)userLocation distanceToActiveRoute:(CGFloat)distanceToActiveRoute ofDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    NSLog(@"Did update user location, distance to active route: %f", distanceToActiveRoute);
    
    if (self.reloadIfUserLocationDeviatesFromRoute && distanceToActiveRoute > 20.f) {
        [self loadDirectionsAndZoom:NO];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Private
#pragma mark -
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - UI
////////////////////////////////////////////////////////////////////////

- (void)setupUI {
    // Title View
    self.titleView = [[MTDTitleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 300.f, 30.f)];
    self.navigationItem.titleView = self.titleView;

    // Directions Control
    CGFloat offset = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 15.f : 5.f;
    self.directionsControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"locate"], [UIImage imageNamed:@"maneuver"]]];
    self.directionsControl.frame = CGRectMake(offset,
                                              CGRectGetHeight(self.view.frame) - 30.f - offset,
                                              CGRectGetWidth(self.directionsControl.frame),
                                              30.f);
    self.directionsControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.directionsControl.momentary = YES;
    self.directionsControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.directionsControl.tintColor = self.navigationController.navigationBar.tintColor;
    self.directionsControl.layer.masksToBounds = NO;
    self.directionsControl.layer.shadowColor = [UIColor blackColor].CGColor;
    self.directionsControl.layer.shadowRadius = 3.f;
    self.directionsControl.layer.shadowOffset = CGSizeMake(4.f, 4.f);
    self.directionsControl.hidden = YES;
    [self.directionsControl addTarget:self action:@selector(handleDirectionsControlTap:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.directionsControl];

    if (self.API != MTDDirectionsAPICustom) {
        // Options Button
        UIImage *image = [UIImage imageNamed:@"options"];

        self.optionsControl = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.optionsControl setImage:image forState:UIControlStateNormal];
        self.optionsControl.frame = CGRectMake(CGRectGetWidth(self.view.frame) - image.size.width,
                                               CGRectGetHeight(self.view.frame) - image.size.height,
                                               image.size.width,
                                               image.size.height);
        self.optionsControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.optionsControl addTarget:self action:@selector(handleOptionsTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.optionsControl];
        
        // BarButtonItems
        self.showSearchViewItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"route"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(handleShowSearchViewItemPress:)];
        self.routeItem = [[UIBarButtonItem alloc] initWithTitle:@"Route"
                                                          style:UIBarButtonItemStyleDone
                                                         target:self
                                                         action:@selector(handleRouteItemPress:)];
        self.cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(handleCancelItemPress:)];
        self.navigationItem.rightBarButtonItem = self.showSearchViewItem;

        // RouteType control
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"pedestrian"],
                                 [UIImage imageNamed:@"car"]]];
        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.segmentedControl.tintColor = self.navigationController.navigationBar.tintColor;
        self.routeType = self.routeType; // updates selected segment index

        // Search View
        self.searchView = [[MTDSearchView alloc] initWithFrame:CGRectMake(0.f, kMTDSearchViewTop, CGRectGetWidth(self.view.frame), 75.f)];
        [self.view addSubview:self.searchView];
    }
}

- (void)setLoadingIndicatorVisible:(BOOL)visible {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

- (void)showLoadingIndicator {
    [self.titleView setTitle:@"Loading..." detailText:nil];
    [self setLoadingIndicatorVisible:YES];
}

- (void)hideLoadingIndicator {
    [self setLoadingIndicatorVisible:NO];
}

- (void)updateDirectionsInfoFromRoute:(MTDRoute *)route {
    NSString *title = route.name ?: @"Route";
    NSString *detailText = [NSString stringWithFormat:@"%@ - %@", route.formattedTime, route.distance];

    [self.titleView setTitle:title
                  detailText:detailText];
}

- (void)setSearchViewHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        self.navigationItem.titleView = self.titleView;
    } else {
        self.navigationItem.titleView = self.segmentedControl;
    }

    [UIView animateWithDuration:(animated ? 0.4 : 0.0) animations:^{
        CGRect rect = self.searchView.frame;

        rect.origin.y =  hidden ? kMTDSearchViewTop : 0.f;
        self.searchView.frame = rect;
    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Map
////////////////////////////////////////////////////////////////////////

- (void)updateDirectionsKitProperties {
    MTDDirectionsSetActiveAPI(self.API);
    MTDDirectionsSetMeasurementSystem(self.measurementSystem);
    MTDDirectionsSetLocale(self.locale);

    if (self.API == MTDDirectionsAPICustom) {
        MTDDirectionsAPIRegisterCustomRequestClass(self.requestClass);
        MTDDirectionsAPIRegisterCustomParserClass(self.parserClass);
    }

    // TODO: MTDOverrideClass
}

- (void)removeAllAnnotations {
    [self removeAnnotations:[self annotations]];
    self.fromAnnotation = nil;
    self.toAnnotation = nil;
}

- (void)updateMapAnnotationsFromDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    [self removeAllAnnotations];

    if (self.showsAnnotations) {
        self.fromAnnotation = [MKPointAnnotation new];
        self.fromAnnotation.coordinate = directionsOverlay.from.coordinate;
        self.fromAnnotation.title = [directionsOverlay.from.address description];

        self.toAnnotation = [MKPointAnnotation new];
        self.toAnnotation.coordinate = directionsOverlay.to.coordinate;
        self.toAnnotation.title = [directionsOverlay.to.address description];

        [self addAnnotation:self.fromAnnotation];
        [self addAnnotation:self.toAnnotation];

        for (MTDWaypoint *intermediateGoal in directionsOverlay.intermediateGoals) {
            if (intermediateGoal.hasValidCoordinate) {
                MKPointAnnotation *annotation = [MKPointAnnotation new];

                annotation.coordinate = intermediateGoal.coordinate;

                if (intermediateGoal.hasValidAddress) {
                    annotation.title = [intermediateGoal.address description];
                }

                [self addAnnotation:annotation];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Network
////////////////////////////////////////////////////////////////////////

- (void)loadDirectionsAndZoom:(BOOL)zoomToShowDirections {
    if (self.intermediateGoals.count > 0 || !_loadAlternatives) {
        [self.mapView loadDirectionsFrom:self.from
                                      to:self.to
                       intermediateGoals:self.intermediateGoals
                               routeType:self.routeType
                                 options:MTDDirectionsRequestOptionOptimizeRoute | _requestOptions
                    zoomToShowDirections:zoomToShowDirections];
    } else {
        [self.mapView loadAlternativeDirectionsFrom:self.from
                                                 to:self.to
                                          routeType:self.routeType
                               zoomToShowDirections:zoomToShowDirections];
    }
}

- (void)performSearchWithFromDescription:(NSString *)fromDescription toDescription:(NSString *)toDescription {
    NSArray *fromComponents = [[fromDescription stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@"/"];
    NSArray *toComponents = [[toDescription stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@"/"];
    MTDWaypoint *from = nil;
    MTDWaypoint *to = nil;

    [_intermediateGoals removeAllObjects];

    if (fromComponents.count == 2 && toComponents.count == 2) {
        CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake([[fromComponents objectAtIndex:0] doubleValue], [[fromComponents objectAtIndex:1] doubleValue]);
        CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake([[toComponents objectAtIndex:0] doubleValue], [[toComponents objectAtIndex:1] doubleValue]);

        from = [MTDWaypoint waypointWithCoordinate:fromCoordinate];
        to = [MTDWaypoint waypointWithCoordinate:toCoordinate];
    } else if (fromComponents.count < 2 && toComponents.count < 2) {
        from = [MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:fromDescription]];
        to = [MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:toDescription]];
    } else {
        [self.titleView setTitle:@"Invalid Input" detailText:nil];
    }

    if (_loadAlternatives) {
        [self.mapView loadAlternativeDirectionsFrom:from
                                                 to:to
                                          routeType:self.routeType
                               zoomToShowDirections:YES];
    } else {
        [self.mapView loadDirectionsFrom:from
                                      to:to
                       intermediateGoals:self.intermediateGoals
                               routeType:self.routeType
                                 options:MTDDirectionsRequestOptionOptimizeRoute
                    zoomToShowDirections:YES];
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleOptionsTap:(id)sender {
    MTDOptionsViewController *optionsViewController = [MTDOptionsViewController viewController];

    optionsViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    optionsViewController.delegate = self;

    [self presentModalViewController:optionsViewController animated:YES];
}

- (void)handleDirectionsControlTap:(id)sender {
    NSInteger selectedIndex = [sender selectedSegmentIndex];

    if (selectedIndex == 0) {
        [self zoomToMyLocation];
    } else {
        MTDRoute *route = [self.mapView directionsOverlay].activeRoute;

        if (route.maneuvers.count > 0) {
            MTDManeuverTableViewController *viewController = [[MTDManeuverTableViewController alloc] initWithRoute:route];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];

            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleManeuverDonePress:)];
            navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

            [self presentModalViewController:navigationController animated:YES];
        }
    }
}

- (void)handleManeuverDonePress:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleShowSearchViewItemPress:(id)sender {
    [self.navigationItem setLeftBarButtonItem:self.cancelItem animated:NO];
    [self.navigationItem setRightBarButtonItem:self.routeItem animated:NO];

    [self setSearchViewHidden:NO animated:YES];
}

- (void)handleCancelItemPress:(id)sender {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationItem setRightBarButtonItem:self.showSearchViewItem animated:NO];
    [self setSearchViewHidden:YES animated:YES];
}

- (void)handleRouteItemPress:(id)sender {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationItem setRightBarButtonItem:self.showSearchViewItem animated:NO];
    [self setSearchViewHidden:YES animated:YES];

    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.routeType = MTDDirectionsRouteTypePedestrian;
    } else {
        self.routeType = MTDDirectionsRouteTypeFastestDriving;
    }

    [self.view endEditing:YES];
    [self performSearchWithFromDescription:self.searchView.fromDescription toDescription:self.searchView.toDescription];
}

@end
