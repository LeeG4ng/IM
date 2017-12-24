//
//  ReceiveCell.m
//  IM
//
//  Created by Gary Lee on 2017/12/20.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "ReceiveCell.h"
#import "Masonry.h"

@implementation ReceiveCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = CATSKILL_WHITE;
        
        _avatarView = [[UIImageView alloc] init];
        _bubbleView = [[UIImageView alloc] init];
        _textLable = [[UILabel alloc] init];
        _pictureView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_avatarView];
        [self.contentView addSubview:_bubbleView];
        [_bubbleView addSubview:_textLable];
        [_bubbleView addSubview:_pictureView];
        
        _avatarView.layer.cornerRadius = 20;
        _avatarView.layer.masksToBounds = YES;
        
        _textLable.numberOfLines = 0;
        _textLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        
        _pictureView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)layout {
    if(_type == MsgText) {
        [_textLable mas_remakeConstraints:^(MASConstraintMaker *make){
            make.width.mas_lessThanOrEqualTo(@(BUBBLE_MAX_WIDTH));
            make.edges.equalTo(_bubbleView).with.insets(UIEdgeInsetsMake(20, 26, 22, 26));
        }];
        [_pictureView mas_remakeConstraints:^(MASConstraintMaker *make){}];
    }
    if(_type == MsgPicture) {
        [_pictureView mas_remakeConstraints:^(MASConstraintMaker *make){
            make.width.mas_lessThanOrEqualTo(@(BUBBLE_MAX_WIDTH));
            make.height.equalTo(_pictureView.mas_width).with.multipliedBy(_pictureView.image.size.height/_pictureView.image.size.width);
            make.edges.equalTo(_bubbleView).with.insets(UIEdgeInsetsMake(20, 26, 22, 26));
        }];
        [_textLable mas_remakeConstraints:^(MASConstraintMaker *make){}];
    }
    
    [_avatarView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView).with.offset(15);
        make.top.equalTo(self.contentView).with.offset(10);
        make.width.and.height.mas_equalTo(@40);
    }];
    
    [_bubbleView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(_avatarView.mas_right).with.offset(15);
        make.top.equalTo(self.contentView).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
    
    //拉伸气泡
    UIImage *bubble = [UIImage imageNamed:@"receive"];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(35, 35, 35, 35);
    bubble = [bubble resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    _bubbleView.image = bubble;
}


@end
