//
//  Friend.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "Friend.h"

@implementation Friend

- (NSMutableArray *)msgs {
    if (!_msgs) {
        _msgs = [NSMutableArray array];
    }
    return _msgs;
}

@end
