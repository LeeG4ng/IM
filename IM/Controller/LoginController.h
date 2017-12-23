//
//  LoginController.h
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagingView.h"
#import "LoadingView.h"
@class User;

@interface LoginController : UIViewController

@property (nonatomic, strong) PagingView *pagingView;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, weak) id delegate;

@end

@protocol ConfigureAfterLogin
- (void)configAfterLogin;
@end
