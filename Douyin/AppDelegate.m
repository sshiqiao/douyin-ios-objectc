//
//  AppDelegate.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "UserHomePageController.h"
#import "NetworkHelper.h"
#import "WebSocketManager.h"
#import "AVPlayerManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[UserHomePageController new]];
    [_window makeKeyAndVisible];

    [NetworkHelper startListening];
    [[WebSocketManager shareManager] connect];
    [AVPlayerManager setAudioMode];
    
    [self requestPermission];
    
    return YES;
}

- (void)requestPermission {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //process photo library request status.
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint touchLocation = [[[event allTouches] anyObject] locationInView:self.window];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if (CGRectContainsPoint(statusBarFrame, touchLocation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarTouchBeginNotification" object:nil];
    }
}

@end
