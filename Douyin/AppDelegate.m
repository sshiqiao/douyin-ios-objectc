//
//  AppDelegate.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AppDelegate.h"
#import "UserHomePageController.h"
#import "NetworkHelper.h"
#import "WebSocketManager.h"
#import "Visitor.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[UserHomePageController alloc] init]];
    [self.window makeKeyAndVisible];
    
    [self registerUserInfo];
    
    [self startReachability];
    
    return YES;
}

- (void)registerUserInfo {
    VisitorRequest *request = [VisitorRequest new];
    request.udid = UDID;
    [NetworkHelper postWithUrlPath:CREATE_VISITOR_BY_UDID_URL request:request success:^(id data) {
        VisitorResponse *response = [[VisitorResponse alloc] initWithDictionary:data error:nil];
        writeVisitor(response.data);
        WebSocketManager *manager = [WebSocketManager shareManager];
        [manager connect];
    } failure:^(NSError *error) {
        [UIWindow showTips:@"注册访客用户失败"];
    }];
}

- (void)startReachability {
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                [UIWindow showTips:@"网络环境未知"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [UIWindow showTips:@"未连接到网络"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [UIWindow showTips:@"当前正使用流量进行浏览"];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [UIWindow showTips:@"连接到无线网"];
                break;
            default:
                break;
        }
    }];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityCallBack:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)reachabilityCallBack:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    AFNetworkReachabilityStatus status = [userInfo[@"AFNetworkingReachabilityNotificationStatusItem"] integerValue];
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            [UIWindow showTips:@"网络环境未知"];
            break;
        case AFNetworkReachabilityStatusNotReachable:
            [UIWindow showTips:@"未连接到网络"];
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [UIWindow showTips:@"当前正使用流量进行浏览"];
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [UIWindow showTips:@"连接到无线网"];
            break;
        default:
            break;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
