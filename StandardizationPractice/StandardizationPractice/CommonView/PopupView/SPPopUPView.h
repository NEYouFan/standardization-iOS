//
//  SPPopUPView.h
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPPopCellData : NSObject

@end

@interface SPPopUPView : UIView

@property (nonatomic, copy) UIView *contentView;

- (instancetype)initWithContentView:(UIView *)contentView;

- (void)popup;

- (void)dismiss;

@end
