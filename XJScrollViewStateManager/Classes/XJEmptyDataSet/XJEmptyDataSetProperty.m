//
//  XJEmptyDataSetProperty.m
//  XJScrollViewStateManager
//
//  Created by apple on 2020/4/25.
//

#import "XJEmptyDataSetProperty.h"

@implementation XJEmptyDataSetProperty

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _emptyVerticalOffset = 0;
        _emptySpaceHeight = 20;
        _allowScroll = YES;
        _userInteractionEnabled = YES;
    }
    return self;
}

- (UIFont *)emptyTitleFont
{
    return _emptyTitleFont ? : [UIFont boldSystemFontOfSize:17.0f];
}

- (UIFont *)emptySubtitleFont
{
    return _emptySubtitleFont ? : [UIFont systemFontOfSize:15.0f];
}

- (UIFont *)emptyBtnTitleFont
{
    return _emptyBtnTitleFont ? : [UIFont systemFontOfSize:17.0f];
}

- (UIColor *)emptyTitleColor
{
    return _emptyTitleColor ? : [UIColor darkGrayColor];
}

- (UIColor *)emptySubtitleColor
{
    return _emptySubtitleColor ? : [UIColor lightGrayColor];
}

- (UIColor *)emptyBtnTitleColor
{
    return _emptyBtnTitleColor ? : [UIColor whiteColor];
}

@end
