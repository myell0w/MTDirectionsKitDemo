#import "MTDDirectionsAppleMapsViewController.h"

@interface MTDDirectionsAppleMapsViewController ()

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
    self.mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
    self.appleMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.appleMapView.delegate = self;
    self.appleMapView.directionsEdgePadding = UIEdgeInsetsMake(35.f, 15.f, 35.f, 15.f);
    [self.view addSubview:self.mapView];
    
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
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDMapView *)appleMapView {
    return (MTDMapView *)self.mapView;
}

@end
