//
//  HTBadgeTextView.m
//  RedPoint
//
//  Created by cxq on 15/9/9.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTBadgeTextView.h"

@implementation HTBadgeTextView
{
    NSInteger _oldLength;
    NSInteger _newLength;
    CGFloat _autoIncrementWidth;
}

- (instancetype)initWithInnerSize:(CGSize)innerSize outerSize:(CGSize)outerSize isRound:(BOOL)isRound
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _autoIncrementWidth = 0;
        _innerSize = innerSize;
        _outerSize = outerSize;
        _isRound = isRound;
        [self loadSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithInnerSize:CGSizeZero outerSize:CGSizeZero isRound:NO];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self handleWidth];
    [self handleCenter];
    
}

- (void)loadSubViews
{
    _outerBackground = [[UIImageView alloc] init];
    _innerBackground = [[UIImageView alloc] init];
    [self addSubview:_outerBackground];
    [self addSubview:_innerBackground];
    
    _innerBackground.frame = CGRectMake(_innerBackground.frame.origin.x, _innerBackground.frame.origin.y, _innerSize.width, _innerSize.height);
    _outerBackground.frame = CGRectMake(_outerBackground.frame.origin.x, _outerBackground.frame.origin.y, _outerSize.width, _outerSize.height);
    [self handelRound];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:12];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
}

- (NSString *)text
{
    return _textLabel.text;
}

#pragma mark - 重写set方法
- (void)setText:(NSString *)text
{
    if (_textLabel.text == nil && text.length > 0) {
        _oldLength = 1;
    }else{
        _oldLength = _textLabel.text.length;
    }
    
    _newLength = text.length;
    _textLabel.text = text;
    [_textLabel sizeToFit];
}

- (void)setTextFontSize:(CGFloat)fontSize
{
    _textLabel.font = [UIFont systemFontOfSize:fontSize];
    [_textLabel sizeToFit];
}

- (void)setInnerImage:(UIImage *)innerImage
{
    if (_innerImage != innerImage) {
        _innerImage = innerImage;
        _innerBackground.image = innerImage;
    }
}

- (void)setOuterImage:(UIImage *)outerImage
{
    if (_outerImage != outerImage) {
        _outerImage = outerImage;
        _outerBackground.image = outerImage;
    }
}

- (void)setInnerSize:(CGSize)innerSize
{
    if (!CGSizeEqualToSize(innerSize, _innerSize)) {
        _innerSize = innerSize;
        [self handelRound];
        [self setNeedsDisplay];
    }
}

- (void)setOuterSize:(CGSize)outerSize
{
    if (!CGSizeEqualToSize(outerSize, _outerSize)) {
        _outerSize = outerSize;
        [self handelRound];
        [self setNeedsDisplay];
    }
}

- (void)setPadding:(CGFloat)padding
{
    if (_padding != padding) {
        _padding = padding;
        [self setNeedsDisplay];
    }
}

- (void)setInnerOuterPadding:(CGFloat)innerOuterPadding
{
    if (_innerOuterPadding != innerOuterPadding) {
        _innerOuterPadding = innerOuterPadding;
        [self setNeedsDisplay];
    }
}

- (void)setIsRound:(BOOL)isRound
{
    _isRound = isRound;
    [self handelRound];
}

- (void)handleWidth
{
    if (_needWidthAutoIncrement && _oldLength != _newLength && _newLength != 1) {
        
        CGRect tempRect = _innerBackground.frame;
        tempRect.size.width = _textLabel.frame.size.width + _padding * 2;
        _innerBackground.frame = tempRect;
        
        tempRect = _outerBackground.frame;
        tempRect.size.width = _innerBackground.frame.size.width + _innerOuterPadding * 2;
        _outerBackground.frame = tempRect;
        
    }else if(_newLength == 1){
        _innerBackground.frame = CGRectMake(_innerBackground.frame.origin.x, _innerBackground.frame.origin.y, _innerSize.width, _innerSize.height);
        _outerBackground.frame = CGRectMake(_outerBackground.frame.origin.x, _outerBackground.frame.origin.y, _outerSize.width, _outerSize.height);
    }
    
    CGRect tempRect = self.frame;
    tempRect.size.width = _innerBackground.frame.size.width > _outerBackground.frame.size.width ?_innerBackground.frame.size.width:_outerBackground.frame.size.width;
    tempRect.size.height = _innerBackground.frame.size.height > _outerBackground.frame.size.height ?_innerBackground.frame.size.height:_outerBackground.frame.size.height;
    self.frame = tempRect;
    
}

- (void)handelRound
{
    if (_isRound) {
        _innerBackground.layer.cornerRadius = _innerSize.height/2;
        _innerBackground.layer.masksToBounds = YES;
        _outerBackground.layer.cornerRadius = _outerSize.height/2;
        _outerBackground.layer.masksToBounds = YES;
    }
}

#pragma mark - 处理居中
- (void)handleCenter
{
    [_textLabel setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [_innerBackground setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [_outerBackground setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
}

@end