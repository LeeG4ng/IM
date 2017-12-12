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
@property (nonatomic, strong) User *user;

+ (instancetype)sharedDBTool;

//记录数据
- (BOOL)recordUser:(User *)user;//记录用户数据
- (BOOL)recordFriend:(Friend *)friend;//记录好友数据
- (BOOL)recordMessagesWithFriend:(Friend *)friend;//记录与该好友的全部消息
- (BOOL)recordMessage:(Message *)msg ofFriend:(Friend *)friend;//记录好友的该条消息

//获取数据
- (User *)getUserWithUserName:(NSString *)userName;//由userName获取User实例,userName不存在返回nil

@end
