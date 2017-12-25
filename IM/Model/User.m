//
//  User.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "User.h"
#import "Friend.h"

static User *user;
@implementation User

+ (instancetype)currentUser {
    static dispatch_once_t user_oncetoken;
    dispatch_once(&user_oncetoken, ^{
        user = [[User alloc] init];
    });
    return user;
}

- (void)setCurrentUserWithUser:(User *)currentUser {
    self.userName = currentUser.userName;
    self.passWord = currentUser.passWord;
    self.avatar = currentUser.avatar;
    self.friends = currentUser.friends;
}

- (NSMutableArray *)friends {
    if (!_friends) {
        _friends = [NSMutableArray array];
    }
    return _friends;
}

- (NSArray *)friendNames {
    NSMutableArray *arr = [NSMutableArray array];
    for(Friend *friend in _friends) {
        [arr addObject:friend.userName];
    }
    return arr;
}

@end
