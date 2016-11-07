//
//  HTSegmentsView.m
//  HTUIDemo
//
//  Created by zp on 15/9/6.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTSegmentsView.h"
#import "HTSegmentsViewAnimator.h"

@interface HTSegmentsView()
@end



@interface HTSegmentsView()

@property (nonatomic, strong) NSArray *segmentCells;

@property (nonatomic, assign) NSUInteger touchesBeginIndex;

@end

@implementation HTSegmentsView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndex = -1;
        _touchesBeginIndex = NSNotFound;
        self.userInteractionEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        [self reloadData];
    }
    return self;
}

- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _selectedIndex = selectedIndex;
    }
    return self;
}

- (void)setSegmentsDataSource:(id<HTSegmentsViewDatasource>)segmentsDataSource
{
    _segmentsDataSource = segmentsDataSource;
    [self reloadData];
    if ([self legalSelectedIndex]) {
        [self moveFrom:_selectedIndex to:_selectedIndex percent:1];
    }
}

- (BOOL)legalSelectedIndex
{
    NSUInteger count = [_segmentsDataSource numberOfCellsInSegementsView:self];
    return _selectedIndex >=0 && _selectedIndex < count;
}

- (void)reloadData
{
    [self removeAllCells];
    
    NSUInteger count = [_segmentsDataSource numberOfCellsInSegementsView:self];
    if (0 == count){
        [_animator hide];
    }
    
    NSMutableArray *segmentCells = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i=0; i<count; i++) {
        HTSegmentsCellView *cell = [_segmentsDataSource segmentsView:self cellForIndex:i];
        [segmentCells addObject:cell];
        [self addSubview:cell];
    }
    
    _segmentCells = segmentCells;
    [self layoutIfNeeded];
    [_animator show];
    
    if ([self legalSelectedIndex]) {
        [_animator moveToIndex:_selectedIndex animated:YES];
        [(HTSegmentsCellView*)_segmentCells[_selectedIndex] updateBySwitchPercent:1 animated:NO];
        [(HTSegmentsCellView*)_segmentCells[_selectedIndex] setSelected:YES];
    }else{
        _selectedIndex = -1;
        return;
    }
}

- (void)removeAllCells
{
    for (HTSegmentsCellView *cell in _segmentCells) {
        [cell removeFromSuperview];
    }
    
    _segmentCells = nil;
}

- (void)moveFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex percent:(CGFloat)percent
{
    if (toIndex >= self.segmentCells.count)
        return;
    
    //更新cell
    if (fromIndex < self.segmentCells.count)
        [(HTSegmentsCellView*)_segmentCells[fromIndex] updateBySwitchPercent:1-percent animated:NO];
    if (toIndex < self.segmentCells.count)
        [(HTSegmentsCellView*)_segmentCells[toIndex] updateBySwitchPercent:percent animated:NO];
    
    //更新animator
    [_animator moveSegmentFrom:fromIndex to:toIndex percent:percent animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated notifyDelegate:(BOOL)bNotifyDelegate
{
    if (self.selectedIndex == index)
        return;
    if ([self legalSelectedIndex]) {
        ((HTSegmentsCellView*)_segmentCells[self.selectedIndex]).selected = NO;
        [(HTSegmentsCellView*)_segmentCells[self.selectedIndex] updateBySwitchPercent:0 animated:animated];
    }
    _selectedIndex = index;
    
    [_animator moveToIndex:index animated:animated];
    
    ((HTSegmentsCellView*)_segmentCells[index]).selected = YES;
    [(HTSegmentsCellView*)_segmentCells[index] updateBySwitchPercent:1 animated:animated];
    
    if (bNotifyDelegate &&
        [self.segmentsDelegate respondsToSelector:@selector(segmentsView:didSelectedAtIndex:)]){
        [self.segmentsDelegate segmentsView:self didSelectedAtIndex:self.selectedIndex];
    }
    
    [self adjustToCenter];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self setSelectedIndex:index animated:animated notifyDelegate:NO];
}

#pragma mark - touches events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    HTSegmentsCellView *foundCell;
    for (HTSegmentsCellView *cell in _segmentCells){
        if (CGRectContainsPoint(cell.frame, location)){
            foundCell = cell;
            break;
        }
    }
    
    if (!foundCell)
        return;
    
    NSUInteger index = [_segmentCells indexOfObject:foundCell];
    if ([_segmentsDelegate respondsToSelector:@selector(segmentsView:shouldSelectedAtIndex:)]){
        if (![_segmentsDelegate segmentsView:self shouldSelectedAtIndex:index]){
            return;
        }
    }
    
    _touchesBeginIndex = index;
    [foundCell setHilighted:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_touchesBeginIndex == NSNotFound)
        return;
    
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    HTSegmentsCellView *foundCell;
    for (HTSegmentsCellView *cell in _segmentCells){
        if (CGRectContainsPoint(cell.frame, location)){
            foundCell = cell;
            break;
        }
    }
    
    HTSegmentsCellView *touchesBeginSegmentCell = [_segmentCells objectAtIndex:_touchesBeginIndex];
    
    if (!foundCell){
        _touchesBeginIndex = NSNotFound;
        [touchesBeginSegmentCell setHilighted:NO];
        return;
    }
    
    if (_touchesBeginIndex != [_segmentCells indexOfObject:foundCell]){
        [touchesBeginSegmentCell setHilighted:NO];
        _touchesBeginIndex = NSNotFound;
        return;
    }
    
    [touchesBeginSegmentCell setHilighted:NO];
    
    if (_touchesBeginIndex != _selectedIndex){
        [self setSelectedIndex:_touchesBeginIndex animated:YES notifyDelegate:YES];
    }

    _touchesBeginIndex = NSNotFound;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if (_touchesBeginIndex == NSNotFound)
        return;
    
    HTSegmentsCellView *touchesBeginSegmentCell = [_segmentCells objectAtIndex:_touchesBeginIndex];
    [touchesBeginSegmentCell setHilighted:NO];
    _touchesBeginIndex = NSNotFound;
}

#pragma mark - adjust to center
- (void)adjustToCenter
{
    if (!_needAdjustToCenter)
        return;
    
    if (CGSizeEqualToSize(self.contentSize, self.frame.size)){
        return;
    }
    
    HTSegmentsCellView *cellView = [self.segmentCells objectAtIndex:self.selectedIndex];
    CGPoint cellViewOriginPoint = cellView.frame.origin;
    
    BOOL bHorizontal = CGRectGetWidth(self.frame) < self.contentSize.width;
    BOOL bVertical = CGRectGetHeight(self.frame) < self.contentSize.height;
    
    CGPoint newContentOffset = self.contentOffset;
    if (bHorizontal){
        if (cellViewOriginPoint.x + CGRectGetWidth(self.frame)/2 > self.contentSize.width){
            newContentOffset.x = self.contentSize.width - CGRectGetWidth(self.frame);
        }
        else if (cellViewOriginPoint.x - CGRectGetWidth(self.frame)/2 < 0){
            newContentOffset.x = 0;
        }
        else{
            newContentOffset.x = cellViewOriginPoint.x - CGRectGetWidth(self.frame)/2;
        }

    }
    
    if (bVertical){
        if (cellViewOriginPoint.y + CGRectGetHeight(self.frame)/2 > self.contentSize.height){
            newContentOffset.y = self.contentSize.height - CGRectGetHeight(self.frame);
        }
        else if (cellViewOriginPoint.y - CGRectGetHeight(self.frame)/2 < 0){
            newContentOffset.y = 0;
        }
        else{
            newContentOffset.y = cellViewOriginPoint.y - CGRectGetHeight(self.frame)/2;
        }
    }
    
    [self setContentOffset:newContentOffset animated:YES];
}

@end


@implementation HTHorizontalSegmentsView

- (void)layoutSubviews
{
    CGFloat startX = 0;
    CGFloat startY = 0;
    
    for (int i=0; i<self.segmentCells.count; i++) {
        HTSegmentsCellView *cell = self.segmentCells[i];
        
        CGSize size = [self.segmentsDataSource segmentsView:self cellSizeForIndex:i];
        
        cell.frame = CGRectMake(startX, startY, size.width, size.height);
        
        startX += size.width;
    }
    
    self.contentSize = CGSizeMake(startX, self.frame.size.height);
    
    [super layoutSubviews];
}

@end

@implementation HTVerticalSegmentsView

- (void)layoutSubviews
{
    CGFloat startX = 0;
    CGFloat startY = 0;
    
    for (int i=0; i<self.segmentCells.count; i++) {
        HTSegmentsCellView *cell = self.segmentCells[i];
        
        CGSize size = [self.segmentsDataSource segmentsView:self cellSizeForIndex:i];
        
        cell.frame = CGRectMake(startX, startY, size.width, size.height);
        
        startY += size.height;
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, startY);
    
    [super layoutSubviews];
}

@end

@interface HTStringToLabelDataSource()

@property (nonatomic, copy) NSArray *stringArray;
@property (nonatomic, strong) Class cellClass;

@end

@implementation HTStringToLabelDataSource

- (instancetype)initWithArray:(NSArray*)stringArray segmentCellClass:(Class)cls
{
    self = [super init];
    if (self){
        _stringArray = stringArray;
        _cellClass = cls ? cls : HTStringSegmentsCell.class;
    }
    return self;
}

- (NSUInteger)numberOfCellsInSegementsView:(HTSegmentsView*)segmentsView
{
    return _stringArray.count;
}

- (HTSegmentsCellView*)segmentsView:(HTSegmentsView*)segmentsView cellForIndex:(NSUInteger)index
{
    HTStringSegmentsCell *cell = [_cellClass new];
    if ([cell isKindOfClass:HTStringSegmentsCell.class]){
        cell.selectedFontSize = _selectedFontSize;
        cell.fontSize = _fontSize;
        cell.textColor = _textColor;
        cell.selectedTextColor = _selectedTextColor;
        cell.highlightedColor = _highlightedTextColor;
        cell.label.text = _stringArray[index];
    }
    return cell;
}

- (CGSize)segmentsView:(HTSegmentsView*)segmentsView cellSizeForIndex:(NSUInteger)index
{
    return CGSizeMake(_cellWidth, _cellHeight);
}

- (CGRect)segmentsView:(HTSegmentsView*)segmentsView cellContentRectForIndex:(NSUInteger)index
{
    HTStringSegmentsCell *cell = (HTStringSegmentsCell*)segmentsView.segmentCells[index];
    CGSize size = [cell.label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    size = CGSizeApplyAffineTransform(size, cell.label.transform);
    
    //居中
    return CGRectMake((CGRectGetWidth(cell.frame)-size.width)/2, (CGRectGetHeight(cell.frame)-size.height)/2, size.width, size.height);
}

@end

