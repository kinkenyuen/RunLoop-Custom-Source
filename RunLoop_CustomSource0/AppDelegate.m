//
//  AppDelegate.m
//  RunLoop_CustomSource0
//
//  Created by jianqin_ruan on 2021/3/2.
//

#import "AppDelegate.h"
#import "RunLoopSource.h"

@interface AppDelegate ()
{
    NSMutableArray *sourcesToPing;
}
@end

@implementation AppDelegate

+ (nullable AppDelegate *)sharedAppDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)registerSource:(RunLoopContext*)sourceInfo;
{
    [sourcesToPing addObject:sourceInfo];
}
 
- (void)removeSource:(RunLoopContext*)sourceInfo
{
    id    objToRemove = nil;
 
    for (RunLoopContext* context in sourcesToPing)
    {
        if ([context isEqual:sourceInfo])
        {
            objToRemove = context;
            break;
        }
    }
 
    if (objToRemove)
        [sourcesToPing removeObject:objToRemove];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    sourcesToPing = [NSMutableArray array];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
