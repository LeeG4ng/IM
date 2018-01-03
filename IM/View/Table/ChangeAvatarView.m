//
//  ChangeAvatarView.m
//  IM
//
//  Created by Gary Lee on 2017/12/27.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "ChangeAvatarView.h"

@implementation ChangeAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        
        _btn = [[UIButton alloc] init];
        _btn.backgroundColor = [UIColor colorWithRed:0.51 green:0.51 blue:0.51 alpha:1.00];
        [_btn setTitle:@"点击上传" forState:UIControlStateNormal];
        _btn.alpha = 0.55f;
        [self addSubview:_btn];
    }
    return self;
}

@end
