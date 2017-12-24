//
//  BubbleView.h
//  IM
//
//  Created by Gary Lee on 2017/12/23.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestView.h"

@interface BubbleView : UIImageView

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *changeBtn;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UITextField *searchBar;
@property (nonatomic, strong) RequestView *requestView;

- (void)turnOn;
- (void)turnToChangeState;
- (void)turnToSearchState;
- (void)turnToRequestState;
- (void)turnToCloseState;
@end
