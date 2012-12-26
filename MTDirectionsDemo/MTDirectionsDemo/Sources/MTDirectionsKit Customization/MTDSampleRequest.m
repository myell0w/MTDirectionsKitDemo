#import "MTDSampleRequest.h"


@implementation MTDSampleRequest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    // doing nothing here
}

- (NSString *)HTTPAddress {
    // We don't really use the address, since we return a hardcoded URL in preparedURLForAddress
    return @"http://mtdirectionsk.it";
}

- (MTDDirectionsAPI)API {
    return MTDDirectionsAPICustom;
}

- (NSURL *)preparedURLForAddress:(NSString *)address {
    // we always want to return the same file for our test request
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"directions"];

    return URL;
}

@end
