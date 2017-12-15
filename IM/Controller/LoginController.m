//
//  LoginController.m
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "LoginController.h"
#import "PagingView.h"
#import "LoadingView.h"
#import "Masonry.h"

@interface LoginController ()

@property (nonatomic, strong) UIImageView *bottomView;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bottomView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_bottomView];
    _bottomView.image = [UIImage imageNamed:@"background"];
    _bottomView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImageView *logo = [[UIImageView alloc] init];
    PagingView *pagingView = [[PagingView alloc] init];
    LoadingView *loadingView = [[LoadingView alloc] init];
    UILabel *nameLable = [[UILabel alloc] init];
    
    [self.bottomView addSubview:logo];
    [self.bottomView addSubview:pagingView];
    [self.bottomView addSubview:loadingView];
    [self.bottomView addSubview:nameLable];
    
    [logo mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_bottomView.mas_centerX);
        make.width.and.height.mas_equalTo(@87);
        make.top.equalTo(_bottomView).with.offset(111);
    }];
    logo.image = [UIImage imageNamed:@"logo"];
    logo.contentMode = UIViewContentModeCenter;
    
    [pagingView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.and.right.equalTo(_bottomView);
        make.height.mas_equalTo(@275);
        make.centerY.equalTo(_bottomView.mas_centerY).with.offset(100);
    }];
    
    for (UIGestureRecognizer *gestureRecognizer in pagingView.scrollView.gestureRecognizers) {
        if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.view addGestureRecognizer:gestureRecognizer];
        }
    }
    
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make){
        
    }];
    
    [nameLable mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_bottomView.mas_centerX);
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@24);
        make.bottom.equalTo(_bottomView).with.offset(-30);
    }];
    nameLable.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:@"name"];
    [name addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:24], NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, 4)];
    nameLable.attributedText = name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
