//
//  UIScrollView+XJEmptyDataSet.h
//  XJScrollViewStateManager
//
//  Created by apple on 2020/4/24.
//

#import <UIKit/UIKit.h>
#import "XJEmptyDataSetConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (XJEmptyDataSet)

- (void)emptyDataSetConfigBlock:(void (^)(XJEmptyDataSetConfig *config))configBlock;

- (void)emptyDataSetConfig:(nullable XJEmptyDataSetConfig *)config;

@end

NS_ASSUME_NONNULL_END
