#import "MTDDirectionsGoogleMapsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MTDirectionsKit/MTDirectionsKit.h>


@interface MTDDirectionsGoogleMapsViewController () <GMSMapViewDelegate>

@property (nonatomic, readonly) GMSMapView *googleMapView;
@property (nonatomic, strong) NSMutableArray *markers;

@end

@implementation MTDDirectionsGoogleMapsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _markers = [NSMutableArray new];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];

    self.mapView =  (UIView<MTDMapView> *)[MTDGMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.googleMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.googleMapView.delegate = self;
    [self.view addSubview:self.mapView];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.googleMapView.myLocationEnabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.googleMapView.myLocationEnabled = NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsViewController
////////////////////////////////////////////////////////////////////////

- (NSArray *)annotations {
    return self.markers;
}

- (void)addAnnotation:(id<MKAnnotation>)annotation {
    GMSMarker *marker = [GMSMarker markerWithPosition:annotation.coordinate];

    marker.title = annotation.title;
    marker.map = self.googleMapView;
}

- (void)removeAnnotations:(NSArray *)annotations {
    for (GMSMarker *marker in annotations) {
        marker.map = nil;
    }
}

- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point {
    return [self.googleMapView.projection coordinateForPoint:point];
}

- (void)zoomToMyLocation {
    [self.googleMapView animateToLocation:self.googleMapView.myLocation.coordinate];
}

- (void)setRegionFromWaypoints:(NSArray *)waypoints animated:(BOOL)animated {
    GMSMutablePath *path = [GMSMutablePath new];

    for (MTDWaypoint *waypoint in waypoints) {
        [path addCoordinate:waypoint.coordinate];
    }

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];

    if (animated) {
        [self.googleMapView animateWithCameraUpdate:update];
    } else {
        [self.googleMapView moveCamera:update];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - GMSMapViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!_loadAlternatives && self.API != MTDDirectionsAPICustom) {
        [_intermediateGoals addObject:[MTDWaypoint waypointWithCoordinate:coordinate]];

        MKPointAnnotation *annotation = [MKPointAnnotation new];

        annotation.coordinate = coordinate;
        [self addAnnotation:annotation];

        [self loadDirectionsAndZoom:NO];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (GMSMapView *)googleMapView {
    return (GMSMapView *)self.mapView;
}


@end
