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

typedef NS_ENUM(NSUInteger, XJScrollViewState)
{
    XJScrollViewStateNone = 0,
    XJScrollViewStateLoading = 1,
    XJScrollViewStateEmptyData = 2,
    XJScrollViewStateNetworkError,
    XJScrollViewStatePullToRefreshLoading,
    XJScrollViewStatePullToRefreshFinish,
    XJScrollViewStateLoadMoreNormal,
    XJScrollViewStateLoadMoreLoading,
    XJScrollViewStateLoadMoreFinish
};

typedef void (^XJScrollViewDidTapNetworkErrorViewBlock)(void);

@interface XJScrollViewStateManager : NSObject < DZNEmptyDataSetSource, DZNEmptyDataSetDelegate >

@property (nonatomic, assign, readonly) XJScrollViewState state;
@property (nonatomic, assign) UIActivityIndicatorViewStyle pullToRefreshIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadMoreIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadingViewIndicatorStyle;
@property (nonatomic, strong) UIColor * _Nullable emptyDataTextColor;
@property (nonatomic, assign) CGFloat emptyDataVerticalOffset;
@property (nonatomic, copy) NSString * _Nullable noContentInfo;

+ (instancetype _Nullable )managerWithScrollView:(UIScrollView *_Nonnull)scrollView;

- (void)addNetworkStatusChangeBlock:(void (^ __nonnull)(NetworkStatus netStatus))block;
- (void)addDidTapNetworkErrorView:(XJScrollViewDidTapNetworkErrorViewBlock _Nullable )didTapNetworkErrorViewBlock;

- (void)addPullToRefreshWithActionHandler:(void (^ __nonnull)(void))actionHandler;
- (void)addLoadMoreWithActionHandler:(void (^ __nonnull)(void))actionHandler;
- (void)finishPullToRefresh;
- (void)finishLoadMore;

// 頁面初始化時，顯示的 Loading
- (void)showLoading;

// 增加資料時，請執行
- (void)showLoadMore;
- (void)showEmptyData;
- (void)showNetworkError;
- (void)showLoadMoreError;
- (void)reloadEmptyDataSet;

// 完全不顯示在上方的錯誤訊息
- (void)disableMessageBarTop;

- (BOOL)ifNeedRefreshData;
- (BOOL)isEmptyData;

@end
