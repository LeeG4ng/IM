//
//  MessageController.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "MessageController.h"
#import "DataBaseTool.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"

@interface MessageController ()

@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self testDataBaseWithoutNetwork];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testDataBaseWithoutNetwork {
    DataBaseTool *tool = [DataBaseTool sharedDBTool];
    User *me = [[User alloc] init];
    me.userName = @"LG";
    me.passWord = @"123";
    me.avatar = [UIImage imageNamed:@"news"];
    tool.user = me;
    Friend *friend = [[Friend alloc] init];
    friend.userName = @"xx";
    friend.avatar = [UIImage imageNamed:@"news"];
    [me.friends addObject:friend];
    Message *msg= [[Message alloc] init];
    msg.content = @"test";
    msg.direction = MsgPost;
    msg.time = [NSDate dateWithTimeIntervalSince1970:1000];
    [friend.msgs addObject:msg];
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [tool recordUser:me];
        [tool recordFriend:friend];
        [tool recordMessagesWithFriend:friend];
    });
    dispatch_barrier_async(queue, ^{
        User *new = [tool getUserWithUserName:@"LG"];
        Friend *f = new.friends.firstObject;
        Message *m = f.msgs.firstObject;
        NSLog(@"%@", m.time);
    });
}

@end
