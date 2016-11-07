//
//  SPTabBarItem.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "HTSegmentsCellView.h"

/**
 角标类型

 - SPBadgeTypeText: 带有文字的角标
 - SPBadgeTypeDot:  圆点
 */
typedef NS_ENUM(NSUInteger, SPBadgeType){
    SPBadgeTypeText = 0,
    SPBadgeTypeDot
};

@interface SPTabBarItem : HTSegmentsCellView

- (instancetype)initWithIcon:(NSString*)icon
                selectedIcon:(NSString*)selectedIcon;

- (void)showBadge;
- (void)hideBadge;

/**
 Deprecated. SPBadgeTypeText is not needed.

 @param badgeType badge的类型
 @param text      用于 text 类型的 badge
 */
- (void)showBadge:(SPBadgeType)badgeType text:(NSString*)text;

@end
