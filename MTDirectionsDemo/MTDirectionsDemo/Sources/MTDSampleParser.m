#import "MTDSampleParser.h"


@implementation MTDSampleParser

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

// We demonstrate how to setup a simple custom parser here, you can do any parsing you would like
- (void)parseWithCompletion:(mtd_parser_block)completion {
    NSString *dataString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    NSArray *components = [dataString componentsSeparatedByString:@";"];
    NSMutableArray *waypoints = [NSMutableArray array];

    for (NSString *component in components) {
        NSArray *waypointComponents = [component componentsSeparatedByString:@","];
        CLLocationDegrees latitude = [waypointComponents[0] doubleValue];
        CLLocationDegrees longitude = [waypointComponents[1] doubleValue];

        MTDWaypoint *waypoint = [MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
        [waypoints addObject:waypoint];
    }

    MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                maneuvers:nil
                                                 distance:[MTDDistance distanceWithMeters:150866.3]
                                            timeInSeconds:7915.
                                           additionalInfo:nil];
    
    MTDDirectionsOverlay *overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:@[route]
                                                               intermediateGoals:self.intermediateGoals
                                                                       routeType:self.routeType];

    [self callCompletion:completion overlay:overlay error:nil];
}

@end
