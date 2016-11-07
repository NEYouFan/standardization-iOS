//
//  HTSegmentsCellView.m
//  Pods
//
//  Created by jw on 3/28/16.
//
//

#import "HTSegmentsCellView.h"
#import "ColorUtils.h"

@implementation HTSegmentsCellView

@synthesize selected=_selected;
@synthesize hilighted=_hilighted;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self doInit];
    }
    
    return self;
}

- (void)doInit
{
    _selected = NO;
    _hilighted = NO;
}

- (void)setSelected:(BOOL)s
{
    if (_selected == s)
        return;
    
    [self willChangeValueForKey:@"selected"];
    _selected = s;
    [self didChangeValueForKey:@"selected"];
}

- (BOOL)isSelected
{
    return _selected;
}

- (BOOL)isHilighted
{
    return _hilighted;
}

- (void)setHilighted:(BOOL)hilighted
{
    if (_hilighted == hilighted)
        return;
    
    [self willChangeValueForKey:@"hilighted"];
    _hilighted = hilighted;
    [self didChangeValueForKey:@"hilighted"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)updateBySwitchPercent:(CGFloat)percent animated:(BOOL)animated
{
    
}

- (CGRect)contentFrame
{
    return self.bounds;
}

@end

@interface HTStringSegmentsCell ()
@property (nonatomic,assign) CGFloat origalScale;
@end

@implementation HTStringSegmentsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = _textColor;
        [self addSubview:_label];
        
        [self addObserver:self forKeyPath:@"hilighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    
    return self;
}

- (void)layoutSubviews
{
    if (CGAffineTransformEqualToTransform(_label.transform, CGAffineTransformMakeScale(_origalScale, _origalScale))){
        _label.frame = self.bounds;
    }
    
    [super layoutSubviews];
}

- (void)updateBySwitchPercent:(CGFloat)percent  animated:(BOOL)animated
{
    UIColor *textColor = [UIColor colorWithRed:(_selectedTextColor.red - _textColor.red) * percent + _textColor.red
                                         green:(_selectedTextColor.green - _textColor.green) * percent + _textColor.green
                                          blue:(_selectedTextColor.blue - _textColor.blue) * percent + _textColor.blue
                                         alpha:(_selectedTextColor.alpha - _textColor.alpha) * percent + _textColor.alpha];
    
    if (animated){
        [UIView beginAnimations:nil context:nil];
    }
    
    CGFloat scale = (1 - _origalScale) * percent + _origalScale;
    _label.transform = CGAffineTransformMakeScale(scale, scale);
    _label.textColor = textColor;
    
    if (animated){
        [UIView commitAnimations];
    }
}

- (CGRect)contentFrame
{
    return CGRectZero;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hilighted"]){
        [self updateWhenHilighted];
    }
}

- (void)updateWhenHilighted
{
    if ([self isHilighted] && _highlightedColor){
        _label.textColor = _highlightedColor;
    }else{
        _label.textColor = self.selected ? _selectedTextColor : _textColor;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    [self updateWhenHilighted];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor
{
    _selectedTextColor = selectedTextColor;
    [self updateWhenHilighted];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self updateLabelFontSizeAndScale];
    
}

- (void)setSelectedFontSize:(CGFloat)selectedFontSize{
    _selectedFontSize = selectedFontSize;
    [self updateLabelFontSizeAndScale];
}

- (void)updateLabelFontSizeAndScale
{
    if (_fontSize == 0 || _selectedFontSize == 0) {
        return;
    }
    CGFloat maxFontSize ;
    CGFloat minFontSize ;
    if (_fontSize > _selectedFontSize) {
        maxFontSize = _fontSize;
        minFontSize = _selectedFontSize;
    }else{
        maxFontSize = _selectedFontSize;
        minFontSize = _fontSize;
    }
    [_label setFont:[UIFont systemFontOfSize:maxFontSize]];
    
    CGFloat scale = minFontSize/maxFontSize;
    _label.transform = CGAffineTransformMakeScale(scale, scale);
    
    _origalScale = scale;
    
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"hilighted"];
}

@end
