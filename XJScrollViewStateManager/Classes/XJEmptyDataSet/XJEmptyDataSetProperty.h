//
//  XJEmptyDataSetProperty.h
//  XJScrollViewStateManager
//
//  Created by apple on 2020/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XJEmptyDataSetProperty : NSObject

/**
 default nil
 */
@property (nonatomic, strong, nullable) UIImage *emptyImage;

/**
 default @""
 */
@property (nonatomic, copy, nullable) NSString *emptyTitle;

/**
 default systemFontOfSize:17.0f
 */
@property (nonatomic, strong) UIFont *emptyTitleFont;

/**
 default darkGrayColor
 */
@property (nonatomic, strong) UIColor *emptyTitleColor;

/**
 default @""
 */
@property (nonatomic, copy, nullable) NSString *emptySubtitle;

/**
 default systemFontOfSize:15.0f
 */
@property (nonatomic, strong) UIFont *emptySubtitleFont;

/**
 default lightGrayColor
 */
@property (nonatomic, strong) UIColor *emptySubtitleColor;

/**
 default nil
 */
@property (nonatomic, copy, nullable) NSString *emptyBtnTitle;

/**
 default systemFontOfSize:17.0f
 */
@property (nonatomic, strong) UIFont *emptyBtnTitleFont;

/**
 default whiteColor
 */
@property (nonatomic, strong) UIColor *emptyBtnTitleColor;

/**
 default nil
 */
@property (nonatomic, strong, nullable) UIImage *emptyBtnImage;

/**
default nil
*/
@property (nonatomic, strong, nullable) UIImage *emptyBtnBackgroundImage;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic) CGFloat emptyVerticalOffset;

@property (nonatomic) CGPoint emptyCenterOffset DEPRECATED_MSG_ATTRIBUTE("使用新屬性：emptyVerticalOffset");

/**
 圖片 | 按鈕 | 文本 各間距 : default 20
 */
@property (nonatomic) CGFloat emptySpaceHeight;

#pragma mark - delegate

@property (nonatomic) BOOL allowScroll;

/**
 default YES
 */
@property (nonatomic) BOOL userInteractionEnabled;

@end

NS_ASSUME_NONNULL_END
