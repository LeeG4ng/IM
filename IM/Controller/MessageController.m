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
#import "NetworkTool.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"
#import "NaviView.h"
#import "LineCell.h"
#import "FriendCell.h"
#import "Masonry.h"
#import "BubbleView.h"
#import "UIResponder+FirstResponder.h"

@interface MessageController () <UITableViewDelegate, UITableViewDataSource, ConfigureAfterLogin, UITextFieldDelegate>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UITableView *friendTable;

@property (nonatomic, strong) UIView *shadow;
@property (nonatomic, strong) BubbleView *bubbleView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeRequestResponse:) name:@"RequestResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReloadNotification:) name:@"ReloadMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReloadNotification:) name:@"ReloadFriend" object:nil];
    
    UITableView *friendTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVI_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVI_HEIGHT) style:UITableViewStylePlain];
    self.friendTable = friendTable;
    friendTable.delegate = self;
    friendTable.dataSource = self;
    friendTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendTable.backgroundColor = CATSKILL_WHITE;
    [self.view addSubview:friendTable];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NaviView *naviView = [[NaviView alloc] init];
    [self.view addSubview:naviView];
    [naviView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.and.width.equalTo(self.view);
        make.height.mas_equalTo(@(NAVI_HEIGHT));
    }];
    naviView.holder = NaviHolderTable;
    [naviView layout];
    [naviView.rightBtn addTarget:self action:@selector(didClickRightButton) forControlEvents:UIControlEventTouchUpInside];
    
//    [self testDataBaseWithoutNetwork];
    /*
    if([self initRecentUser]) {
        loginCtrl.pagingView.hidden = YES;
        loginCtrl.loadingView.hidden = NO;
    } else {
        loginCtrl.pagingView.hidden = NO;
        loginCtrl.loadingView.hidden = YES;
     }*/[self initRecentUser];
    loginCtrl.pagingView.hidden = NO;
    
    _shadow = [[UIView alloc] initWithFrame:self.view.frame];
    _shadow.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.00];
    _shadow.alpha = 0;
    [self.view addSubview:_shadow];
    [_shadow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickShadow)]];
    
    _bubbleView = [[BubbleView alloc] initWithFrame:BUBBLE_ORIGIN];
    [self.view addSubview:_bubbleView];
    [_bubbleView.addBtn addTarget:self action:@selector(turnToSearchState) forControlEvents:UIControlEventTouchUpInside];
    [_bubbleView.changeBtn addTarget:self action:@selector(turnToChangeState) forControlEvents:UIControlEventTouchUpInside];
    _bubbleView.searchBar.delegate = self;
    _bubbleView.searchBar.returnKeyType = UIReturnKeySearch;
}

#pragma mark - Bubble
- (void)didClickRightButton {
    
    [UIView animateWithDuration:0.3f animations:^{
        _shadow.alpha = 0.15f;
        _bubbleView.frame = CGRectMake(SCREEN_WIDTH-15-140, NAVI_HEIGHT, 140, 90);
        [_bubbleView turnOn];
    } completion:^(BOOL complete){
        
    }];
    
}

- (void)didClickShadow {
    NSLog(@"click shadow");
//    _shadow.hidden = YES;
    [UIView animateWithDuration:0.3f animations:^{
        _shadow.alpha = 0;
        _bubbleView.frame = BUBBLE_ORIGIN;
        [_bubbleView turnToCloseState];
    }];
}

- (void)turnToChangeState {
    [UIView animateWithDuration:0.3f animations:^{
        _bubbleView.frame = CGRectMake(15, NAVI_HEIGHT, SCREEN_WIDTH-30, 260);
        [_bubbleView turnToChangeState];
    } completion:^(BOOL complete){
    }];
}

- (void)turnToSearchState {
    [UIView animateWithDuration:0.3f animations:^{
        _bubbleView.frame = CGRectMake(15, NAVI_HEIGHT, SCREEN_WIDTH-30, 95);
        [_bubbleView turnToSearchState];
    } completion:^(BOOL complete){
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    id responder = [UIResponder currentFirstResponder];
    if([responder isKindOfClass:[UITextField class]] || [responder isKindOfClass:[UITextView class]]) {
        UIView *view = responder;
        [view resignFirstResponder];
    }
    [[NetworkTool sharedNetTool] sendFriendRequestWithName:_bubbleView.searchBar.text];
    return YES;
}

- (void)turnToRequestState {
    [UIView animateWithDuration:0.3f animations:^{
        _bubbleView.frame = CGRectMake(15, NAVI_HEIGHT, SCREEN_WIDTH-30, 210);
        [_bubbleView turnToRequestState];
    } completion:^(BOOL complete){
    }];
}

- (void)observeRequestResponse:(NSNotification *)notification {
    if([notification.object isEqualToString:@"发送成功"]) {
        UIAlertController *requestAlert = [UIAlertController alertControllerWithTitle:notification.object message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [requestAlert addAction:okAction];
//        [self presentViewController:requestAlert animated:YES completion:nil];
    }
    if([notification.object isEqualToString:@"receive_request"]) {
        UIAlertController *requestAlert = [UIAlertController alertControllerWithTitle:@"好友申请" message:notification.userInfo[@"username"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[NetworkTool sharedNetTool] disposeFriendRequest:YES ID:notification.userInfo[@"id"]];
        }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [[NetworkTool sharedNetTool] disposeFriendRequest:NO ID:notification.userInfo[@"id"]];
        }];
        [requestAlert addAction:okAction];
        [requestAlert addAction:noAction];
        [self presentViewController:requestAlert animated:YES completion:nil];
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

- (void)getReloadNotification:(NSNotification *)notification {
    [self.friendTable reloadData];
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
    Message *lastMsg = friend.msgs.firstObject;
    cell.msg.text = lastMsg.content;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yy年M月d日";
    cell.time.text = [dateFormatter stringFromDate:lastMsg.time];
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
