//
//  XJScrollViewStateManager.h
//  Vidol
//
//  Created by XJIMI on 2015/10/7.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "XJNetworkStatusMonitor.h"
#import "XJMessageBar.h"

typedef enum : NSUInteger {
    XJScrollViewState_Init,
    XJScrollViewState_Loading,
    XJScrollViewState_EmptyData,
    XJScrollViewState_NetworkError,
    
    XJScrollViewState_PullToRefresh_Finish,
    
    XJScrollViewState_LoadMore_Normal,
    XJScrollViewState_LoadMore_Loading,
    XJScrollViewState_LoadMore_Finish,
} XJScrollViewState;


typedef void (^XJScrollViewDidTapNetworkErrorViewBlock)(void);

@interface XJScrollViewStateManager : NSObject < DZNEmptyDataSetSource, DZNEmptyDataSetDelegate >

@property (nonatomic, assign) XJScrollViewState state;
@property (nonatomic, strong) XJMessageBar *messageBarTop;
@property (nonatomic, copy)   NSString *noContentInfo;
@property (nonatomic, assign) UIActivityIndicatorViewStyle pullToRefreshIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadMoreIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadingViewIndicatorStyle;
@property (nonatomic, strong) UIColor *emptyDataTextColor;

+ (instancetype)managerWithScrollView:(UIScrollView *)scrollView;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;
- (void)addLoadMoreWithActionHandler:(void (^)(void))actionHandler;
- (void)addDidTapNetworkErrorView:(XJScrollViewDidTapNetworkErrorViewBlock)didTapNetworkErrorViewBlock;
- (void)addNetworkStatusChangeBlock:(void (^)(NetworkStatus netStatus))block;

- (void)finishPullToRefresh;

- (void)finishLoadMore;
- (void)disableLoadMore;

- (void)showLoading;
- (void)showLoadMore;
- (void)showEmptyData;
- (void)showNetworkError;
- (void)showLoadMoreError;

- (void)disableMessageBarTop;

- (BOOL)ifNeedRefreshData;

- (BOOL)isEmptyData;

@end
