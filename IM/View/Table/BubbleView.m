//
//  BubbleView.m
//  IM
//
//  Created by Gary Lee on 2017/12/23.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "BubbleView.h"
#import "Masonry.h"

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
        
        [self addSubview:_addBtn];
        [self addSubview:_changeBtn];
        [self addSubview:_confirmBtn];
        [self addSubview:_searchBar];
        [self addSubview:_requestView];
        
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
}

@end
