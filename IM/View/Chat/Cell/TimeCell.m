//
//  TimeCell.m
//  IM
//
//  Created by Gary Lee on 2017/12/20.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "TimeCell.h"
#import "Masonry.h"

@implementation TimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        _timeLable = [[UILabel alloc] init];
        [self.contentView addSubview:_timeLable];
        _timeLable.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        _timeLable.textColor = [UIColor colorWithRed:0.63 green:0.63 blue:0.63 alpha:1.00];
        _timeLable.textAlignment = NSTextAlignmentCenter;
        
    }
    return self;
}

- (void)layout {
    [_timeLable mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.lessThanOrEqualTo(self.contentView);
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).with.offset(14);
        make.bottom.equalTo(self.contentView);
    }];
}

@end
