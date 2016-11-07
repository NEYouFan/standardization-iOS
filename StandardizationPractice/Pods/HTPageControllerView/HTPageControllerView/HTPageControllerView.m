//
//  HTPageControllerView.m
//  HTUIDemo
//
//  Created by zp on 15/10/11.
//  Copyright © 2015年 HT. All rights reserved.
//

#import "HTPageControllerView.h"
#import "HTLog.h"

const static NSUInteger kMaxCachedControllerCount = 6;
const static NSUInteger kPreloadControllerCount = 4;

@interface HTPageControllerView() <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *controllers;
@property (nonatomic, strong) NSMutableDictionary *placeHolderViews;

@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation HTPageControllerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _controllers = [NSMutableDictionary new];
        _placeHolderViews = [NSMutableDictionary new];
        _currentPageIndex = -1;
        
        self.delegate = self;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
#warning 需要增加scrollToTop = NO;
        [self addObserver:self forKeyPath:@"pageDataSource" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pageDataSource"]){
        [self reloadDataSource];
    }
}

- (NSUInteger)maxCachedControllerCount
{
    if ([_pageDataSource respondsToSelector:@selector(maxCachedControllerCountInpageControllerView:)]){
        return [_pageDataSource maxCachedControllerCountInpageControllerView:self];
    }
    
    return kMaxCachedControllerCount;
}

- (NSUInteger)preLoadControllerCount
{
    if ([_pageDataSource respondsToSelector:@selector(preloadControllerCountInPageControllerView:)]){
        return [_pageDataSource preloadControllerCountInPageControllerView:self];
    }
    
    return kPreloadControllerCount;
}


/**
 * 返回一定加在ScrollView上的Controller的区域
 */
- (NSRange)activeControllersRange:(NSUInteger)currentIndex
{
    return [self rangeIncludeLocation:currentIndex count:[self preLoadControllerCount] withinSize:[_pageDataSource numberOfControllersInPageControllerView]];
}

/**
 * 返回需要在内存中缓存的Controller的range，他一定比activeControllersRange要大
 */
- (NSRange)cachedControllersRange:(NSUInteger)currentIndex
{
    return [self rangeIncludeLocation:currentIndex count:[self maxCachedControllerCount] withinSize:[_pageDataSource numberOfControllersInPageControllerView]];
}

- (void)reloadDataSource
{
    //删除原来的viewcontroller，更新current index
    [self removeAllViewControllers];
    [self removeAllplaceHolders];
    
    NSUInteger pageCount = [_pageDataSource numberOfControllersInPageControllerView];
    NSUInteger newPageIndex = _currentPageIndex;
    if (pageCount >= _currentPageIndex){
        newPageIndex = pageCount - 1;
    }
    if (_currentPageIndex < 0 && pageCount > 0){
        newPageIndex = 0;
    }
    
    [self loadAllPlaceHolders];
    [self layoutIfNeeded];
    [self scrollToPageIndex:newPageIndex animated:YES];
}

- (void)removeAllViewControllers
{
    for (NSNumber *indexValue in _controllers) {
        UIViewController *controller = [_controllers objectForKey:indexValue];
        [controller.view removeFromSuperview];
    }
    
    [_controllers removeAllObjects];
}

- (void)scrollToPageIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self setSelectedIndex:index notifyDelegate:NO];
    
    //滚动到当前页
    CGFloat offsetX = CGRectGetWidth(self.frame) * index;
    [self setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (UIViewController*)pageControllerView:(NSUInteger)index
{
    return [_controllers objectForKey:@(index)];
}

- (void)setSelectedIndex:(NSUInteger)index notifyDelegate:(BOOL)bNotifyDelegate
{
    if (_currentPageIndex == index)
        return;
    
    HTLogInfo(@"change selected index from %ld to %lud", _currentPageIndex, index);
    
    NSUInteger pageCount = [_pageDataSource numberOfControllersInPageControllerView];
    if (index >= pageCount)
        index = pageCount - 1;
    _currentPageIndex = index;
    
    //1. 将需要加载到ScrollView中的Controller加载进来
    NSRange range = [self activeControllersRange:_currentPageIndex];
    for (NSUInteger i=range.location; i<range.location+range.length; i++) {
        UIViewController *vc = [self loadViewControllerAtIndex:i];
        if (vc && !vc.view.superview){
            [self addSubview:vc.view];
            [self removePlaceHolderViewAtIndex:i];
        }
    }
    
    //2. 将不需要加载到ScrollView中的Controller从ScrollView中remove下来
    [self removeInactiveControllerFromScrollView];
    
    //3. 将超过缓存限制的Controller从内存中删除
    [self removeNotCachedControllers];
    
    if (bNotifyDelegate &&
        [_pageDelegate respondsToSelector:@selector(pageControllerViewDidSelectedIndex:)]){
        [_pageDelegate pageControllerViewDidSelectedIndex:_currentPageIndex];
    }
}

- (UIViewController*)loadViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *vc = [_controllers objectForKey:@(index)];
    if (vc)
        return vc;
    
    vc = [_pageDataSource pageControllerView:self viewControllerForIndex:index];
    [_controllers setObject:vc forKey:@(index)];
    [self layoutViewController:vc atIndex:index];
    
    HTLogInfo(@"create new page controller:%lud", index);
    
    return vc;
}

- (void)layoutViewController:(UIViewController*)controller atIndex:(NSUInteger)index
{
    CGFloat x = CGRectGetWidth(self.frame) * index;
    controller.view.frame = CGRectMake(x, 0, CGRectGetWidth(self.frame), self.contentSize.height);
}

- (void)removeInactiveControllerFromScrollView
{
    //除去当前controller，以及前后各1个controller，其他的controller的view，要从ScrollView中删除，节省性能
    NSUInteger pageCount = [_pageDataSource numberOfControllersInPageControllerView];
    NSRange range = [self rangeIncludeLocation:_currentPageIndex count:[self preLoadControllerCount] withinSize:pageCount];
    
    for (int i = 0; i<pageCount; i++) {
        UIViewController *vc = [_controllers objectForKey:@(i)];
        if (range.location <= i && i < range.location+range.length){
            continue;
        }
        
        if (vc.view && vc.view.superview){
            [vc.view removeFromSuperview];
            [self addPlaceHolderViewAtIndex:i];
            HTLogInfo(@"remove page controller from super view at index:%d", i);
        }
    }
}

- (void)removeNotCachedControllers
{
    NSUInteger pageCount = [_pageDataSource numberOfControllersInPageControllerView];
    NSRange cachedRange = [self rangeIncludeLocation:_currentPageIndex count:[self maxCachedControllerCount] withinSize:pageCount];
    
    for (NSInteger i=0; i<cachedRange.location; i++) {
        UIViewController *vc = [_controllers objectForKey:@(i)];
        if (vc){
            [vc.view removeFromSuperview];
            [self addPlaceHolderViewAtIndex:i];
            HTLogInfo(@"remove page controller at index:%ld", i);
        }
        [_controllers removeObjectForKey:@(i)];
    }
    
    for (NSInteger i=cachedRange.location + cachedRange.length; i<pageCount; i++) {
        UIViewController *vc = [_controllers objectForKey:@(i)];
        if (vc){
            [vc.view removeFromSuperview];
            [self addPlaceHolderViewAtIndex:i];
            HTLogInfo(@"remove page controller at index:%ld", i);
        }
        [_controllers removeObjectForKey:@(i)];
    }
}

#pragma mark - placeholder
- (void)removeAllplaceHolders
{
    for (NSNumber *indexValue in _placeHolderViews){
        UIView *placeHolder = [_placeHolderViews objectForKey:indexValue];
        if (placeHolder.superview)
            [placeHolder removeFromSuperview];
    }
    
    [_placeHolderViews removeAllObjects];
}

- (void)loadAllPlaceHolders
{
    NSUInteger count = [_pageDataSource numberOfControllersInPageControllerView];
    for (int i=0; i<count; i++) {
        if ([_pageDataSource respondsToSelector:@selector(pageControllerView:placeHolderViewForIndex:)]){
            UIView *placeHolderView = [_pageDataSource pageControllerView:self placeHolderViewForIndex:i];
            if (placeHolderView){
                [_placeHolderViews setObject:placeHolderView forKey:@(i)];
                [self addSubview:placeHolderView];
            }
        }
    }
}

- (void)layoutPlaceHolderView:(UIView*)placeHolder atIndex:(NSInteger)index
{
    CGFloat x = CGRectGetWidth(self.frame) * index;
    placeHolder.frame = CGRectMake(x, 0, CGRectGetWidth(self.frame), self.contentSize.height);
}

- (void)addPlaceHolderViewAtIndex:(NSInteger)index
{
    UIView *view = [_placeHolderViews objectForKey:@(index)];
    if (!view.superview){
        [self insertSubview:view atIndex:0];
    }
}

- (void)removePlaceHolderViewAtIndex:(NSInteger)index
{
    UIView *view = [_placeHolderViews objectForKey:@(index)];
    if (view.superview){
        [view removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    NSUInteger pageCount = [_pageDataSource numberOfControllersInPageControllerView];
    self.contentSize = CGSizeMake(pageCount * CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));

    for (NSNumber *key in _controllers) {
        [self layoutViewController:(UIViewController*)[_controllers objectForKey:key] atIndex:[key integerValue]];
    }
    
    for (NSNumber *key in _placeHolderViews){
        [self layoutPlaceHolderView:(UIView*)[_placeHolderViews objectForKey:key] atIndex:[key integerValue]];
    }
    
    //TODO:是否需要调整ContentOffset
    
    [super layoutSubviews];
}

//如果vc在一开始的时候，就加入到parent vc中，而parent vc并没有显示出来，那么档parent vc显示的时候，page controller接收不到view appear事件。 如果parent vc已经显示了，那么显示新的page view controller的时候，添加page view controller的view的时候，会接收到view appear事件。
#pragma mark - view controller events
#warning 生命周期需要修改
- (void)viewWillAppear:(BOOL)animated
{
    for (NSNumber *key in _controllers) {
        UIViewController *vc = [_controllers objectForKey:key];
        if (vc.view.superview)
            [vc viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    for (NSNumber *key in _controllers) {
        UIViewController *vc = [_controllers objectForKey:key];
        if (vc.view.superview)
            [vc viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (NSNumber *key in _controllers) {
        UIViewController *vc = [_controllers objectForKey:key];
        if (vc.view.superview)
            [vc viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    for (NSNumber *key in _controllers) {
        UIViewController *vc = [_controllers objectForKey:key];
        if (vc.view.superview)
            [vc viewDidDisappear:animated];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_pageDelegate respondsToSelector:@selector(pageControllerViewDidScroll:)]){
        [_pageDelegate pageControllerViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //当ScrollView滑动结束位置正好是一页时，不会走回调scrollViewDidEndDecelerating，所以用scrollViewDidEndDragging回调，当decelerate为NO时来补充
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width);
    [self setSelectedIndex:index notifyDelegate:YES];
}

#pragma mark -
//返回从location开始，前后扩散count个单位的range。返回的range的length一定等于count
- (NSRange)rangeIncludeLocation:(NSUInteger)location count:(NSUInteger)count withinSize:(NSUInteger)size
{
    if (count > size)
        count = size;
    
    if (count == 0 || count == 1){
        return NSMakeRange(location, count);
    }
    
    NSInteger startIndex = location;
    NSInteger endIndex = location;
    
    NSInteger remainCount = count - 1;//减去location
    do {
        if (remainCount == 0)
            break;
        
        if (startIndex > 0){
            startIndex --;
            remainCount --;
        }
        
        if (remainCount == 0)
            break;
        
        if (endIndex < size-1){
            endIndex ++;
            remainCount --;
        }
        
    } while (YES);
    
    return NSMakeRange(startIndex, endIndex-startIndex+1);
}


#pragma mark -
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"pageDataSource"];
}


@end
