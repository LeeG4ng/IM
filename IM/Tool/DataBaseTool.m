//
//  DataBaseTool.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "DataBaseTool.h"
#import "FMDB.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"

@interface DataBaseTool ()

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end
static DataBaseTool *tool;

@implementation DataBaseTool

+ (instancetype)sharedDBTool {
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        tool = [[DataBaseTool alloc] init];
    });
    return tool;
}

//以UserName获取一个数据库队列
- (FMDatabaseQueue *)getQueueWithUserName:(NSString *)name {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", name]];
    NSLog(@"path    %@", path);
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    return queue;
}
- (FMDatabaseQueue *)queue {
    if(!_queue) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
        NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.operatedUser.userName]];
        NSLog(@"path    %@", path);
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return _queue;
}

#pragma mark - Record Data
- (BOOL)recordUser:(User *)user {
    __block BOOL res1, res2, res3;
    [self.queue inDatabase:^(FMDatabase *db) {
        res1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (userName TEXT, passWord TEXT, avatar BLOB);"] && [db executeUpdate:@"insert into 'info' ('userName', 'passWord', 'avatar') values(?,?,?)", user.userName, user.passWord, UIImagePNGRepresentation(user.avatar)];
        res2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS friends (userName TEXT, avatar BLOB);"];
        res3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS messages (friendName TEXT, content TEXT, direction INTEGER, time DATETIME);"];
    }];
    return res1&&res2&&res3;
}

- (BOOL)recordFriend:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db) {
        res = [db executeUpdate:@"insert into 'friends' ('userName', 'avatar') values(?,?)",
               friend.userName,
               UIImagePNGRepresentation(friend.avatar)];
    }];
    return res;
}

- (BOOL)recordMessagesWithFriend:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL tempRes;
        for(Message *msg in friend.msgs) {
            tempRes = [db executeUpdate:@"insert into 'messages' ('friendName', 'content', 'direction', 'time') values(?,?,?,?)", friend.userName, msg.content, @(msg.direction), @(msg.time.timeIntervalSince1970)];
            res = res && tempRes;
        }
    }];
    return res;
}

- (BOOL)recordMessage:(Message *)msg ofFriend:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL tempRes;
        tempRes = [db executeUpdate:@"insert into 'messages' ('friendName', 'content', 'direction', 'time') values(?,?,?,?)", friend.userName, msg.content, @(msg.direction) , @(msg.time.timeIntervalSince1970)];
            res = res && tempRes;
    }];
    return res;
}

#pragma mark - Fetch Data
- (User *)getUserWithUserName:(NSString *)userName {
    User *user = [[User alloc] init];
    __block FMResultSet *userSet;
    __block FMResultSet *friendSet;
    __block FMResultSet *msgSet;
    [[self getQueueWithUserName:userName] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        userSet = [db executeQuery:@"select * from 'info'"];
        friendSet = [db executeQuery:@"select * from 'friends'"];
        msgSet = [db executeQuery:@"select * from 'messages' order by time desc"];//默认升序 加desc降序
    }];
    if(!userSet)
        return nil;
    //获得user数据
    while ([userSet next]) {
        user.userName = userName;
        user.passWord = [userSet stringForColumn:@"passWord"];
        user.avatar = [UIImage imageWithData:[userSet dataForColumn:@"avatar"]];
    }
    //获得friend数据
    while ([friendSet next]) {
        Friend *friend = [[Friend alloc] init];
        friend.userName = [friendSet stringForColumn:@"userName"];
        friend.avatar = [UIImage imageWithData:[userSet dataForColumn:@"avatar"]];
        [user.friends addObject:friend];
    }
    //获得message数据
    NSMutableArray *tempMsgArr = [NSMutableArray array];
    while ([msgSet next]) {
        Message *msg = [[Message alloc] init];
        msg.friendName = [msgSet stringForColumn:@"friendName"];
        msg.content = [msgSet stringForColumn:@"content"];
        if([msgSet intForColumn:@"direction"]) {
            msg.direction = MsgPost;
        } else {
            msg.direction = MsgReceive;
        }
        msg.time = [msgSet dateForColumn:@"time"];
        [tempMsgArr addObject:msg];
    }
    for(Friend *friend in user.friends) {
        for(Message *msg in tempMsgArr) {
            if ([friend.userName isEqualToString:msg.friendName]) {
                [friend.msgs addObject:msg];
            }
        }
    }
    [userSet close];
    [friendSet close];
    [msgSet close];
    user.userName = userName;
    return user;
}

#pragma mark - Delete Data
- (BOOL)deleteFriendAndMessages:(Friend *)friend {
    __block BOOL res;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        res = [db executeUpdate:@"delete from 'friends' where userName = ?", friend.userName];
        res = res && [db executeUpdate:@"delete from 'messages' where friendName = ?", friend.userName];
    }];
    return res;
}

#pragma mark - Update Data
- (BOOL)updateUserInfo:(User *)user {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db){
        res = [db executeUpdate:@"update 'info' set passWord=?, avatar=?", user.passWord, UIImagePNGRepresentation(user.avatar)];
    }];
    return res;
}

- (BOOL)updateFriendInfo:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db){
        res = [db executeUpdate:@"update 'info' set avatar=? where userName=?", UIImagePNGRepresentation(friend.avatar), friend.userName];
    }];
    return res;
}
@end
