//
//  LoginController.m
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "LoginController.h"
#import "UIResponder+FirstResponder.h"
#import "PagingView.h"
#import "LoadingView.h"
#import "Masonry.h"

@interface LoginController () <ClickBtn>

@property (nonatomic, strong) UIImageView *bottomView;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
    
    self.bottomView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_bottomView];
    _bottomView.image = [UIImage imageNamed:@"background"];
    _bottomView.contentMode = UIViewContentModeScaleAspectFill;
    _bottomView.userInteractionEnabled = YES;
    
    UIImageView *logo = [[UIImageView alloc] init];
    PagingView *pagingView = [[PagingView alloc] init];
    pagingView.delegate = self;
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
            gestureRecognizer.cancelsTouchesInView = NO;
            [self.view addGestureRecognizer:gestureRecognizer];
        }
    }
    
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(pagingView);
        make.width.equalTo(_bottomView).with.offset(-40);
        make.centerX.equalTo(_bottomView);
        make.height.mas_equalTo(@162);
    }];
    loadingView.hidden = YES;
    
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

- (void)hideKeyboard {
    NSLog(@"hide");
    id responder = [UIResponder currentFirstResponder];
    if([responder isKindOfClass:[UITextField class]] || [responder isKindOfClass:[UITextView class]]) {
        UIView *view = responder;
        [view resignFirstResponder];
    }
}

- (void)didClickBtn:(UIButton *)btn {
    NSLog(@"clickbtn");
}
@end
