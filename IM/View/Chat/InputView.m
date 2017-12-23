//
//  InputView.m
//  IM
//
//  Created by Gary Lee on 2017/12/19.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "InputView.h"
#import "Masonry.h"

@implementation InputView

- (instancetype)init {
    if(self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.82];
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowColor = [UIColor colorWithRed:0.67 green:0.63 blue:0.67 alpha:1.00].CGColor;
        self.layer.shadowRadius = 8;
        
        self.textView = [[UITextView alloc] init];
        self.imgBtn = [[UIButton alloc] init];
        self.sendBtn = [[UIButton alloc] init];
        
        [self addSubview:_textView];
        [self addSubview:_imgBtn];
        [self addSubview:_sendBtn];
        
        _textView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _textView.layer.cornerRadius = 20;
        _textView.layer.masksToBounds = YES;
        _textView.textContainerInset = UIEdgeInsetsMake(8, 20, 8, 20);
        
        [_imgBtn setImage:[UIImage imageNamed:@"imgBtn"] forState:UIControlStateNormal];
        [_sendBtn setImage:[UIImage imageNamed:@"sendBtn"] forState:UIControlStateNormal];
        [_imgBtn addTarget:_delegate action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_sendBtn addTarget:_delegate action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        _imgBtn.tag = 2000;
        _sendBtn.tag = 2001;
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self).with.offset(1);
            make.centerY.equalTo(self);
            make.right.equalTo(_imgBtn.mas_left).with.offset(-25);
            make.height.mas_equalTo(@40);
        }];
        
        [_imgBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.and.height.mas_equalTo(@28);
            make.bottom.equalTo(self).with.offset(-9);
            make.right.equalTo(_sendBtn.mas_left).with.offset(-15);
        }];
        
        [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.and.height.mas_equalTo(@28);
            make.right.equalTo(self).with.offset(-15);
            make.bottom.equalTo(self).with.offset(-9);
        }];
    }
    return self;
}

@end
