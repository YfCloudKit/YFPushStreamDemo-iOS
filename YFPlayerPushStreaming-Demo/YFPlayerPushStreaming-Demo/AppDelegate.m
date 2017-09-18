#import "AppDelegate.h"
#import "YFNavViewController.h"
#import "YFNewFeatureViewController.h"
#import <Bugly/Bugly.h>
#import "YfLisenceManger.h"
#define APPId @"566d0df2b5"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    YFNewFeatureViewController *start = [[YFNewFeatureViewController alloc] init];
    YFNavViewController *nav = [[YFNavViewController alloc] initWithRootViewController:start];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //[[UIScreen mainScreen] setBrightness:0.5];
    //5cac66cf999fba09a9aabe674d21a82098d597d4
    //fc00e8546afd27dbce70222c2a8f963f337fdaea
    //65592eeddc3d646db903a7367d58792268804f09
    //9e7299afc12d793a23d913d88be6fa6383f5876e
    [YfLisenceManger LisenceWithAK:"5cac66cf999fba09a9aabe674d21a82098d597d4" Token:"fc00e8546afd27dbce70222c2a8f963f337fdaea" YfAuthResult:^(int flag, NSString *description) {
        NSLog(@"%d=licence = %@",flag,description);
    }];

    [Bugly startWithAppId:APPId];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
