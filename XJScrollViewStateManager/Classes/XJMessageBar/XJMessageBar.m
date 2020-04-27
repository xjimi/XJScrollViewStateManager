//
//  XJMessageBar.m
//  XJMessageBar
//
//  Created by jimi on 2014/6/19.
//  Copyright (c) 2014年 jimi. All rights reserved.
//

#import "XJMessageBar.h"

@interface XJMessageBar ()

@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSTimer *autoDismissTimer;
@property (nonatomic, weak) UIView *view;


@end

@implementation XJMessageBar

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (instancetype)messageBarType:(XJMessageBarType)messageBarType
              dismissWhenTouch:(BOOL)dismissWhenTouch
                    showInView:(UIView *)inView
{
    XJMessageBar *messageBar = [[XJMessageBar alloc] init];
    messageBar.messageBarType = messageBarType;
    messageBar.dismissWhenTouch = dismissWhenTouch;
    messageBar.view = inView;
    messageBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [inView addSubview:messageBar];
    return messageBar;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
        [self createMessageBar];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    self.bgColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    self.textColor = [UIColor whiteColor];
    self.dismissTimeInterval = 3;
    self.horizontalPadding = 10.0f;
    self.verticalPadding = 10.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat vw = self.view.frame.size.width;
    CGFloat vh = self.view.frame.size.height;
    
    CGFloat labelW = vw - (self.horizontalPadding * 2);
    CGRect messageLabelFrame = CGRectMake(self.horizontalPadding, self.verticalPadding, labelW, 0.0f);
    self.messageLabel.frame = messageLabelFrame;
    [self.messageLabel sizeToFit];
    CGRect newMessageLabelFrame = self.messageLabel.frame;
    newMessageLabelFrame.size.width = labelW;
    self.messageLabel.frame = newMessageLabelFrame;
    
    CGFloat messageViewH = newMessageLabelFrame.size.height + self.verticalPadding * 2;
    CGRect messageViewFrame = self.messageView.frame;
    if (messageViewH == self.verticalPadding * 2) {
        //代表沒文字 不需要show
        messageViewFrame.origin.y = (self.messageBarType == XJMessageBarTypeTop) ? -messageViewH : messageViewH;
    }
    messageViewFrame.size.width = vw;
    messageViewFrame.size.height = messageViewH;
    self.messageView.frame = messageViewFrame;
    
    CGFloat messageBarPosY = (self.messageBarType == XJMessageBarTypeTop) ? 0.0f - self.startPosY : vh - messageViewH;
    self.frame = CGRectMake(0, messageBarPosY, vw, messageViewH);
}

- (void)createMessageBar
{
    UIView *messageView = [[UIView alloc] init];
    [self addSubview:messageView];
    self.messageView = messageView;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = self.textColor;
    [self.messageView addSubview:messageLabel];
    self.messageLabel = messageLabel;
}

- (void)setDismissWhenTouch:(BOOL)dismissWhenTouch
{
    if (_dismissWhenTouch == dismissWhenTouch) return;
    
    _dismissWhenTouch = dismissWhenTouch;
    if (dismissWhenTouch) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessageBar)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.messageLabel.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.messageLabel.textColor = textColor;
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    self.messageView.backgroundColor = bgColor;
}

- (void)showMessage:(NSString *)message {
    [self showMessage:message autoDismiss:NO];
}

- (void)showMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss
{
    self.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    [self hideWithCompletion:^{
        
        weakSelf.messageLabel.text = message;
        [weakSelf setNeedsLayout];
        [weakSelf layoutIfNeeded];

        CGRect messageBarFrame = self.messageView.frame;
        messageBarFrame.origin.y = 0.0f;
        [UIView animateWithDuration:0.4 delay:0 options:(7 << 16) animations:^{
            
            weakSelf.messageView.frame = messageBarFrame;
            
        } completion:^(BOOL finished) {
            
            weakSelf.userInteractionEnabled = YES;
            if (autoDismiss) {
                [self createTimer];
            }
            
        }];
        
    }];
}

- (void)showBottomMessage:(NSString *)message
{
    self.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    [self hideBottomWithCompletion:^{
        
        weakSelf.messageLabel.text = message;
        [weakSelf setNeedsLayout];
        [weakSelf layoutIfNeeded];
        
        CGRect messageViewFrame = self.messageView.frame;
        messageViewFrame.origin.y = 0;
        [UIView animateWithDuration:0.3 delay:0 options:(7 << 16) animations:^{
            
            weakSelf.messageView.frame = messageViewFrame;
            
        } completion:^(BOOL finished) {
            
            weakSelf.userInteractionEnabled = YES;
            
        }];
        
    }];
}

- (void)hideBottomWithCompletion:(void (^)(void))completion
{
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect messageBarFrame = self.messageView.frame;
    messageBarFrame.origin.y = messageBarFrame.size.height;

    [UIView animateWithDuration:0.3 delay:0 options:(7 << 16) animations:^{
        
        self.messageView.frame = messageBarFrame;
        
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = NO;
        if (completion) completion();
        
    }];
}

- (void)hideWithCompletion:(void (^)(void))completion
{
    [self invalidateTimer];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect messageBarFrame = self.messageView.frame;
    messageBarFrame.origin.y = -messageBarFrame.size.height;
    [UIView animateWithDuration:0.4 delay:0 options:(7 << 16) animations:^{
        
        self.messageView.frame = messageBarFrame;
        
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = NO;
        if (completion) completion();
        
    }];
}

- (void)hide
{
    if (self.messageBarType == XJMessageBarTypeTop) [self hideWithCompletion:nil];
    else if (self.messageBarType == XJMessageBarTypeBottom) [self hideBottomWithCompletion:nil];
}

- (void)tapMessageBar {
    if (self.dismissWhenTouch) [self hide];
}

- (void)createTimer
{
    [self invalidateTimer];
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:self.dismissTimeInterval target:self selector:@selector(hide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
}

- (void)removeMessageBar
{
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    
    [self invalidateTimer];
    [self removeFromSuperview];
    [self.messageLabel removeFromSuperview];
    self.messageLabel = nil;
}

@end
