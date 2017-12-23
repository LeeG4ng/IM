//
//  PostCell.h
//  IM
//
//  Created by Gary Lee on 2017/12/20.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface PostCell : UITableViewCell

@property (nonatomic, assign) MsgType type;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UIImageView *pictureView;

- (void)layout;
@end
