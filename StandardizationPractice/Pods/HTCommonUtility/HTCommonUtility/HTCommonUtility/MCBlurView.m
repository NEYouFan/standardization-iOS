//
//  MCBlurView.m
//  NeteaseMusic
//
//  Created by Chengyin on 14-8-25.
//
//

#import "MCBlurView.h"

@implementation MCBlurView
{
@private
    UIView *_maskView;
    UIView *_bgView;
    MCBlurStyle _style;
}
@synthesize style = _style;

- (instancetype)initWithStyle:(MCBlurStyle)style frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _style = style;
        if (isIOS8)
        {
            if (_style == MCBlurStyleBlack)
            {
                _bgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            }
            else
            {
                _bgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
            }
        }
        else if (isIOS7)
        {
            _bgView = [[UIToolbar alloc] init];
            if (_style == MCBlurStyleBlack)
            {
                [(UIToolbar *)_bgView setBarStyle:UIBarStyleBlack];
            }
            else
            {
                [(UIToolbar *)_bgView setBarStyle:UIBarStyleDefault];
            }
        }
        else
        {
            _bgView = [[UIView alloc] init];
            if (_style == MCBlurStyleWhite)
            {
                _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
            }
            else
            {
                _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
            }
        }
        [self addSubview:_bgView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MCBlurStyleWhite frame:frame];
}

- (id)initWithStyle:(MCBlurStyle)style
{
    return [self initWithStyle:style frame:CGRectZero];
}

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    if ([_bgView isKindOfClass:[UIToolbar class]])
    {
        [(UIToolbar *)_bgView setBarTintColor:blurTintColor];
    }
    else if ([_bgView isKindOfClass:[UIVisualEffectView class]])
    {
        [(UIVisualEffectView *)_bgView setTintColor:blurTintColor];
    }
}

- (UIColor *)blurTintColor
{
    if ([_bgView isKindOfClass:[UIVisualEffectView class]])
    {
        return [(UIVisualEffectView *)_bgView tintColor];
    }
    else if ([_bgView isKindOfClass:[UIToolbar class]])
    {
        return [(UIToolbar *)_bgView barTintColor];
    }
    else
    {
        return nil;
    }
}

- (void)setUnblurTintColor:(UIColor *)unblurTintColor
{
    if (![_bgView isKindOfClass:[UIToolbar class]] && ![_bgView isKindOfClass:[UIVisualEffectView class]])
    {
        [_bgView setBackgroundColor:unblurTintColor];
    }
}

- (UIColor *)unblurTintColor
{
    if (![_bgView isKindOfClass:[UIToolbar class]] && ![_bgView isKindOfClass:[UIVisualEffectView class]])
    {
        return _bgView.backgroundColor;
    }
    else
    {
        return nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _maskView.frame = self.bounds;
    _bgView.frame = self.bounds;
}
@end
