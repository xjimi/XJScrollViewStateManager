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

NS_ASSUME_NONNULL_BEGIN

@class XJScrollViewStateManager;

@protocol XJScrollViewStateDelegate <NSObject>

@optional

- (UIView *)customViewForEmptyDataState:(XJScrollViewStateManager *)scrollViewState;

- (UIImage *)imageForEmptyDataState:(XJScrollViewStateManager *)scrollViewState;
- (UIColor *)imageTintColorForEmptyDataState:(XJScrollViewStateManager *)scrollViewState;

- (NSAttributedString *)titleForEmptyDataState:(XJScrollViewStateManager *)scrollViewState;
- (NSAttributedString *)descriptionForEmptyDataState:(XJScrollViewStateManager *)scrollViewState;

@end

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

@property (nonatomic, weak) id <XJScrollViewStateDelegate> delegate;
@property (nonatomic, assign, readonly) XJScrollViewState state;
@property (nonatomic, assign) UIActivityIndicatorViewStyle pullToRefreshIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadMoreIndicatorStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle loadingViewIndicatorStyle;
@property (nonatomic, strong, nullable)  UIColor *emptyDataTextColor;
@property (nonatomic, assign)  CGFloat emptyDataVerticalOffset;

+ (instancetype)managerWithScrollView:(UIScrollView *)scrollView;

/** 監聽網路狀態是否改變 **/
- (void)addNetworkStatusChangeBlock:(void (^)(NetworkStatus netStatus))block;
- (void)addDidTapNetworkErrorView:(XJScrollViewDidTapNetworkErrorViewBlock)didTapNetworkErrorViewBlock;

/** 監聽是否觸發 - 下拉重整 **/
- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;

/** 監聽是否觸發 - Load More **/
- (void)addLoadMoreWithActionHandler:(void (^)(void))actionHandler;

/** 恢復下拉重整功能 **/
- (void)finishPullToRefresh;

/** 結束 Load More 功能 **/
- (void)finishLoadMore;

/** 還未載入資料時,scrollView 中央顯示的 Loading **/
- (void)showLoading;

/** 讀取資料完成時,需重置才能繼續讀取下一次資料 **/
- (void)showLoadMore;

/** 顯示無資料時的狀態 **/
- (void)showEmptyData;

/** 顯示網路連線錯誤 **/
- (void)showNetworkError;
- (void)showLoadMoreError;

/** 更新物件位置 **/
- (void)reloadEmptyDataSet;

/** 關閉上方的錯誤提示訊息 **/
- (void)disableMessageBarTop;

/** 檢查是否需要更新資料 **/
- (BOOL)ifNeedRefreshData;

/** 檢查 DataSource 的資料是否為空 **/
- (BOOL)isEmptyData;

@end

NS_ASSUME_NONNULL_END
