//
//  XJNetworkStatusMonitor.m
//  Vidol
//
//  Created by XJIMI on 2015/10/14.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJNetworkStatusMonitor.h"

@interface XJNetworkStatusMonitor ()

@property (strong) Reachability *internetReachability;

@end


@implementation XJNetworkStatusMonitor

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [_internetReachability stopNotifier];
}

+ (instancetype)monitorWithNetworkStatusChange:(void (^)(NetworkStatus netStatus))block
{
    XJNetworkStatusMonitor *networkStatusMonitor = [XJNetworkStatusMonitor new];
    networkStatusMonitor.internetReachability = [Reachability reachabilityForInternetConnection];
    
    __weak typeof(networkStatusMonitor)weakSelf = networkStatusMonitor;
    networkStatusMonitor.internetReachability.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.netStatus = [reachability currentReachabilityStatus];
            block(weakSelf.netStatus);
        });
    };
    
    networkStatusMonitor.internetReachability.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.netStatus = [reachability currentReachabilityStatus];
            block(weakSelf.netStatus);
        });
    };
    
    [networkStatusMonitor.internetReachability startNotifier];
    
    networkStatusMonitor.netStatus = [networkStatusMonitor.internetReachability currentReachabilityStatus];
    block (networkStatusMonitor.netStatus);
    return networkStatusMonitor;
}

@end
