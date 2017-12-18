//
//  PagingView.h
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextField.h"

@interface PagingView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) TextField *login_userName;
@property (nonatomic, strong) TextField *login_passWord;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIView *registerView;
@property (nonatomic, strong) TextField *reg_userName;
@property (nonatomic, strong) TextField *reg_passWord;
@property (nonatomic, strong) TextField *reg_passWordRepeat;
@property (nonatomic, strong) UIButton *regBtn;
@property (nonatomic, strong) UIPageControl *pageCtrl;
@property (nonatomic, weak) id delegate;

@end

@protocol ClickBtn
- (void)didClickBtn:(UIButton *)btn;
@end
