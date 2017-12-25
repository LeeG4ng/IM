//
//  LoginController.m
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "LoginController.h"
#import "UIResponder+FirstResponder.h"
#import "Masonry.h"
#import "DataBaseTool.h"
#import "NetworkTool.h"
#import "User.h"
#import "SocketRocket.h"
#import "AFNetworking.h"

@interface LoginController () <ClickBtn>

@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) SRWebSocket *ws;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
    [self layout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeResponse:) name:@"UserResponse" object:nil];
    
}

- (void)layout {
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
    pagingView.hidden = YES;
    
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
    
    self.pagingView = pagingView;
    self.loadingView = loadingView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)hideKeyboard {
    NSLog(@"tap gesture");
    id responder = [UIResponder currentFirstResponder];
    if([responder isKindOfClass:[UITextField class]] || [responder isKindOfClass:[UITextView class]]) {
        UIView *view = responder;
        [view resignFirstResponder];
    }
}

#pragma mark - Operation On User
- (void)didClickBtn:(UIButton *)btn {
    NSLog(@"clickbtn");
    
    DataBaseTool *dbTool = [DataBaseTool sharedDBTool];
    NetworkTool *netTool = [NetworkTool sharedNetTool];
    
    //登录操作
    if(btn.tag == 1000) {
        /*
        User *tempUser = [dbTool getUserWithUserName:self.pagingView.login_userName.text];
        if(tempUser == nil) {//用户名不存在
            UIAlertController *loginUserNameAlert = [UIAlertController alertControllerWithTitle:@"用户不存在" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [loginUserNameAlert addAction:okAction];
            [self presentViewController:loginUserNameAlert animated:YES completion:nil];
        } else if(tempUser.passWord == self.pagingView.login_passWord.text) {//密码正确
            [[User currentUser] setCurrentUserWithUser:tempUser];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {//密码错误
            UIAlertController *loginPassWordAlert = [UIAlertController alertControllerWithTitle:@"密码错误" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [loginPassWordAlert addAction:okAction];
            [self presentViewController:loginPassWordAlert animated:YES completion:nil];
        }
        */
        User *tempuser = [[User alloc] init];
        tempuser.userName = self.pagingView.login_userName.text;
        tempuser.passWord = self.pagingView.login_passWord.text;
        [netTool loginWithUser:tempuser];
        
    }
    
    //注册操作
    if(btn.tag == 1001) {
        if([self.pagingView.reg_passWord.text isEqualToString:self.pagingView.reg_passWordRepeat.text]) {
            User *tempuser = [[User alloc] init];
            tempuser.userName = self.pagingView.reg_userName.text;
            tempuser.passWord = self.pagingView.reg_passWord.text;
            [netTool registerWithUser:tempuser];
        } else {
            UIAlertController *regPassWordAlert = [UIAlertController alertControllerWithTitle:@"密码不一致" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [regPassWordAlert addAction:okAction];
            [self presentViewController:regPassWordAlert animated:YES completion:nil];
        }
    }
    
    [self.delegate configAfterLogin];
}

- (void)observeResponse:(NSNotification *)notification {
    NSString *response = notification.object;
    if(response) {
        if([response isEqualToString:@"success"]) {//
            NSLog(@"success");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"%@", response);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:response message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

@end
