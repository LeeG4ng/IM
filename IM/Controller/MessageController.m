//
//  MessageController.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "MessageController.h"
#import "LoginController.h"
#import "DataBaseTool.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"
#import "LineCell.h"
#import "FriendCell.h"

@interface MessageController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) User *user;

@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息";
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.barTintColor = [UIColor whiteColor];
    [bar setShadowImage:[[UIImage alloc] init]];
    
    UITableView *friendTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    friendTable.delegate = self;
    friendTable.dataSource = self;
    friendTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendTable.backgroundColor = CATSKILL_WHITE;
    [self.view addSubview:friendTable];
    
//    [self testDataBaseWithoutNetwork];
    
    if(![self initRecentUser]) {
        LoginController *loginCtrl = [[LoginController alloc] init];
        [self presentViewController:loginCtrl animated:YES completion:nil];
    }
    
}

- (void)testDataBaseWithoutNetwork {
    DataBaseTool *tool = [DataBaseTool sharedDBTool];
    User *me = [[User alloc] init];
    me.userName = @"LG";
    me.passWord = @"123";
    me.avatar = [UIImage imageNamed:@"news"];
    tool.operatedUser = me;
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
//        [tool recordRecentUser:me];
//        [tool recordUser:me];
//        [tool recordFriend:friend];
//        [tool recordMessagesWithFriend:friend];
    });
    dispatch_barrier_async(queue, ^{
        User *new = [tool getUserWithUserName:@"LG"];
        Friend *f = new.friends.firstObject;
        Message *m = f.msgs.firstObject;
        NSLog(@"%@", m.time);
    });
    me.passWord = @"updated";
    friend.avatar = [UIImage imageNamed:@"msg"];
    dispatch_async(queue, ^{
//        [tool updateUserInfo:me];
//        [tool updateFriendInfo:friend];
    });
}

#pragma mark - Configure Data
- (BOOL)initRecentUser {
    self.user = [User currentUser];
    DataBaseTool *tool = [DataBaseTool sharedDBTool];
    self.user = [tool getRecentUser];
    if(self.user) {
        NSLog(@"Loaded recent user.");
        return YES;
    }
    NSLog(@"No recent user.");
    return NO;//没有最近登陆用户记录时返回NO
}

#pragma mark - Table View Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0) {
        static NSString * friendCellID = @"friendCellID";
        FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:friendCellID];
        if(!friendCell) {
            friendCell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCellID];
        }
        [self configDataOfCell:friendCell withIndex:indexPath.row/2];
        return friendCell;
    } else {
        static NSString * lineCellID = @"lineCellID";
        LineCell *line = [tableView dequeueReusableCellWithIdentifier:lineCellID];
        if(!line) {
            line = [[LineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lineCellID];
        }
        return line;
    }
}

- (FriendCell *)configDataOfCell:(FriendCell *)cell withIndex:(NSInteger)index {
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0) {
        return 68;
    } else {
        return 0.5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2*10;
}

@end
