//
//  XJScrollViewStateManager.h
//  Vidol
//
//  Created by XJIMI on 2015/10/7.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIScrollView+XJEmptyDataSet.h"
#import "XJMessageBar.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XJScrollViewState)
{
    XJScrollViewStateNone = 0,
    XJScrollViewStateLoading = 1,
    XJScrollViewStateEmptyData = 2,
    XJScrollViewStateNetworkError,
    XJScrollViewStatePullToRefreshLoading,
    XJScrollViewStatePullToRefreshFinished,
    XJScrollViewStateLoadMoreNormal,
    XJScrollViewStateLoadMoreLoading,
    XJScrollViewStateLoadMoreFinished
};

@interface XJScrollViewStateManager : NSObject

@property (nonatomic, assign, readonly) XJScrollViewState state;

@property (nonatomic, assign) UIActivityIndicatorViewStyle pullToRefreshIndicatorStyle;

@property (nonatomic, assign) UIActivityIndicatorViewStyle loadMoreIndicatorStyle;

@property (nonatomic, assign) UIActivityIndicatorViewStyle loadingViewIndicatorStyle;

@property (nonatomic, strong) XJMessageBar *messageBar;

/** 檢查 DataSource 的資料是否為空 **/
@property (nonatomic, assign, readonly) BOOL isEmptyData;

/** 檢查是否需要更新資料 **/
@property (nonatomic, assign, readonly) BOOL ifNeededRefreshData;


+ (instancetype)managerWithScrollView:(UIScrollView *)scrollView;

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

/** 關閉上方提示訊息 **/
- (void)disableMessageBar;

#pragma mark - Blocks

/** 修改 DZNEmptyDataSet 屬性 **/
- (void)emptyDataSetConfigBlock:(void (^)(XJEmptyDataSetConfig *config))configBlock;

/** 監聽是否觸發 - 下拉重整 **/
- (void)pullToRefreshBlock:(void (^)(void))block;

/** 監聽是否觸發 - Load More **/
- (void)loadMoreBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
