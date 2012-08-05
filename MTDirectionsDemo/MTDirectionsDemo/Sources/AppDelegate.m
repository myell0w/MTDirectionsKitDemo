#import "AppDelegate.h"
#import "MTDirectionsSampleViewController.h"


@implementation AppDelegate

////////////////////////////////////////////////////////////////////////
#pragma mark - Application Lifecycle
////////////////////////////////////////////////////////////////////////

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    MTDirectionsSampleViewController *viewController = [MTDirectionsSampleViewController viewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
