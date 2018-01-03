//
//  BubbleView.m
//  IM
//
//  Created by Gary Lee on 2017/12/23.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "BubbleView.h"
#import "Masonry.h"
#import "User.h"

@implementation BubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.image = [UIImage imageNamed:@"bubble"];
        self.userInteractionEnabled = YES;
        _addBtn = [[UIButton alloc] init];
        _changeBtn = [[UIButton alloc] init];
        _confirmBtn = [[UIButton alloc] init];
        _searchBar = [[UITextField alloc] init];
        _requestView = [[RequestView alloc] init];
        _avatarView = [[ChangeAvatarView alloc] init];
        _avatarLabel = [[UILabel alloc] init];
        
        [self addSubview:_addBtn];
        [self addSubview:_changeBtn];
        [self addSubview:_confirmBtn];
        [self addSubview:_searchBar];
        [self addSubview:_requestView];
        [self addSubview:_avatarView];
        [self addSubview:_avatarLabel];
        
        for(UIView *subview in self.subviews) {
            subview.frame = SUBVIEW_ORIGIN;
        }
        
        [_addBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        [_changeBtn setTitle:@"更改头像" forState:UIControlStateNormal];
        
        _searchBar.layer.cornerRadius = 19;
        _searchBar.layer.masksToBounds = YES;
        _searchBar.layer.borderColor = [UIColor whiteColor].CGColor;
        _searchBar.layer.borderWidth = 1;
        _searchBar.textAlignment = NSTextAlignmentCenter;
        _searchBar.textColor = [UIColor whiteColor];
        _searchBar.placeholder = @"搜索";
        
        _avatarView.image = [User currentUser].avatar;
        _avatarView.layer.cornerRadius = 65;
        _avatarView.layer.masksToBounds = YES;
        
        _avatarLabel.text = @"更换头像";
        _avatarLabel.textColor = [UIColor whiteColor];
        _avatarLabel.font = [UIFont systemFontOfSize:22];
        _avatarLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)turnOn {
    [UIView animateWithDuration:0.3f animations:^{
        _addBtn.frame = CGRectMake(36, 24, 80, 14);
        _changeBtn.frame = CGRectMake(36, 54, 80, 14);
    }];
}

- (void)turnToChangeState {
    [UIView animateWithDuration:0.3f animations:^{
        _addBtn.frame = SUBVIEW_ORIGIN;
        _changeBtn.frame = SUBVIEW_ORIGIN;
        _avatarView.frame = CGRectMake(107, 90, 130, 130);
        _avatarView.btn.frame = CGRectMake(0, 0, 130, 130);
        _avatarLabel.frame = CGRectMake(128, 27, 100, 22);
    }];
}

- (void)turnToSearchState {
    [UIView animateWithDuration:0.3f animations:^{
        _addBtn.frame = SUBVIEW_ORIGIN;
        _changeBtn.frame = SUBVIEW_ORIGIN;
        _searchBar.frame = CGRectMake(50, 28, self.frame.size.width-100, 38);
    }];
}

- (void)turnToRequestState {
    [UIView animateWithDuration:0.3f animations:^{
        _addBtn.frame = SUBVIEW_ORIGIN;
        _changeBtn.frame = SUBVIEW_ORIGIN;
        _searchBar.frame = CGRectMake(50, 28, self.frame.size.width-100, 38);
    }];
    
}

- (void)turnToCloseState {
    for(UIView *subview in self.subviews) {
        subview.frame = SUBVIEW_ORIGIN;
    }
    _avatarView.btn.frame = SUBVIEW_ORIGIN;
}

@end
