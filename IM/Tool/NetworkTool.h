//
//  NetworkTool.h
//  IM
//
//  Created by Gary Lee on 2017/12/22.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;
@class Friend;
@class Message;

@interface NetworkTool : NSObject

+ (instancetype)sharedNetTool;

//用户操作
- (void)registerWithUser:(User *)user;//注册成功返回nil，失败返回错误描述
- (void)loginWithUser:(User *)user;//注册成功返回nil，失败返回错误描述
- (void)getCurrentAvatar;//获取用户当前头像
- (void)changeAvatar:(UIImage *)avatar;//更换头像

//好友操作
- (void)getFriendsList;//获取好友列表
- (void)getFriendRequestHistory;//获取离线时收到的好友请求
- (void)sendFriendRequestWithName:(NSString *)userName;//发出好友请求
- (void)deleteFriendWithName:(NSString *)userName;//删除好友
- (void)disposeFriendRequest:(BOOL)dispose ID:(NSString *)id;//处理好友请求

//消息处理
- (void)sendMessage:(Message *)msg toFriend:(NSString *)userName;//发送消息
- (void)getMessageHistorySince:(NSTimeInterval)time;//获取从参数时间开始的历史消息

@end
