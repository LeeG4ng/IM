//
//  NaviView.h
//  IM
//
//  Created by Gary Lee on 2017/12/23.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, NaviHolder) {NaviHolderTable, NaviHolderChat};
@interface NaviView : UIView

@property (nonatomic, assign) NaviHolder holder;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;

- (void)layout;
@end
