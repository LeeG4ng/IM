//
//  DataBaseTool.h
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Friend;
@class Message;

@interface DataBaseTool : NSObject

//使用前需设定操作的User
@property (nonatomic, strong) User *operatedUser;

+ (instancetype)sharedDBTool;

//记录数据
- (BOOL)recordRecentUser:(User *)user;//记录最近登陆的用户
- (BOOL)recordUser:(User *)user;//记录用户数据
- (BOOL)recordFriend:(Friend *)friend;//记录好友数据
- (BOOL)recordAllMessagesWithFriend:(Friend *)friend;//记录与该好友的全部消息
- (BOOL)recordMessage:(Message *)msg ofFriend:(Friend *)friend;//记录好友的该条消息

//获取数据
- (User *)getRecentUser;//获得最近登陆的用户
- (User *)getUserWithUserName:(NSString *)userName;//由userName获取用户实例,userName不存在返回nil

//删除数据
- (BOOL)deleteFriendAndMessages:(Friend *)friend;//删除好友及与该好友的聊天记录

//更新数据
- (BOOL)updateUserInfo:(User *)user;//更新用户数据：头像、密码
- (BOOL)updateFriendInfo:(Friend *)friend;//更新好友数据：头像

//从网络更新数据


@end
