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
@property (nonatomic, assign) BOOL dismissWhenTouch;
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
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        [self createMessageBar];
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.bgColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    self.textColor = [UIColor whiteColor];
    self.dismissTimeInterval = 3;
    self.horizontalPadding = 10.0f;
    self.verticalPadding = 15.0f;
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
    
    CGFloat messageBarPosY = (self.messageBarType == XJMessageBarTypeTop) ? 0.0f : vh - messageViewH;
    self.frame = CGRectMake(0, messageBarPosY, vw, messageViewH);
}

- (void)createMessageBar
{
    UIView *messageView = [[UIView alloc] init];
    [self addSubview:messageView];
    self.messageView = messageView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessageBar)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.font = [UIFont systemFontOfSize:13.0f];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.numberOfLines = 0;
    
    [self.messageView addSubview:messageLabel];
    self.messageLabel = messageLabel;
}

- (void)setFont:(UIFont *)font {
    self.messageLabel.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    self.messageLabel.textColor = textColor;
}

- (void)setBgColor:(UIColor *)bgColor {
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
                weakSelf.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.dismissTimeInterval target:weakSelf selector:@selector(hide) userInfo:nil repeats:NO];
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
        [UIView animateWithDuration:0.4 delay:0 options:(7 << 16) animations:^{
            
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

    [UIView animateWithDuration:0.4 delay:0 options:(7 << 16) animations:^{
        
        self.messageView.frame = messageBarFrame;
        
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = NO;
        if (completion) completion();
        
    }];
}

- (void)hideWithCompletion:(void (^)(void))completion
{
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    
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



- (void)removeMessageBar
{
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    
    [self removeFromSuperview];
    [self.messageLabel removeFromSuperview];
    self.messageLabel = nil;
}

@end
