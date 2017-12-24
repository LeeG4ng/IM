//
//  NaviView.m
//  IM
//
//  Created by Gary Lee on 2017/12/23.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "NaviView.h"
#import "Masonry.h"

@implementation NaviView

- (instancetype)init {
    if(self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleView = [[UILabel alloc] init];
        self.leftBtn = [[UIButton alloc] init];
        self.rightBtn = [[UIButton alloc] init];
        [self addSubview:_titleView];
        [self addSubview:_leftBtn];
        [self addSubview:_rightBtn];
        
        
    }
    return self;
}

- (void)layout {
    [_titleView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self).with.offset(-9);
        make.height.mas_equalTo(@25);
        make.left.and.right.equalTo(self);
    }];
    
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.and.height.mas_equalTo(@34);
        make.left.equalTo(self).with.offset(15);
        make.bottom.equalTo(self).with.offset(-5);
    }];
    
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.and.height.mas_equalTo(@34);
        make.right.equalTo(self).with.offset(-15);
        make.bottom.equalTo(self).with.offset(-5);
    }];
    
    _titleView.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    _titleView.textAlignment = NSTextAlignmentCenter;
    
    if(self.holder == NaviHolderTable) {
        _titleView.text = @"消息";
        [_leftBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
        [_rightBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    }
    if(self.holder == NaviHolderChat) {
        [_leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    }
}

@end
