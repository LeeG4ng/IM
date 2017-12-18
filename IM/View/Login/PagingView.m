//
//  PagingView.m
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "PagingView.h"
#import "Masonry.h"

@implementation PagingView

- (instancetype)init {
    if(self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.scrollView = [[UIScrollView alloc] init];
        [self addSubview:self.scrollView];
//        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, 230);
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.top.and.width.equalTo(self);
            make.height.equalTo(self).with.offset(-18);
        }];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.alwaysBounceHorizontal = YES;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];

        self.pageCtrl = [[UIPageControl alloc] init];
        [self addSubview:self.pageCtrl];
        [self.pageCtrl mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).with.offset(15);
        }];
        self.pageCtrl.numberOfPages = 2;

        
        //圆角矩形布局
        UIView *shadowView1 = [[UIView alloc] init];
        [self.scrollView addSubview:shadowView1];
        UIView *shadowView2 = [[UIView alloc] init];
        [self.scrollView addSubview:shadowView2];
        [shadowView1 mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.scrollView).with.offset(10);
            make.right.equalTo(shadowView2.mas_left).with.offset(-20);
            make.top.equalTo(self.scrollView);
            make.width.mas_equalTo(@(SCREEN_WIDTH-20));
            make.height.equalTo(self.scrollView);
        }];
        
        [shadowView2 mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.scrollView).with.offset(-10);
            make.top.equalTo(self.scrollView);
            make.width.mas_equalTo(@(SCREEN_WIDTH-20));
            make.height.equalTo(self.scrollView);
        }];
        
        self.loginView = [[UIView alloc] init];
        self.registerView = [[UIView alloc] init];
        [shadowView1 addSubview:_loginView];
        [shadowView2 addSubview:_registerView];
        [_loginView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(shadowView1);
            make.size.equalTo(shadowView1).with.sizeOffset(CGSizeMake(-20, -20));
        }];
        [_registerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(shadowView2);
            make.size.equalTo(shadowView2).with.sizeOffset(CGSizeMake(-20, -20));
        }];
        
        _loginView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.38];
        _loginView.layer.cornerRadius = 100;
        _loginView.layer.masksToBounds = YES;
        shadowView1.layer.shadowColor = [UIColor colorWithRed:0.45 green:0.38 blue:0.47 alpha:1].CGColor;
        shadowView1.layer.shadowOffset = CGSizeMake(0, 0);
        shadowView1.layer.shadowOpacity = 1;
        shadowView1.layer.shadowRadius = 8;
        
        _registerView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.38];
        _registerView.layer.cornerRadius = 100;
        _registerView.layer.masksToBounds = YES;
        shadowView2.layer.shadowColor = [UIColor colorWithRed:0.45 green:0.38 blue:0.47 alpha:1].CGColor;
        shadowView2.layer.shadowOffset = CGSizeMake(0, 0);
        shadowView2.layer.shadowOpacity = 1;
        shadowView2.layer.shadowRadius = 8;
        
        
        //文本框和按钮布局
        self.login_userName = [[TextField alloc] init];
        self.login_passWord = [[TextField alloc] init];
        self.loginBtn = [[UIButton alloc] init];
        [_loginView addSubview:_login_userName];
        [_loginView addSubview:_login_passWord];
        [_loginView addSubview:_loginBtn];
        
        self.reg_userName = [[TextField alloc] init];
        self.reg_passWord = [[TextField alloc] init];
        self.reg_passWordRepeat = [[TextField alloc] init];
        self.regBtn = [[UIButton alloc] init];
        [_registerView addSubview:_reg_userName];
        [_registerView addSubview:_reg_passWord];
        [_registerView addSubview:_reg_passWordRepeat];
        [_registerView addSubview:_regBtn];
        
        NSArray *textFieldArr = @[_login_userName, _login_passWord, _reg_userName, _reg_passWord, _reg_passWordRepeat];
        for(TextField *textField in textFieldArr) {
            textField.layer.cornerRadius = 21;
            textField.layer.masksToBounds = YES;
            textField.layer.borderColor = [UIColor whiteColor].CGColor;
            textField.layer.borderWidth = 1;
        }
        
        NSArray *userNameArr = @[_login_userName, _reg_userName];
        for(TextField *textField in userNameArr) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userName"]];
            textField.leftView = imgView;
            textField.leftViewMode = UITextFieldViewModeAlways;
        }
        
        NSArray *passWordArr = @[_login_passWord, _reg_passWord, _reg_passWordRepeat];
        for(TextField *textField in passWordArr) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passWord"]];
            textField.leftView = imgView;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.clearsOnBeginEditing = YES;
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeAlphabet;
        }
        
        NSArray *btnArr = @[_loginBtn, _regBtn];
        for(UIButton *btn in btnArr) {
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:_delegate action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 14;
        }

        [self.login_userName mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_loginView).with.offset(30);
            make.centerX.equalTo(_loginView);
            make.width.equalTo(_loginView).with.offset(-120);
            make.height.mas_equalTo(@37);
        }];
        
        [self.login_passWord mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_login_userName).with.offset(51);
            make.centerX.equalTo(_loginView);
            make.width.equalTo(_loginView).with.offset(-120);
            make.height.mas_equalTo(@37);
        }];
        
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(_loginView).with.offset(-20);
            make.centerX.equalTo(_loginView);
            make.width.mas_equalTo(@95);
            make.height.mas_equalTo(@28);
        }];
        _loginBtn.tag = 1000;
        NSAttributedString *loginName = [[NSAttributedString alloc] initWithString:@"登录" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.62 green:0.56 blue:0.71 alpha:1.00], NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:18]}];
        [_loginBtn setAttributedTitle:loginName forState:UIControlStateNormal];
        
        [self.reg_userName mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_registerView).with.offset(21);
            make.centerX.equalTo(_registerView);
            make.width.equalTo(_registerView).with.offset(-120);
            make.height.mas_equalTo(@37);
        }];
        
        [self.reg_passWord mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_reg_userName.mas_bottom).with.offset(14);
            make.centerX.equalTo(_registerView);
            make.width.equalTo(_registerView).with.offset(-120);
            make.height.mas_equalTo(@37);
        }];
        
        [self.reg_passWordRepeat mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_reg_passWord.mas_bottom).with.offset(14);
            make.centerX.equalTo(_registerView);
            make.width.equalTo(_registerView).with.offset(-120);
            make.height.mas_equalTo(@37);
        }];
        _reg_passWordRepeat.placeholder = @"repeat";
        
        [self.regBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(_registerView);
            make.centerY.equalTo(_loginBtn);
            make.size.equalTo(_loginBtn);
        }];
        _regBtn.tag = 1001;
        NSAttributedString *regName = [[NSAttributedString alloc] initWithString:@"注册" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.62 green:0.56 blue:0.71 alpha:1.00], NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:18]}];
        [_regBtn setAttributedTitle:regName forState:UIControlStateNormal];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGPoint offset = [(NSValue *)change[@"new"] CGPointValue];
    NSInteger page = (int)(offset.x/SCREEN_WIDTH+0.5)%2;
    self.pageCtrl.currentPage = page;
}

@end
