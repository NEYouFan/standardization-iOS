//
//  SPTabBarItem.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPTabBarItem.h"
#import "UIView+Frame.h"
#import "UIImage+ImageWithColor.h"
#import "SPMainSizes.h"

static const NSUInteger dotWidth = 9;

@interface SPTabBarItem ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *dotBadgeView;

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *selectedIcon;

@end

@implementation SPTabBarItem

#pragma mark - Life cycle.

- (instancetype)initWithIcon:(NSString*)icon
                selectedIcon:(NSString*)selectedIcon {
    if (self = [super initWithFrame:CGRectZero]) {
        _icon = icon;
        _selectedIcon = selectedIcon;
        
        [self loadSubviews];
        
        [self addObserver:self
               forKeyPath:@"selected"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithIcon:nil selectedIcon:nil]) {
        
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selected"];
}


#pragma mark - Load views.

- (void)loadSubviews {
    _iconImageView = [UIImageView new];
    _iconImageView.image = [UIImage imageNamed:_icon];
    [_iconImageView sizeToFit];
    [self addSubview:_iconImageView];
    
    [self selectedChanged];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _iconImageView.middleX = self.width / 2;
    _iconImageView.middleY = self.height / 2;
    _dotBadgeView.frame = CGRectMake(CGRectGetWidth(self.frame)/2 + 10, 0, dotWidth, dotWidth);
}


#pragma mark - KVO.

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        [self selectedChanged];
    }
}

- (void)selectedChanged {
    if ([self isSelected]) {
        _iconImageView.image = [UIImage imageNamed:_selectedIcon];
    } else {
        _iconImageView.image = [UIImage imageNamed:_icon];
    }
    [_iconImageView sizeToFit];
}


#pragma mark - Show badge.

- (void)showBadge {
    [self showBadge:SPBadgeTypeDot text:nil];
}

- (void)showBadge:(SPBadgeType)badgeType text:(NSString*)text {
    if (badgeType == SPBadgeTypeText) {
        // 目前 tabbar 没有 text 类型的 badge
        return;
    } else if (badgeType == SPBadgeTypeDot && _dotBadgeView) {
        // 已经显示了
        return;
    }
    
    _dotBadgeView = [[UIImageView alloc] init];
    _dotBadgeView.image = [UIImage imageNamed:@"red_point"];
    
    [self addSubview:_dotBadgeView];
}

- (void)hideBadge {
    [_dotBadgeView removeFromSuperview];
    _dotBadgeView = nil;
}

@end
