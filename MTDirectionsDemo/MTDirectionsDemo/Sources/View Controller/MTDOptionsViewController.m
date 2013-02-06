#import "MTDOptionsViewController.h"


@interface MTDOptionsViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *APIControl;
@property (nonatomic, strong) IBOutlet UISwitch *customOverlayControl;
@property (nonatomic, strong) IBOutlet UISwitch *avoidTollRoadsControl;

@end

@implementation MTDOptionsViewController

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)viewController {
    return [[[self class] alloc] initWithNibName:nil bundle:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.APIControl.selectedSegmentIndex = (NSUInteger)MTDDirectionsGetActiveAPI();
    self.customOverlayControl.on = MTDOverriddenClass([MTDDirectionsOverlayView class]) != [MTDDirectionsOverlayView class];
    // TODO: persist state of avoid switch
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (IBAction)handleAPIChange:(id)sender {
    NSUInteger index = [sender selectedSegmentIndex];
    MTDDirectionsAPI API = (MTDDirectionsAPI)index;

    [self.delegate optionsViewController:self didActivateAPI:API];
}

- (IBAction)handleCustomizedOverlayChange:(id)sender {
    BOOL useCustomizedOverlay = [sender isOn];

    [self.delegate optionsViewController:self didChangeOverlayType:useCustomizedOverlay];
}

- (IBAction)handleAvoidTollRoadsChange:(id)sender {
    BOOL avoidTollRoads = [sender isOn];

    [self.delegate optionsViewController:self didChangeAvoidanceOfTollRoads:avoidTollRoads];
}

@end
