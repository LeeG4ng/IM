//
//  MessageController.m
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "MessageController.h"
#import "LoginController.h"
#import "ChatController.h"
#import "DataBaseTool.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"
#import "LineCell.h"
#import "FriendCell.h"
#import "SocketRocket.h"

@interface MessageController () <UITableViewDelegate, UITableViewDataSource, ConfigureAfterLogin>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UITableView *friendTable;

@end

@implementation MessageController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.friendTable reloadData];
}

- (void)viewDidLoad {
    LoginController *loginCtrl = [[LoginController alloc] init];
    [self presentViewController:loginCtrl animated:NO completion:nil];
    loginCtrl.delegate = self;

    [super viewDidLoad];
    
    self.navigationItem.title = @"消息";
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.barTintColor = [UIColor whiteColor];
    [bar setShadowImage:[[UIImage alloc] init]];
    
    UITableView *friendTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.friendTable = friendTable;
    friendTable.delegate = self;
    friendTable.dataSource = self;
    friendTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendTable.backgroundColor = CATSKILL_WHITE;
    [self.view addSubview:friendTable];
    
//    [self testDataBaseWithoutNetwork];
    if([self initRecentUser]) {
        loginCtrl.pagingView.hidden = YES;
        loginCtrl.loadingView.hidden = NO;
    } else {
        loginCtrl.pagingView.hidden = NO;
        loginCtrl.loadingView.hidden = YES;
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
    msg.type = MsgText;
    msg.time = [NSDate dateWithTimeIntervalSince1970:1000];
    [friend.msgs addObject:msg];
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
//        [tool recordRecentUser:me];
        [tool recordUser:me];
        [tool recordFriend:friend];
        [tool recordAllMessagesWithFriend:friend];
    });
//    dispatch_barrier_async(queue, ^{
//        User *new = [tool getUserWithUserName:@"LG"];
//        Friend *f = new.friends.firstObject;
//        Message *m = f.msgs.firstObject;
//        NSLog(@"%@", m.time);
//    });
//    me.passWord = @"updated";
//    friend.avatar = [UIImage imageNamed:@"msg"];
//    dispatch_async(queue, ^{
//        [tool updateUserInfo:me];
//        [tool updateFriendInfo:friend];
//    });
}



#pragma mark - Configure Data
- (BOOL)initRecentUser {
    self.user = [User currentUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserResponse" object:[User currentUser].response];
    DataBaseTool *dbTool = [DataBaseTool sharedDBTool];
    User *tempUser = [dbTool getRecentUser];
    if(tempUser) {
        NSLog(@"Loaded recent user.");
        return YES;
    }
    NSLog(@"No recent user.");
    return NO;//没有最近登陆用户记录时返回NO
}

- (void)configAfterLogin {
//    Friend *friend = self.user.friends[0];
//    NSLog(@"self.user = %@", friend.avatar);
}

#pragma mark - Table View Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0) {
        static NSString * friendCellID = @"friendCellID";
        FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:friendCellID];
        if(!friendCell) {
            friendCell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCellID];
        }
        friendCell = [self configDataOfCell:friendCell withIndex:indexPath.row/2];
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
    Friend *friend = self.user.friends[index];
    cell.image.image = friend.avatar;
    cell.name.text = friend.userName;
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
    return 2*self.user.friends.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatController *chatCtrl = [[ChatController alloc] init];
    chatCtrl.view.backgroundColor = CATSKILL_WHITE;
    chatCtrl.friendIndex = indexPath.row/2;
    chatCtrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatCtrl animated:YES];
}

@end
