//
//  DataBaseTool.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "DataBaseTool.h"
#import "FMDB.h"
#import "NetworkTool.h"
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

#pragma mark - Get Queue
//获得记录最近用户的队列
- (FMDatabaseQueue *)getRecentUserQueue {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"recent.sqlite"]];
    NSLog(@"recent user db ----path    %@", path);
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    return queue;
}

//以UserName获取一个数据库队列
- (FMDatabaseQueue *)getQueueWithUserName:(NSString *)name {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", name]];
    NSLog(@"user db ----path    %@", path);
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    return queue;
}

- (FMDatabaseQueue *)queue {
//    if(!_queue) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
        NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.operatedUser.userName]];
        NSLog(@"path    %@", path);
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
//    }
    return _queue;
}

#pragma mark - Record Data
- (BOOL)recordRecentUser:(User *)user {
    FMDatabaseQueue *queue = [self getRecentUserQueue];
    __block BOOL res;
    [queue inDatabase:^(FMDatabase *db){
        res = [db executeUpdate:@"CREATE TABLE IF NOT EXISIT recentUser (userName TEXT);"]
        && [db executeUpdate:@"delete from table 'recentUser'"]
        && [db executeUpdate:@"insert into 'recentUser' ('userName') values(?)", user.userName];
    }];
    return res;
}

- (BOOL)recordUser:(User *)user {
    __block BOOL res1, res2, res3;
    [self.queue inDatabase:^(FMDatabase *db) {
        res1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (userName TEXT, passWord TEXT, avatar BLOB);"] && [db executeUpdate:@"insert into 'info' ('userName', 'passWord', 'avatar') values(?,?,?)", user.userName, user.passWord, UIImagePNGRepresentation(user.avatar)];
        res2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS friends (userName TEXT, avatar BLOB, unread INTEGER);"];
        res3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS messages (friendName TEXT, content TEXT, picture BLOB, direction INTEGER, type INTEGER, time DATETIME);"];
    }];
    return res1&&res2&&res3;
}

- (BOOL)recordFriend:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db) {
        res = [db executeUpdate:@"insert into 'friends' ('userName', 'avatar', 'unread') values(?,?,?)",
               friend.userName,
               UIImagePNGRepresentation(friend.avatar),
               @(friend.unread)];
    }];
    return res;
}

- (BOOL)recordAllMessagesWithFriend:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL tempRes;
        for(Message *msg in friend.msgs) {
            tempRes = [db executeUpdate:@"insert into 'messages' ('friendName', 'content', 'picture','direction', 'type', 'time') values(?,?,?,?,?,?)", friend.userName, msg.content, UIImagePNGRepresentation(msg.picture), @(msg.direction), @(msg.type), @(msg.time.timeIntervalSince1970)];
            res = res && tempRes;
        }
    }];
    return res;
}

- (BOOL)recordMessage:(Message *)msg ofFriend:(Friend *)friend {
    __block BOOL res;
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL tempRes;
        tempRes = [db executeUpdate:@"insert into 'messages' ('friendName', 'content', 'picture', 'direction', 'type', 'time') values(?,?,?,?,?,?)", friend.userName, msg.content, UIImagePNGRepresentation(msg.picture), @(msg.direction), @(msg.type), @(msg.time.timeIntervalSince1970)];
            res = res && tempRes;
    }];
    return res;
}

#pragma mark - Fetch Data
- (User *)getRecentUser {
    User *user = [[User alloc] init];
    __block FMResultSet *userSet;
    [[self getRecentUserQueue] inDatabase:^(FMDatabase *db){
        userSet = [db executeQuery:@"select * from 'recentUser'"];
        while([userSet next]) {
            user.userName = [userSet stringForColumn:@"userName"];
        }
    }];
    user = [self getUserWithUserName:user.userName];
    return user;
}

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
        friend.avatar = [UIImage imageWithData:[friendSet dataForColumn:@"avatar"]];
        friend.unread = [friendSet intForColumn:@"unread"];
        [user.friends addObject:friend];
    }
    //获得message数据
    NSMutableArray *tempMsgArr = [NSMutableArray array];
    while ([msgSet next]) {
        Message *msg = [[Message alloc] init];
        msg.friendName = [msgSet stringForColumn:@"friendName"];
        msg.content = [msgSet stringForColumn:@"content"];
        msg.picture = [UIImage imageWithData:[msgSet dataForColumn:@"picture"]];
        if([msgSet intForColumn:@"type"]) {
            msg.type = MsgPicture;
        } else {
            msg.type = MsgText;
        }
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
        res = [db executeUpdate:@"update 'friends' set avatar=?, unread=? where userName=?", UIImagePNGRepresentation(friend.avatar), @(friend.unread), friend.userName];
    }];
    return res;
}

#pragma mark - Update Database From Netsever
@end
