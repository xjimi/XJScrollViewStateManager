//
//  XJScrollViewStateManager.m
//  Vidol
//
//  Created by XJIMI on 2015/10/7.
//  Copyright © 2015年 XJIMI. All rights reserved.
//

#import "XJScrollViewStateManager.h"
#import "SVPullToRefresh.h"

@interface XJScrollViewStateManager ()

@property (nonatomic, weak) UIScrollView *baseScrollView;

@property (nonatomic, copy) void (^pullToRefreshHandler)(void);
@property (nonatomic, copy) void (^loadMoreHandler)(void);

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) Reachability *internetConnectionReach;
@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;
@property (nonatomic, copy) void (^networkStatusChangeBlock)(NetworkStatus status);
@property (nonatomic, copy)   XJScrollViewDidTapNetworkErrorViewBlock didTapNetworkErrorViewBlock;

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
    self.state = XJScrollViewState_Init;
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

- (void)addNetworkStatusChangeBlock:(void (^)(NetworkStatus netStatus))block
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
                weakSelf.baseScrollView.infiniteScrollingView.needDragToLoadMore = NO;
            }
            else
            {
                if (weakSelf.state == XJScrollViewState_NetworkError)
                {
                    weakSelf.state = XJScrollViewState_Init;
                    [weakSelf.baseScrollView reloadEmptyDataSet];
                }
            }
        }
        
        //NSLog(@"call back state : ---------- %ld", (unsigned long)weakSelf.state);
        if (block) block(status);

    }];
}

- (void)setState:(XJScrollViewState)state
{
    //[self stringState:state];
    _state = state;
}

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler
{
    if (self.baseScrollView.pullToRefreshView) return;
    self.pullToRefreshHandler = actionHandler;
    
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
            [weakSelf showLoading];
            if (weakSelf.pullToRefreshHandler) weakSelf.pullToRefreshHandler();
        }
        
    }];
    
    self.baseScrollView.showsPullToRefresh = YES;
    
    [self.baseScrollView.pullToRefreshView setActivityIndicatorViewStyle:_pullToRefreshIndicatorStyle];
    [self.baseScrollView.pullToRefreshView setTitle:nil forState:SVPullToRefreshStateAll];
    [self.baseScrollView.pullToRefreshView setSubtitle:nil forState:SVPullToRefreshStateAll];
}

- (void)addLoadMoreWithActionHandler:(void (^)(void))actionHandler
{
    if (self.baseScrollView.infiniteScrollingView) return;
    self.loadMoreHandler = actionHandler;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self)weakSelf = self;
        [self.baseScrollView addInfiniteScrollingWithActionHandler:^{
            
            if ([weakSelf isLoadingData])
            {
                [weakSelf.baseScrollView.infiniteScrollingView stopAnimating];
                [weakSelf.baseScrollView.infiniteScrollingView showIndicatorView];
                [weakSelf.messageBarTop showMessage:@"資料讀取中...請稍候" autoDismiss:YES];
            }
            else
            {
                weakSelf.state = XJScrollViewState_LoadMore_Loading;
                [weakSelf.messageBarTop hide];
                if (weakSelf.loadMoreHandler) weakSelf.loadMoreHandler();
            }
            
        }];

        [self.baseScrollView.infiniteScrollingView setActivityIndicatorViewStyle:self.loadMoreIndicatorStyle];

    });
}

- (void)finishPullToRefresh {
    [self finishPullToRefreshWithState:XJScrollViewState_PullToRefresh_Finish];
}

- (void)showLoading {
    self.state = XJScrollViewState_Loading;
    [self.baseScrollView reloadEmptyDataSet];
}

- (void)finishLoadMore {
    [self finishLoadMoreWithState:XJScrollViewState_LoadMore_Finish];
}

- (void)showLoadMore {
    [self finishLoadMoreWithState:XJScrollViewState_LoadMore_Normal];
}

- (void)showEmptyData {
    [self finishPullToRefreshWithState:XJScrollViewState_EmptyData];
}

- (void)showNetworkError
{
    [self finishPullToRefreshWithState:XJScrollViewState_NetworkError];
    if (![self isEmptyData])
    {
        [self.messageBarTop showMessage:@"#LInfo_NetworkError"];
    }
}

- (void)showLoadMoreError
{
    [self.messageBarTop showMessage:@"#LInfo_NetworkError"];
    self.baseScrollView.infiniteScrollingView.needDragToLoadMore = YES;
    [self finishLoadMoreWithState:XJScrollViewState_NetworkError];
    [self.baseScrollView.infiniteScrollingView showIndicatorView];
}

- (void)finishPullToRefreshWithState:(XJScrollViewState)state
{
    self.state = state;
    [self.baseScrollView.pullToRefreshView stopAnimating];
    [self.baseScrollView reloadEmptyDataSet];
}

- (void)finishLoadMoreWithState:(XJScrollViewState)state
{
    if (!self.baseScrollView.infiniteScrollingView) return;
    self.state = state;
    
    [self.baseScrollView.infiniteScrollingView stopAnimating];

    NSLog(@":: %@",     [self stringState:state]);
    
    if (self.state == XJScrollViewState_LoadMore_Finish)
    {
        self.baseScrollView.showsInfiniteScrolling = NO;
    }
    else
    {
        [self disableLoadMore];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.baseScrollView.showsInfiniteScrolling = YES;
        });

    }
}

- (void)addDidTapNetworkErrorView:(XJScrollViewDidTapNetworkErrorViewBlock)didTapNetworkErrorViewBlock
{
    self.didTapNetworkErrorViewBlock = didTapNetworkErrorViewBlock;
}

- (void)disableMessageBarTop {
    self.messageBarTop.hidden = YES;
}

- (void)disableLoadMore
{
    if (self.baseScrollView.showsInfiniteScrolling)
        [self.baseScrollView.infiniteScrollingView disableInfiniteScrolling];
}

- (void)enableLoadMore
{
    if (self.baseScrollView.showsInfiniteScrolling)
        self.baseScrollView.showsInfiniteScrolling = YES;
}

- (void)triggerInfiniteScrolling {
    [self.baseScrollView triggerInfiniteScrolling];
}

- (BOOL)ifNeedRefreshData
{
    return ([self isEmptyData] && ![self isLoadingData]);
}

- (BOOL)isLoadingData
{
    return (self.state == XJScrollViewState_Loading ||
            self.state == XJScrollViewState_LoadMore_Loading);
}

#pragma mark - DZNEmptyDataSet delegate

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewState_Init || [self isLoadingData])
    {
        return self.loadingView;
    }
    return nil;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewState_NetworkError)
    {
        return [UIImage imageNamed:@"ic_networkError_dark"];
    }
    
    return nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewState_NetworkError)
    {
        return [self attributedStringWithString:@"#LInfo_NetworkError"];
    }
    else if (self.state == XJScrollViewState_EmptyData)
    {
        return [self attributedStringWithString:self.noContentInfo];
    }
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.state == XJScrollViewState_NetworkError)
    {
        //return [self mutableAttributedStringWithString:LInfo_NetworkError];
    }
    return nil;
}


- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if (self.state == XJScrollViewState_NetworkError)
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

- (void)setLoadingViewIndicatorStyle:(UIActivityIndicatorViewStyle)loadingViewIndicatorStyle
{
    UIActivityIndicatorView *activityView = [self.loadingView viewWithTag:101];
    activityView.activityIndicatorViewStyle = loadingViewIndicatorStyle;
}

- (BOOL)isEmptyData
{
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
        case XJScrollViewState_Init:
            stateString = @"Init";
            break;

        case XJScrollViewState_Loading:
            stateString = @"Loading";
            break;

        case XJScrollViewState_EmptyData:
            stateString = @"Empty data";
            break;

        case XJScrollViewState_NetworkError:
            stateString = @"Network Error";
            break;

        case XJScrollViewState_PullToRefresh_Finish:
            stateString = @"PullToRefresh Finish";
            break;

        case XJScrollViewState_LoadMore_Normal:
            stateString = @"LoadMore Normal";
            break;

        case XJScrollViewState_LoadMore_Loading:
            stateString = @"LoadMore Loading";
            break;

        case XJScrollViewState_LoadMore_Finish:
            stateString = @"LoadMore Finish";
            break;
    }

    return stateString;
}

@end
