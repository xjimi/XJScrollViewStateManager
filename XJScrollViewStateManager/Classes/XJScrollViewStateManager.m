//
//  XJScrollViewStateManager.m
//  Vidol
//
//  Created by XJIMI on 2015/10/7.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJScrollViewStateManager.h"
#import "XJScrollViewStateBundleResource.h"
#import "SVPullToRefresh.h"

@interface XJScrollViewStateManager ()

@property (nonatomic, weak) UIScrollView *baseScrollView;

@property (nonatomic, assign) XJScrollViewState state;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, copy, nullable) void(^emptyDataSetBlock)(XJEmptyDataSetConfig *);

@property (nonatomic, copy) void (^pullToRefreshBlock)(void);

@property (nonatomic, copy) void (^loadMoreBlock)(void);

@end

@implementation XJScrollViewStateManager

+ (instancetype)managerWithScrollView:(UIScrollView *)scrollView {
    return [[self alloc] initWithScrollView:scrollView];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    if (self)
    {
        self.baseScrollView = scrollView;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.state = XJScrollViewStateNone;
    self.baseScrollView.delaysContentTouches = YES;
    self.pullToRefreshIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.loadMoreIndicatorStyle = UIActivityIndicatorViewStyleGray;
    
    __weak typeof(self)weakSelf = self;
    [self.baseScrollView emptyDataSetConfigBlock:^(XJEmptyDataSetConfig * _Nonnull config) {

        if (weakSelf.state == XJScrollViewStateNetworkError)
        {
            NSString *networkError = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LNetworkError"];
            config.props.emptyImage = [XJScrollViewStateBundleResource imageNamed:@"ic_reload_dark"];
            config.props.emptyTitle = networkError;
        }
        else if (weakSelf.state == XJScrollViewStateEmptyData)
        {
            NSString *noContent = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LNoContentYet"];
            config.props.emptyTitle = noContent;
        }
        else if (weakSelf.state == XJScrollViewStateLoading)
        {
            config.props.customView = weakSelf.loadingView;
        }
        
        !weakSelf.emptyDataSetBlock ? :weakSelf.emptyDataSetBlock(config);

    }];
    /*
    XJEmptyDataSetConfig *config = [[XJEmptyDataSetConfig alloc] init];
    NSString *networkError = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LNetworkError"];
    config.props.emptyTitle = networkError;
    config.props.emptyImage = [XJScrollViewStateBundleResource imageNamed:@"ic_reload_dark"];
    [self.baseScrollView emptyDataSetConfig:config];
    */
}

#pragma mark - Blocks

- (void)emptyDataSetConfigBlock:(void (^)(XJEmptyDataSetConfig *config))configBlock {
    self.emptyDataSetBlock = configBlock;
}

- (void)pullToRefreshBlock:(void (^)(void))block
{
    if (self.baseScrollView.pullToRefreshView) return;
    self.pullToRefreshBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        __weak typeof(self) weakSelf = self;
        [self.baseScrollView addPullToRefreshWithActionHandler:^{

            if (weakSelf.isLoadingData)
            {
                [weakSelf.baseScrollView.pullToRefreshView stopAnimating];
                NSString *message = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LLoading"];
                [weakSelf.messageBar showMessage:message autoDismiss:YES];
            }
            else
            {
                [weakSelf.messageBar hide];
                weakSelf.state = XJScrollViewStatePullToRefreshLoading;
                !weakSelf.pullToRefreshBlock ? : weakSelf.pullToRefreshBlock();
            }

        }];

        self.baseScrollView.showsPullToRefresh = YES;
        [self.baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:self.pullToRefreshIndicatorStyle];
        [self.baseScrollView.pullToRefreshView setTitle:nil forState:SVPullToRefreshStateAll];
        [self.baseScrollView.pullToRefreshView setSubtitle:nil forState:SVPullToRefreshStateAll];

    });
}

- (void)loadMoreBlock:(void (^)(void))block
{
    if (self.baseScrollView.infiniteScrollingView) return;
    self.loadMoreBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        __weak typeof(self)weakSelf = self;
        [self.baseScrollView addInfiniteScrollingWithActionHandler:^{

            if (weakSelf.isLoadingData)
            {
                weakSelf.baseScrollView.showsInfiniteScrolling = NO;
                NSString *message = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LLoading"];
                [weakSelf.messageBar showMessage:message autoDismiss:NO];
            }
            else
            {
                weakSelf.state = XJScrollViewStateLoadMoreLoading;
                [weakSelf.messageBar hide];
                !weakSelf.loadMoreBlock ? : weakSelf.loadMoreBlock();
            }

        }];

        [self.baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:self.loadMoreIndicatorStyle];

    });
}

- (void)finishPullToRefresh {
    [self finishPullToRefreshWithState:XJScrollViewStatePullToRefreshFinished];
}

- (void)showLoading
{
    self.state = XJScrollViewStateLoading;
    [self.baseScrollView reloadEmptyDataSet];
}

- (void)finishLoadMore {
    [self finishLoadMoreWithState:XJScrollViewStateLoadMoreFinished];
}

- (void)showLoadMore
{
    self.baseScrollView.infiniteScrollingView.needDragToLoadMore = NO;
    [self finishLoadMoreWithState:XJScrollViewStateLoadMoreNormal];
}

- (void)showEmptyData {
    [self finishPullToRefreshWithState:XJScrollViewStateEmptyData];
}

- (void)showNetworkError
{
    [self finishPullToRefreshWithState:XJScrollViewStateNetworkError];
    if (!self.isEmptyData)
    {
        NSString *message = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LNetworkError"];
        [self.messageBar showMessage:message];
    }
}

- (void)showLoadMoreError
{
    NSString *message = [XJScrollViewStateBundleResource LocalizedStringWithKey:@"LNetworkError"];
    [self.messageBar showMessage:message];
    self.baseScrollView.infiniteScrollingView.needDragToLoadMore = YES;
    [self finishLoadMoreWithState:XJScrollViewStateNetworkError];
    [self.baseScrollView.infiniteScrollingView showIndicatorView];
}

- (void)finishPullToRefreshWithState:(XJScrollViewState)state
{
    self.state = state;
    [self.messageBar hide];
    [self.baseScrollView.pullToRefreshView stopAnimating];
    
    [self.baseScrollView reloadEmptyDataSet];
    if (self.baseScrollView.infiniteScrollingView)
    {
        self.baseScrollView.showsInfiniteScrolling = YES;
        [self.baseScrollView.infiniteScrollingView stopAnimating];
    }
}

- (void)finishLoadMoreWithState:(XJScrollViewState)state
{
    if (!self.baseScrollView.infiniteScrollingView) return;
    self.state = state;
    [self.messageBar hide];
    [self.baseScrollView.infiniteScrollingView stopAnimating];
    if (self.state == XJScrollViewStateLoadMoreFinished) {
        self.baseScrollView.showsInfiniteScrolling = NO;
    }
}

- (void)disableMessageBar {
    self.messageBar.hidden = YES;
}

- (BOOL)ifNeededRefreshData {
    return (self.isEmptyData && !self.isLoadingData);
}

- (BOOL)isLoadingData
{
    return (self.state == XJScrollViewStateLoading ||
            self.state == XJScrollViewStatePullToRefreshLoading ||
            self.state == XJScrollViewStateLoadMoreLoading);
}

#pragma mark - loadingView and NSAttributedString

- (BOOL)isEmptyData {
    return ![XJScrollViewStateManager itemCountInScrollView:self.baseScrollView];
}

+ (NSInteger)itemCountInScrollView:(UIScrollView *)scrollView
{
    NSInteger items = 0;

    if (![scrollView respondsToSelector:@selector(dataSource)]) {
        return items;
    }

    if ([scrollView isKindOfClass:[UITableView class]])
    {
        id <UITableViewDataSource> dataSource = [scrollView performSelector:@selector(dataSource)];
        UITableView *tableView = (UITableView *)scrollView;

        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }

        for (NSInteger i = 0; i < sections; i++) {
            items += [dataSource tableView:tableView numberOfRowsInSection:i];
        }
    }
    else if ([scrollView isKindOfClass:[UICollectionView class]])
    {
        id <UICollectionViewDataSource> dataSource = [scrollView performSelector:@selector(dataSource)];
        UICollectionView *collectionView = (UICollectionView *)scrollView;

        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }

        for (NSInteger i = 0; i < sections; i++) {
            items += [dataSource collectionView:collectionView numberOfItemsInSection:i];
        }
    }

    return items;
}

#pragma mark - Set UI property

- (void)setPullToRefreshIndicatorStyle:(UIActivityIndicatorViewStyle)pullToRefreshIndicatorStyle
{
    _pullToRefreshIndicatorStyle = pullToRefreshIndicatorStyle;
    [self.baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:_pullToRefreshIndicatorStyle];
}

- (void)setLoadMoreIndicatorStyle:(UIActivityIndicatorViewStyle)loadMoreIndicatorStyle
{
    _loadMoreIndicatorStyle = loadMoreIndicatorStyle;
    [self.baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:_loadMoreIndicatorStyle];
}

- (void)setLoadingViewIndicatorStyle:(UIActivityIndicatorViewStyle)loadingViewIndicatorStyle {
    self.loadingView.activityIndicatorViewStyle = loadingViewIndicatorStyle;
}

- (XJMessageBar *)messageBar
{
    if (!_messageBar)
    {
        _messageBar = [XJMessageBar messageBarType:XJMessageBarTypeTop dismissWhenTouch:NO showInView:self.baseScrollView.superview];
        _messageBar.bgColor = [UIColor colorWithRed:0.7961 green:0.0431 blue:0.0902 alpha:1.0000];
    }

    return _messageBar;
}

- (UIView *)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView startAnimating];
    }
    return _loadingView;
}

- (NSString *)stringState:(XJScrollViewState)state
{
    NSString *stateString;
    switch (state)
    {
        case XJScrollViewStateNone:
            stateString = @"None";
            break;

        case XJScrollViewStateLoading:
            stateString = @"Loading";
            break;

        case XJScrollViewStateEmptyData:
            stateString = @"Empty Data";
            break;

        case XJScrollViewStateNetworkError:
            stateString = @"Network Error";
            break;

        case XJScrollViewStatePullToRefreshLoading:
            stateString = @"PullToRefresh Loading";
            break;

        case XJScrollViewStatePullToRefreshFinished:
            stateString = @"PullToRefresh Finished";
            break;

        case XJScrollViewStateLoadMoreNormal:
            stateString = @"LoadMore Normal";
            break;

        case XJScrollViewStateLoadMoreLoading:
            stateString = @"LoadMore Loading";
            break;

        case XJScrollViewStateLoadMoreFinished:
            stateString = @"LoadMore Finished";
            break;
    }

    return stateString;
}

@end
