//
//  FriendCell.h
//  IM
//
//  Created by Gary Lee on 2017/12/13.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *msg;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIView *bubble;
@property (nonatomic, strong) UILabel *num;

@end
