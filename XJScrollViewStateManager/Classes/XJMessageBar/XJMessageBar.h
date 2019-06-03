//
//  XJMessageBar.h
//  XJMessageBar
//
//  Created by jimi on 2014/6/19.
//  Copyright (c) 2014年 jimi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    XJMessageBarTypeTop,
    XJMessageBarTypeBottom
} XJMessageBarType;

@interface XJMessageBar : UIView

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSTimeInterval dismissTimeInterval;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;

@property (nonatomic, assign) XJMessageBarType messageBarType;

+ (instancetype)messageBarType:(XJMessageBarType)messageBarType
              dismissWhenTouch:(BOOL)dismissWhenTouch
                    showInView:(UIView *)inView;

- (void)showMessage:(NSString *)message;
- (void)showMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss;
- (void)showBottomMessage:(NSString *)message;
- (void)hide;

@end
