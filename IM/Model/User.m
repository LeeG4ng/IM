//
//  User.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "User.h"

static User *user;
@implementation User

+ (instancetype)currentUser {
    static dispatch_once_t user_oncetoken;
    dispatch_once(&user_oncetoken, ^{
        user = [[User alloc] init];
    });
    return user;
}

- (NSMutableArray *)friends {
    if (!_friends) {
        _friends = [NSMutableArray array];
    }
    return _friends;
}

@end
