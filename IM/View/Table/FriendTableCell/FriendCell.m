//
//  FriendCell.m
//  IM
//
//  Created by Gary Lee on 2017/12/13.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "FriendCell.h"
#import "Masonry.h"

@implementation FriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _image = [[UIImageView alloc] init];
        [self.contentView addSubview:_image];
        _name = [[UILabel alloc] init];
        [self.contentView addSubview:_name];
        _msg = [[UILabel alloc] init];
        [self.contentView addSubview:_msg];
        _time = [[UILabel alloc] init];
        [self.contentView addSubview:_time];
        _bubble = [[UIView alloc] init];
        [self.contentView addSubview:_bubble];
        _num = [[UILabel alloc] init];
        [_bubble addSubview:_num];
        
        [_image mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView).with.offset(15);
            make.top.equalTo(self.contentView).with.offset(9);
            make.width.and.height.mas_equalTo(@50);
        }];
        _image.contentMode = UIViewContentModeScaleAspectFill;
        _image.layer.cornerRadius = 25;
        _image.layer.masksToBounds = YES;
        
        [_name mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView).with.offset(80);
            make.top.equalTo(self.contentView).with.offset(9);
            make.width.mas_equalTo(@175);
            make.height.mas_equalTo(@25);
        }];
        _name.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];

        [_msg mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_name.mas_bottom).with.offset(2);
            make.left.equalTo(self.contentView).with.offset(80);
            make.height.mas_equalTo(@17);
            make.right.equalTo(_bubble.mas_left).with.offset(-8);
        }];
        _msg.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        _msg.textColor = STAR_DUST;

        [_time mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.contentView).with.offset(14);
            make.right.equalTo(self.contentView).with.offset(-15);
            make.height.mas_equalTo(@14);
            make.width.mas_equalTo(@70);
        }];
        _time.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
        _time.textAlignment = NSTextAlignmentRight;
        _time.textColor = DARK_GRAY;
        
        [_bubble mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.contentView).with.offset(-15);
            make.top.equalTo(_time.mas_bottom).with.offset(8);
            make.width.mas_equalTo(@25);
            make.height.mas_equalTo(@18);
        }];
        _bubble.backgroundColor = PRELUDE;
        _bubble.layer.cornerRadius = 9;
        _bubble.layer.masksToBounds = YES;
        
        [_num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_bubble);
            make.height.mas_equalTo(@15);
            make.width.mas_equalTo(@20);
        }];
        _num.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        _num.textColor = [UIColor whiteColor];
        _num.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


@end
