//
//  HTSegmentsViewAnimator.m
//  HTUIDemo
//
//  Created by zp on 15/9/6.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTSegmentsViewAnimator.h"
#import "HTSegmentsView.h"

@interface HTSegmentsViewAnimator()
@property (nonatomic, weak) HTSegmentsView *segmentsView;
@end

@implementation HTSegmentsViewAnimator

- (instancetype)initWithSegmentsView:(HTSegmentsView*)segmentsView
{
    self = [super init];
    if (self){
        _segmentsView = segmentsView;
    }
    
    return self;
}

- (void)moveSegmentFrom:(NSUInteger)fromIndex to:(NSUInteger)to percent:(CGFloat)percent animated:(BOOL)animated;
{
    NSAssert(NO, @"cannot be here");
}

- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSAssert(NO, @"cannot be here");
}

- (void)hide
{
    NSAssert(NO, @"cannot be here");
}

- (void)show
{
    NSAssert(NO, @"cannot be here");
}

@end

@interface HTSublineSegmentViewAnimator()
@property (nonatomic, assign) CGFloat lineHeight;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) CALayer *lineLayer;

@end

@implementation HTSublineSegmentViewAnimator

- (instancetype)initWithSegmentsView:(HTSegmentsView*)segmentsView
                     backgroundColor:(UIColor*)backgroundColor
                           lineColor:(UIColor*)lineColor
                          lineHeight:(CGFloat)lineHeight
{
    self = [super initWithSegmentsView:segmentsView];
    if (self){
        _backgroundColor = backgroundColor;
        _lineColor = lineColor;
        _lineHeight = lineHeight;
        _lineWidthEqualToCellContent = NO;
        _animationDuration = 0.25;
        [self doInitSubLayers];
    }
    
    return self;
}

- (void)doInitSubLayers
{
    _backgroundLayer = [CALayer new];
    _backgroundLayer.backgroundColor = _backgroundColor.CGColor;
    
    _lineLayer = [CALayer new];
    _lineLayer.backgroundColor = _lineColor.CGColor;
    
    [self.segmentsView.layer insertSublayer:_backgroundLayer below:[self.segmentsView.layer.sublayers firstObject]];
    [_backgroundLayer addSublayer:_lineLayer];
}

- (void)moveSegmentFrom:(NSUInteger)fromIndex
                     to:(NSUInteger)to
                percent:(CGFloat)percent
               animated:(BOOL)animated
{
    CGRect fromFrame = _backgroundLayer.frame;
    if (fromIndex < self.segmentsView.segmentCells.count){
        fromFrame = [(HTSegmentsCellView*)self.segmentsView.segmentCells[fromIndex] frame];
        if (_lineWidthEqualToCellContent && [self.segmentsView.segmentsDataSource respondsToSelector:@selector(segmentsView:cellContentRectForIndex:)]){
            CGRect contentRect = [self.segmentsView.segmentsDataSource segmentsView:self.segmentsView cellContentRectForIndex:fromIndex];
            fromFrame.origin.x += contentRect.origin.x - _cellContentPadding;
            
            fromFrame.size.width = contentRect.size.width + 2 * _cellContentPadding;
        }
    }
    
    CGRect toFrame = [(HTSegmentsCellView*)self.segmentsView.segmentCells[to] frame];
    if (_lineWidthEqualToCellContent && [self.segmentsView.segmentsDataSource respondsToSelector:@selector(segmentsView:cellContentRectForIndex:)]){
        CGRect contentRect = [self.segmentsView.segmentsDataSource segmentsView:self.segmentsView cellContentRectForIndex:to];
        
        toFrame.origin.x += contentRect.origin.x - _cellContentPadding;
        
        toFrame.size.width = contentRect.size.width + 2 * _cellContentPadding;
    }
    
    CGRect frame = CGRectMake(fromFrame.origin.x + (toFrame.origin.x - fromFrame.origin.x) * percent,
                              fromFrame.origin.y + (toFrame.origin.y - fromFrame.origin.y) * percent,
                              fromFrame.size.width + (toFrame.size.width - fromFrame.size.width) * percent,
                              fromFrame.size.height + (toFrame.size.height - fromFrame.size.height) * percent);
    
    [CATransaction begin];
    [CATransaction setDisableActions:!animated];
    [CATransaction setValue:[NSNumber numberWithFloat:_animationDuration]
                     forKey:kCATransactionAnimationDuration];
    _backgroundLayer.frame = frame;
    [self layoutLayers];
    [CATransaction commit];
}

- (void)layoutLayers
{
    CGRect lineFrame = CGRectMake(0, CGRectGetHeight(_backgroundLayer.frame) - _lineHeight, CGRectGetWidth(_backgroundLayer.frame), _lineHeight);
    _lineLayer.frame = lineFrame;
}

- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self moveSegmentFrom:-1 to:index percent:1 animated:animated];
}

- (void)hide
{
    BOOL originDisableActions = [CATransaction disableActions];
    [CATransaction setDisableActions:YES];
    
    _backgroundLayer.hidden = YES;
    _lineLayer.hidden = YES;
    
    [CATransaction setDisableActions:originDisableActions];
}

- (void)show
{
    BOOL originDisableActions = [CATransaction disableActions];
    [CATransaction setDisableActions:YES];
    
    _backgroundLayer.hidden = NO;
    _lineLayer.hidden = NO;
    
    [CATransaction setDisableActions:originDisableActions];
}

- (CALayer *)lineLayer
{
    return _lineLayer;
}

- (CALayer *)backgroundLayer
{
    return _backgroundLayer;
}

@end
