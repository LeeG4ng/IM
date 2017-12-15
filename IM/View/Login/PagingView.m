//
//  PagingView.m
//  IM
//
//  Created by Gary Lee on 2017/12/14.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "PagingView.h"
#import "Masonry.h"

@implementation PagingView

- (instancetype)init {
    if(self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 255)];
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, 230);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.alwaysBounceHorizontal = YES;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:self.scrollView];
        
        
        UIView *shadowView1 = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 250)];
        self.loginView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-40, 230)];
        [self.scrollView addSubview:shadowView1];
        [shadowView1 addSubview:_loginView];
        _loginView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.38];
        _loginView.layer.cornerRadius = 100;
        _loginView.layer.masksToBounds = YES;
        shadowView1.layer.shadowColor = [UIColor colorWithRed:0.45 green:0.38 blue:0.47 alpha:1].CGColor;
        shadowView1.layer.shadowOffset = CGSizeMake(0, 0);
        shadowView1.layer.shadowOpacity = 1;
        shadowView1.layer.shadowRadius = 8;
        
        UIView *shadowView2 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH+10, 0, SCREEN_WIDTH-20, 250)];
        self.registerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-40, 230)];
        [self.scrollView addSubview:shadowView2];
        [shadowView2 addSubview:_registerView];
        _registerView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.38];
        _registerView.layer.cornerRadius = 100;
        _registerView.layer.masksToBounds = YES;
        shadowView2.layer.shadowColor = [UIColor colorWithRed:0.45 green:0.38 blue:0.47 alpha:1].CGColor;
        shadowView2.layer.shadowOffset = CGSizeMake(0, 0);
        shadowView2.layer.shadowOpacity = 1;
        shadowView2.layer.shadowRadius = 8;
        
        self.pageCtrl = [[UIPageControl alloc] init];
        [self addSubview:self.pageCtrl];
        [self.pageCtrl mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).with.offset(15);
        }];
        self.pageCtrl.numberOfPages = 2;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGPoint offset = [(NSValue *)change[@"new"] CGPointValue];
    NSLog(@"%f", offset.x);
    NSInteger page = (int)(offset.x/SCREEN_WIDTH+0.5)%2;
    self.pageCtrl.currentPage = page;
}

@end
