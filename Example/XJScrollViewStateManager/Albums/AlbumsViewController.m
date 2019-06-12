//
//  AlbumsViewController.m
//  Demo
//
//  Created by XJIMI on 2019/6/4.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "AlbumsViewController.h"
#import "AlbumModel.h"
#import "AlbumCell.h"
#import "AlbumHeader.h"
#import <Masonry/Masonry.h>
#import <XJTableViewManager/XJTableViewManager.h>
#import <XJScrollViewStateManager/XJScrollViewStateManager.h>

@interface AlbumsViewController () < XJTableViewDelegate, XJScrollViewStateDelegate >

@property (nonatomic, strong) XJTableViewManager *tableView;

@property (nonatomic, strong) XJScrollViewStateManager *scrollViewState;

@property (nonatomic, assign) NSInteger retryCount;

@end

@implementation AlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createTableView];
    [self createScrollViewState];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollViewState reloadEmptyDataSet];
}

#pragma mark - Create XJScrollViewState

- (void)createScrollViewState
{
    self.scrollViewState = [XJScrollViewStateManager managerWithScrollView:self.tableView];
    self.scrollViewState.delegate = self;
    self.scrollViewState.emptyDataVerticalOffset = -64;
    __weak typeof(self)weakSelf = self;
    [self.scrollViewState addNetworkStatusChangeBlock:^(NetworkStatus netStatus) {

        if (netStatus != NotReachable) {
            [weakSelf refreshData];
        } else {
            [weakSelf.scrollViewState showNetworkError];
        }

    }];

    [self.scrollViewState addDidTapNetworkErrorView:^{
        [weakSelf callAPIRefresh];
    }];
}

#pragma mark - Create XJTableView and dataModel

- (void)refreshData
{
    self.retryCount = 0;
    [self.scrollViewState finishPullToRefresh];
    self.tableView.data = @[[self createDataModel]].mutableCopy;

    __weak typeof(self)weakSelf = self;
    [self.scrollViewState addPullToRefreshWithActionHandler:^{
        [weakSelf callAPIRefresh];
    }];

    [self.scrollViewState addLoadMoreWithActionHandler:^{
        [weakSelf loadMoreData];
    }];
}

- (void)loadMoreData
{
    NSLog(@"loadMoreData ---- ");
    self.retryCount ++;
    if (self.retryCount % 3)
    {
        __weak typeof(self)weakSelf = self;
        [self callAPILoadMoreWithCompletion:^{

            if (weakSelf.retryCount > 6)
            { 
                weakSelf.retryCount = 0;
                [weakSelf.scrollViewState finishLoadMore];
                return;
            }

            [weakSelf.scrollViewState showLoadMore];
        }];
    }
    else
    {
        [self.scrollViewState showLoadMoreError];
    }
}

#pragma mark - Call API

- (void)callAPIRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshData];
    });
}

- (void)callAPILoadMoreWithCompletion:(void (^ __nullable)())completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self appendDataModel];
        if (completion) completion();
    });
}

#pragma mark - Create dataModel

- (XJTableViewDataModel *)createDataModel
{
    XJTableViewDataModel *dataModel = [XJTableViewDataModel
                                       modelWithSection:nil
                                       rows:[self createRows]];
    return dataModel;
}

- (XJTableViewHeaderModel *)createSection
{
    NSString *setion = [NSString stringWithFormat:@"New Album %ld", (long)self.tableView.data.count];
    XJTableViewHeaderModel *headerModel = [XJTableViewHeaderModel
                                           modelWithReuseIdentifier:[AlbumHeader identifier]
                                           headerHeight:50.0f
                                           data:setion];
    return headerModel;
}

- (NSMutableArray *)createRows
{
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < 15; i++)
    {
        AlbumModel *model = [[AlbumModel alloc] init];
        model.albumName = @"Scorpion (OVO Updated Version) [iTunes][2018]";
        model.artistName = @"Drake";
        model.imageName = @"drake";

        XJTableViewCellModel *cellModel = [XJTableViewCellModel
                                           modelWithReuseIdentifier:[AlbumCell identifier]
                                           cellHeight:80.0f
                                           data:model];
        [rows addObject:cellModel];
    }
    return rows;
}

- (void)createTableView
{
    XJTableViewManager *tableView = [XJTableViewManager managerWithStyle:UITableViewStyleGrouped];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.tableViewDelegate = self;
    [tableView disableGroupHeaderHeight];
    [tableView disableGroupFooterHeight];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }

    self.tableView = tableView;
}

#pragma mark - Append or insert dataModel

- (void)appendRows
{
    XJTableViewHeaderModel *section = nil;
    XJTableViewDataModel *newDataModel = [XJTableViewDataModel
                                          modelWithSection:section
                                          rows:[self createRows]];
    [self.tableView appendRowsWithDataModel:newDataModel];
}

- (IBAction)appendDataModel
{
    XJTableViewDataModel *newDataModel = [XJTableViewDataModel
                                          modelWithSection:[self createSection]
                                          rows:[self createRows]];
    [self.tableView appendDataModel:newDataModel];
}

- (IBAction)insertSectionData
{
    XJTableViewDataModel *dataModel = [self createDataModel];
    [self.tableView insertDataModel:dataModel atSectionIndex:self.tableView.data.count];
}

#pragma mark - XJTableView delegate

- (void)xj_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
}

@end
