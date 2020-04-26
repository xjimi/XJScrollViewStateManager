//
//  XJEmptyDataSetConfig.h
//  XJScrollViewStateManager
//
//  Created by apple on 2020/4/24.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "XJEmptyDataSetProperty.h"

NS_ASSUME_NONNULL_BEGIN

@interface XJEmptyDataSetConfig : NSObject <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong, nullable) XJEmptyDataSetProperty *props;

/**
 是否要顯示空白頁 : default YES
 */
@property (nonatomic, copy, nullable) BOOL(^shouldDisplay)(void);

@property (nonatomic, copy, nullable) void(^emptyViewTapBlock)(UIView *);

@property (nonatomic, copy, nullable) void(^emptyBtnTapBlock)(UIButton *);

/**
 圖片是否執行動畫 : default YES
 */
@property (nonatomic, copy, nullable) BOOL(^shouldStartImageViewAnimate)(void);

/**
 圖片動畫
 Note: shouldStartAnimate == NO || imageAnimation == nil || emptyImage == nil 其中1個成立就不執行動畫
 */
@property (nonatomic, strong) CAAnimation *imageAnimation;


#pragma mark - life cycle

@property (nonatomic, copy, nullable) void(^emptyViewWillAppear)(void);

@property (nonatomic, copy, nullable) void(^emptyViewWillDisappear)(void);

@property (nonatomic, copy, nullable) void(^emptyViewDidAppear)(void);

@property (nonatomic, copy, nullable) void(^emptyViewDidDisappear)(void);

@end

NS_ASSUME_NONNULL_END
