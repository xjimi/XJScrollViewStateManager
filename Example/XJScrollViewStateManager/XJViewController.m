//
//  XJViewController.m
//  XJScrollViewStateManager
//
//  Created by xjimi on 06/03/2019.
//  Copyright (c) 2019 xjimi. All rights reserved.
//

#import "XJViewController.h"
#import <XJScrollViewStateManager/XJScrollViewStateManager.h>

@interface XJViewController ()

@property (nonatomic, strong) XJScrollViewStateManager *scrollViewStateManager;

@end

@implementation XJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollViewStateManager = [XJScrollViewStateManager managerWithScrollView:nil];
    [self.scrollViewStateManager addNetworkStatusChangeBlock:^(NetworkStatus netStatus) {
        
    }];

    [self.scrollViewStateManager addPullToRefreshWithActionHandler:^{

    }];

    
}


@end
