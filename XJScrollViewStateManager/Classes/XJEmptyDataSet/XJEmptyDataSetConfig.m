//
//  XJEmptyDataSetConfig.m
//  XJScrollViewStateManager
//
//  Created by apple on 2020/4/24.
//

#import "XJEmptyDataSetConfig.h"

@interface XJEmptyDataSetConfig ()

@end

@implementation XJEmptyDataSetConfig

- (XJEmptyDataSetProperty *)props
{
    if (!_props) {
        _props = [[XJEmptyDataSetProperty alloc] init];
    }
    return _props;
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName:self.props.emptyTitleFont,
                                 NSForegroundColorAttributeName:self.props.emptyTitleColor};
    
    return [[NSAttributedString alloc] initWithString:self.props.emptyTitle ? : @""
                                           attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName:self.props.emptySubtitleFont,
                                 NSForegroundColorAttributeName:self.props.emptySubtitleColor,
                                 NSParagraphStyleAttributeName:paragraph};
    
    return [[NSAttributedString alloc] initWithString:self.props.emptySubtitle ? : @"" attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.props.emptyImage;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSDictionary *attributes = @{NSFontAttributeName:self.props.emptyBtnTitleFont,
                                 NSForegroundColorAttributeName:self.props.emptyBtnTitleColor};
    
    return [[NSAttributedString alloc] initWithString:self.props.emptyBtnTitle ? : @"" attributes:attributes];
}

- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    return self.props.emptyBtnImage;
}

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    return self.props.emptyBtnBackgroundImage;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor clearColor];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.props.customView;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.props.emptyVerticalOffset;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.props.emptySpaceHeight;
}

#pragma mark - DZNEmptyDataSetDelegate

//- (BOOL)emptyDataSetShouldFadeIn:(UIScrollView *)scrollView {
//    return YES;
//}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return self.props.userInteractionEnabled;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return self.props.allowScroll;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.shouldDisplay ? self.shouldDisplay() : YES;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView
{
    return self.shouldStartImageViewAnimate ? self.shouldStartImageViewAnimate() : YES;
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.imageAnimation ?: [CAAnimation animation];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    !self.emptyViewTapBlock ?: self.emptyViewTapBlock(view);
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    !self.emptyBtnTapBlock ?: self.emptyBtnTapBlock(button);
}

#pragma mark - life cycle

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView
{
    !self.emptyViewWillAppear ?: self.emptyViewWillAppear();
}

- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView
{
    !self.emptyViewDidAppear ?: self.emptyViewDidAppear();
}

- (void)emptyDataSetWillDisappear:(UIScrollView *)scrollView
{
    !self.emptyViewWillDisappear ?: self.emptyViewWillDisappear();
}

- (void)emptyDataSetDidDisappear:(UIScrollView *)scrollView
{
    !self.emptyViewDidDisappear ?: self.emptyViewDidDisappear();
}

@end
