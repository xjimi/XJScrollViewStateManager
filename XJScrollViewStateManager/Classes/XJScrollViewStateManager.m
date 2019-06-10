//
//  XJScrollViewStateManager.m
//  Vidol
//
//  Created by XJIMI on 2015/10/7.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJScrollViewStateManager.h"
#import "SVPullToRefresh.h"
#import "XJMessageBar.h"

@interface XJScrollViewStateManager ()

@property (nonatomic, weak) UIScrollView *baseScrollView;
@property (nonatomic, assign) XJScrollViewState state;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) Reachability *internetConnectionReach;
@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;
@property (nonatomic, copy) XJScrollViewDidTapNetworkErrorViewBlock didTapNetworkErrorViewBlock;
@property (nonatomic, strong) XJMessageBar *messageBarTop;

@property (nonatomic, copy) void (^pullToRefreshHandler)(void);
@property (nonatomic, copy) void (^loadMoreHandler)(void);
@property (nonatomic, copy) void (^networkStatusChangeBlock)(NetworkStatus status);

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
        self.baseScrollView.emptyDataSetSource = self;
        self.baseScrollView.emptyDataSetDelegate = self;
        [self.baseScrollView reloadEmptyDataSet];
    }
    return self;
}

- (void)setup
{
    self.state = XJScrollViewStateNone;
    self.emptyDataTextColor = [UIColor darkGrayColor];
    self.noContentInfo = @"#LInfo_NoContentYet";

    /*
     ref:http://mywayonobjectivec.blogspot.tw/2016/05/uiscrollview.html
     如果你想讓你的scrollView以點擊事件為主：
     yourScrollView.delaysContentTouches = NO
     如果你想讓你的scrollView以滑動事件為主：
     yourScrollView.delaysContentTouches = YES
     */
    self.baseScrollView.delaysContentTouches = YES;
    self.pullToRefreshIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.loadMoreIndicatorStyle = UIActivityIndicatorViewStyleGray;
}

- (void)setPullToRefreshIndicatorStyle:(UIActivityIndicatorViewStyle)pullToRefreshIndicatorStyle {
    _pullToRefreshIndicatorStyle = pullToRefreshIndicatorStyle;
    [self.baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:_pullToRefreshIndicatorStyle];
}

- (void)setLoadMoreIndicatorStyle:(UIActivityIndicatorViewStyle)loadMoreIndicatorStyle {
    _loadMoreIndicatorStyle = loadMoreIndicatorStyle;
    [self.baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:_loadMoreIndicatorStyle];
}

- (XJMessageBar *)messageBarTop
{
    if (!_messageBarTop)
    {
        _messageBarTop = [XJMessageBar messageBarType:XJMessageBarTypeTop dismissWhenTouch:NO showInView:self.baseScrollView.superview];
        _messageBarTop.verticalPadding = 10.0f;
        _messageBarTop.bgColor = [UIColor colorWithRed:0.7961 green:0.0431 blue:0.0902 alpha:1.0000];
    }

    return _messageBarTop;
}

- (void)setEmptyDataVerticalOffset:(CGFloat)emptyDataVerticalOffset
{
    _emptyDataVerticalOffset = emptyDataVerticalOffset;
    self.messageBarTop.startPosY = emptyDataVerticalOffset;
}

- (void)addNetworkStatusChangeBlock:(void (^ _Nonnull)(NetworkStatus netStatus))block
{
    if (self.networkStatusMonitor) return;
    __weak typeof(self)weakSelf = self;
    self.networkStatusMonitor = [XJNetworkStatusMonitor monitorWithNetworkStatusChange:^(NetworkStatus status) {

        if (status == NotReachable)
        {
            [weakSelf showNetworkError];
        }
        else
        {
            if (![weakSelf isEmptyData])
            {
                [weakSelf.messageBarTop hide];
            }
            else
            {
                if (weakSelf.state == XJScrollViewStateNetworkError)
                {
                    weakSelf.state = XJScrollViewStateNone;
                    [weakSelf.baseScrollView reloadEmptyDataSet];
                }
            }
        }

        if (block) block(status);

    }];
}

- (void)addPullToRefreshWithActionHandler:(void (^ __nonnull)(void))actionHandler
{
    if (self.baseScrollView.pullToRefreshView) return;
    self.pullToRefreshHandler = actionHandler;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        __weak typeof(self) weakSelf = self;
        [self.baseScrollView addPullToRefreshWithActionHandler:^{

            if ([weakSelf isLoadingData])
            {
                [weakSelf.baseScrollView.pullToRefreshView stopAnimating];
                [weakSelf.messageBarTop showMessage:@"#LInfo_DataLoading" autoDismiss:YES];
            }
            else
            {
                [weakSelf.messageBarTop hide];
                weakSelf.state = XJScrollViewStatePullToRefreshLoading;
                if (weakSelf.pullToRefreshHandler) weakSelf.pullToRefreshHandler();
            }

        }];

        self.baseScrollView.showsPullToRefresh = YES;
        [self.baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:self.pullToRefreshIndicatorStyle];
        [self.baseScrollView.pullToRefreshView setTitle:nil forState:SVPullToRefreshStateAll];
        [self.baseScrollView.pullToRefreshView setSubtitle:nil forState:SVPullToRefreshStateAll];

    });
}

- (void)addLoadMoreWithActionHandler:(void (^ _Nonnull)(void))actionHandler
{
    if (self.baseScrollView.infiniteScrollingView) return;
    self.loadMoreHandler = actionHandler;
    dispatch_async(dispatch_get_main_queue(), ^{

        __weak typeof(self)weakSelf = self;
        [self.baseScrollView addInfiniteScrollingWithActionHandler:^{

            if ([weakSelf isLoadingData])
            {
                weakSelf.baseScrollView.showsInfiniteScrolling = NO;
                [weakSelf.messageBarTop showMessage:@"#資料讀取中...請稍候" autoDismiss:NO];
            }
            else
            {
                weakSelf.state = XJScrollViewStateLoadMoreLoading;
                [weakSelf.messageBarTop hide];
                if (weakSelf.loadMoreHandler) weakSelf.loadMoreHandler();
            }

        }];

        [self.baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:self.loadMoreIndicatorStyle];

    });
}

- (void)finishPullToRefresh {
    [self finishPullToRefreshWithState:XJScrollViewStatePullToRefreshFinish];
}

- (void)showLoading
{
    self.state = XJScrollViewStateLoading;
    [self.baseScrollView reloadEmptyDataSet];
}

- (void)finishLoadMore {
    [self finishLoadMoreWithState:XJScrollViewStateLoadMoreFinish];
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
    if (![self isEmptyData]) {
        [self.messageBarTop showMessage:@"#LInfo_NetworkError"];
    }
}

- (void)showLoadMoreError
{
    [self.messageBarTop showMessage:@"#LInfo_NetworkError"];
    self.baseScrollView.infiniteScrollingView.needDragToLoadMore = YES;
    [self finishLoadMoreWithState:XJScrollViewStateNetworkError];
    [self.baseScrollView.infiniteScrollingView showIndicatorView];
}

- (void)finishPullToRefreshWithState:(XJScrollViewState)state
{
    self.state = state;
    [self.messageBarTop hide];
    [self.baseScrollView.pullToRefreshView stopAnimating];
    [self.baseScrollView reloadEmptyDataSet];
    if (self.baseScrollView.infiniteScrollingView) {
        self.baseScrollView.showsInfiniteScrolling = YES;
    }
}

- (void)finishLoadMoreWithState:(XJScrollViewState)state
{
    if (!self.baseScrollView.infiniteScrollingView) return;
    self.state = state;
    [self.messageBarTop hide];
    [self.baseScrollView.infiniteScrollingView stopAnimating];
    if (self.state == XJScrollViewStateLoadMoreFinish) {
        self.baseScrollView.showsInfiniteScrolling = NO;
    }
}

- (void)addDidTapNetworkErrorView:(XJScrollViewDidTapNetworkErrorViewBlock)didTapNetworkErrorViewBlock {
    self.didTapNetworkErrorViewBlock = didTapNetworkErrorViewBlock;
}

- (void)disableMessageBarTop {
    self.messageBarTop.hidden = YES;
}

- (void)triggerInfiniteScrolling {
    [self.baseScrollView triggerInfiniteScrolling];
}

- (BOOL)ifNeedRefreshData {
    return ([self isEmptyData] && ![self isLoadingData]);
}

- (BOOL)isLoadingData
{
    return (self.state == XJScrollViewStateLoading ||
            self.state == XJScrollViewStatePullToRefreshLoading ||
            self.state == XJScrollViewStateLoadMoreLoading);
}

#pragma mark - DZNEmptyDataSet delegate

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return self.emptyDataVerticalOffset;
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewStateNone || [self isLoadingData]) {
        return self.loadingView;
    }
    return nil;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewStateNetworkError) {
        return [UIImage imageNamed:@"ic_networkError_dark"];
    }

    return nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewStateNetworkError) {
        return [self attributedStringWithString:@"#LInfo_NetworkError"];
    }
    else if (self.state == XJScrollViewStateEmptyData) {
        return [self attributedStringWithString:self.noContentInfo];
    }
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewStateNetworkError) {
        //return [self mutableAttributedStringWithString:LInfo_NetworkError];
    }
    return nil;
}


- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if (self.state == XJScrollViewStateNetworkError)
    {
        [self showLoading];
        if (self.didTapNetworkErrorViewBlock) self.didTapNetworkErrorViewBlock();
    }
}

#pragma mark - loadingView and NSAttributedString

- (NSAttributedString *)attributedStringWithString:(NSString *)string
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;

    NSMutableDictionary *attributes = [NSMutableDictionary new];
    text = string;
    font = [UIFont systemFontOfSize:16];
    textColor = self.emptyDataTextColor;

    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];

    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSMutableAttributedString *)mutableAttributedStringWithString:(NSString *)string
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;

    NSMutableDictionary *attributes = [NSMutableDictionary new];

    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;

    text = string;
    font =  [UIFont systemFontOfSize:14];
    textColor = self.emptyDataTextColor;

    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
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

- (void)reloadEmptyDataSet {
    [self.baseScrollView reloadEmptyDataSet];
}

- (void)setLoadingViewIndicatorStyle:(UIActivityIndicatorViewStyle)loadingViewIndicatorStyle
{
    UIActivityIndicatorView *activityView = [self.loadingView viewWithTag:101];
    activityView.activityIndicatorViewStyle = loadingViewIndicatorStyle;
}

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

        case XJScrollViewStatePullToRefreshFinish:
            stateString = @"PullToRefresh Finish";
            break;

        case XJScrollViewStateLoadMoreNormal:
            stateString = @"LoadMore Normal";
            break;

        case XJScrollViewStateLoadMoreLoading:
            stateString = @"LoadMore Loading";
            break;

        case XJScrollViewStateLoadMoreFinish:
            stateString = @"LoadMore Finish";
            break;
    }

    return stateString;
}

@end
