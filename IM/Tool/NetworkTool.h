//
//  NetworkTool.h
//  IM
//
//  Created by Gary Lee on 2017/12/22.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Friend;
@class Message;

@interface NetworkTool : NSObject

+ (instancetype)sharedNetTool;

//用户操作
- (void)registerWithUser:(User *)user;//注册成功返回nil，失败返回错误描述
- (void)loginWithUser:(User *)user;//注册成功返回nil，失败返回错误描述

//好友操作
- (void)getFriendsList;//获取好友列表
- (void)sendFriendRequestWithName:(NSString *)userName;
- (void)deleteFriendWithName:(NSString *)userName;
- (void)disposeFriendRequest;

//消息处理


@end
