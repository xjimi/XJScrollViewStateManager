//
//  UIScrollView+XJEmptyDataSet.m
//  XJScrollViewStateManager
//
//  Created by apple on 2020/4/24.
//

#import "UIScrollView+XJEmptyDataSet.h"
#import <objc/runtime.h>

static char const * const kXJEmptyDataSetConfig = "kXJEmptyDataSetConfig";
static char const * const kXJEmptyDataSetBlock = "kXJEmptyDataSetBlock";


@interface UIScrollView (XJEmptyDataSetConfig)

@property (nonatomic, strong) XJEmptyDataSetConfig *config;

@property (nonatomic, copy, nullable) void(^emptyDataSetBlock)(XJEmptyDataSetConfig *);


@end

@implementation UIScrollView (XJEmptyDataSetConfig)

- (void)emptyDataSetConfigBlock:(void (^)(XJEmptyDataSetConfig *config))configBlock
{
    XJEmptyDataSetConfig *config = [[XJEmptyDataSetConfig alloc] init];
    self.config = config;
    self.emptyDataSetBlock = configBlock;
    self.emptyDataSetSource = self.config;
    self.emptyDataSetDelegate = self.config;
    
    __weak typeof(self)weakSelf = self;
    self.config.emptyViewWillAppear = ^{
        weakSelf.config.props = nil;
        weakSelf.emptyDataSetBlock(weakSelf.config);
    };
}

- (void)emptyDataSetConfig:(XJEmptyDataSetConfig *)config
{
    self.config = config ? : [[XJEmptyDataSetConfig alloc] init];
    self.emptyDataSetSource = self.config;
    self.emptyDataSetDelegate = self.config;
}

- (XJEmptyDataSetConfig *)config
{
    XJEmptyDataSetConfig *config = objc_getAssociatedObject(self, kXJEmptyDataSetConfig);
    if ([config isKindOfClass:[XJEmptyDataSetConfig class]] && config) {
        return config;
    }
    return nil;
}

- (void)setConfig:(XJEmptyDataSetConfig *)config {
    objc_setAssociatedObject(self, kXJEmptyDataSetConfig, config, OBJC_ASSOCIATION_RETAIN);
}

- (void)setEmptyDataSetBlock:(void (^)(XJEmptyDataSetConfig *))emptyDataSetBlock {
    objc_setAssociatedObject(self, kXJEmptyDataSetBlock, emptyDataSetBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(XJEmptyDataSetConfig *))emptyDataSetBlock {
    return objc_getAssociatedObject(self, kXJEmptyDataSetBlock);
}

@end

