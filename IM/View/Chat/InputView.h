//
//  InputView.h
//  IM
//
//  Created by Gary Lee on 2017/12/19.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputView : UIView

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *imgBtn;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, weak) id delegate;

@end

@protocol ClickBtn
- (void)didClickBtn:(UIButton *)btn;
@end
