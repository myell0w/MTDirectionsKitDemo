#import "MTDDirectionsAppleMapsViewController.h"

@interface MTDDirectionsAppleMapsViewController () <MKMapViewDelegate>

@property (nonatomic, readonly) MTDMapView *appleMapView;

@end

@implementation MTDDirectionsAppleMapsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    // Bug in Google Maps SDK
    // http://stackoverflow.com/questions/15052952/google-maps-sdk-mapkit-in-the-same-app-cause-crash
    [EAGLContext setCurrentContext:nil];

    self.mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
    self.appleMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.appleMapView.delegate = self;
    self.appleMapView.directionsEdgePadding = UIEdgeInsetsMake(35.f, 15.f, 35.f, 15.f);
    [self.view addSubview:self.mapView];

    if (!_loadAlternatives && self.API != MTDDirectionsAPICustom) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapLongPress:)];
        [self.mapView addGestureRecognizer:longPress];
    }

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.appleMapView.showsUserLocation = self.showsUserLocation;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.appleMapView.showsUserLocation = NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsViewController
////////////////////////////////////////////////////////////////////////

- (NSArray *)annotations {
    return [self.appleMapView annotations];
}

- (void)addAnnotation:(id<MKAnnotation>)annotation {
    [self.appleMapView addAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations {
    [self.appleMapView removeAnnotations:annotations];
}

- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point {
    return [self.appleMapView convertPoint:point toCoordinateFromView:self.appleMapView];
}

- (void)zoomToMyLocation {
    [self.appleMapView setCenterCoordinate:[self.appleMapView userLocation].coordinate animated:YES];
}

- (void)setRegionFromWaypoints:(NSArray *)waypoints animated:(BOOL)animated {
    if (waypoints != nil) {
        CLLocationDegrees maxX = -DBL_MAX;
        CLLocationDegrees maxY = -DBL_MAX;
        CLLocationDegrees minX = DBL_MAX;
        CLLocationDegrees minY = DBL_MAX;

        for (NSUInteger i=0; i<waypoints.count; i++) {
            MTDWaypoint *currentLocation = [waypoints objectAtIndex:i];

            if (currentLocation.hasValidCoordinate) {
                MKMapPoint mapPoint = MKMapPointForCoordinate(currentLocation.coordinate);

                if (mapPoint.x > maxX) {
                    maxX = mapPoint.x;
                }
                if (mapPoint.x < minX) {
                    minX = mapPoint.x;
                }
                if (mapPoint.y > maxY) {
                    maxY = mapPoint.y;
                }
                if (mapPoint.y < minY) {
                    minY = mapPoint.y;
                }
            }
        }

        if (maxX != -DBL_MAX && minX != DBL_MAX) {
            MKMapRect mapRect = MKMapRectMake(minX,minY,maxX-minX,maxY-minY);

            [self.appleMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(50.f, 50.f, 50.f, 50.f) animated:animated];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MTDirectionsKitAnnotation"];

    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MTDirectionsKitAnnotation"];
    } else {
        pin.annotation = annotation;
    }

    pin.draggable = YES;
    pin.animatesDrop = YES;
    pin.canShowCallout = YES;

    if (annotation == self.fromAnnotation) {
        pin.pinColor = MKPinAnnotationColorRed;
    } else if (annotation == self.toAnnotation) {
        pin.pinColor = MKPinAnnotationColorGreen;
    } else {
        pin.pinColor = MKPinAnnotationColorPurple;
    }

    return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {

    if(newState == MKAnnotationViewDragStateEnding) {
        if (annotationView.annotation == self.fromAnnotation) {
            self.from = [MTDWaypoint waypointWithCoordinate:annotationView.annotation.coordinate];
        } else if (annotationView.annotation == self.toAnnotation) {
            self.to = [MTDWaypoint waypointWithCoordinate:annotationView.annotation.coordinate];
        }

        self.searchView.fromDescription = [NSString stringWithFormat:@"%f/%f",
                                           self.fromAnnotation.coordinate.latitude,
                                           self.fromAnnotation.coordinate.longitude];
        self.searchView.toDescription = [NSString stringWithFormat:@"%f/%f",
                                         self.toAnnotation.coordinate.latitude,
                                         self.toAnnotation.coordinate.longitude];

        [self loadDirectionsAndZoom:NO];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDMapView *)appleMapView {
    return (MTDMapView *)self.mapView;
}

- (void)handleMapLongPress:(UILongPressGestureRecognizer *)longPress {
    if ((longPress.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        CGPoint location = [longPress locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self coordinateForPoint:location];

        [_intermediateGoals addObject:[MTDWaypoint waypointWithCoordinate:coordinate]];

        MKPointAnnotation *annotation = [MKPointAnnotation new];

        annotation.coordinate = coordinate;
        [self addAnnotation:annotation];

        [self loadDirectionsAndZoom:NO];
    }
}

@end
