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

static DataBaseTool *tool;
@implementation DataBaseTool

+ (instancetype)sharedDBTool {
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        tool = [[DataBaseTool alloc] init];
    });
    return tool;
}

- (FMDatabaseQueue *)dataBaseWithUser:(User *)user {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", user.userName]];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    return queue;
}

- (BOOL)addUser:(User *)user {
    FMDatabaseQueue *queue = [self dataBaseWithUser:user];
    __block BOOL res1, res2, res3;
    [queue inDatabase:^(FMDatabase *db) {
        res1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (userName TEXT,  passWord TEXT, avatar BLOB);"] && [db executeUpdate:@"insert into 'info' ('userName', passWord', 'avatar') values(?,?,?)", user.userName, user.passWord, UIImagePNGRepresentation(user.avatar)];
        res2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS friends (userName TEXT, avatar BLOB);"];
        res3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS messages (userName TEXT, content TEXT, direction INTEGER, time INTEGER);"];
    }];
    return res1&&res2&&res3;
}

- (BOOL)addFriend:(Friend *)friend OfUser:(User *)user {
    FMDatabaseQueue *queue = [self dataBaseWithUser:user];
    __block BOOL res;
    [queue inDatabase:^(FMDatabase *db) {
        res = [db executeUpdate:@"insert into 'friend' ('userName', 'avatar') values(?,?)",
               friend.userName,
               UIImagePNGRepresentation(friend.avatar)];
    }];
    return res;
}

@end
