//
//  PagingView.h
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UIView *registerView;
@property (nonatomic, strong) UIPageControl *pageCtrl;

@end
