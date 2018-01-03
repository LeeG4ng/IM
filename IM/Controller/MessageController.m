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
#import "AfNetworking.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"
#import "NaviView.h"
#import "LineCell.h"
#import "FriendCell.h"
#import "Masonry.h"
#import "BubbleView.h"
#import "UIResponder+FirstResponder.h"

@interface MessageController () <UITableViewDelegate, UITableViewDataSource, ConfigureAfterLogin, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UITableView *friendTable;

@property (nonatomic, strong) UIView *shadow;
@property (nonatomic, strong) BubbleView *bubbleView;
@property (nonatomic, strong) NaviView *naviView;

@property (nonatomic, strong) Friend *friendToDelete;

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
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NaviView *naviView = [[NaviView alloc] init];
    [self.view addSubview:naviView];
    _naviView = naviView;
    [naviView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.and.width.equalTo(self.view);
        make.height.mas_equalTo(@(NAVI_HEIGHT));
    }];
    naviView.holder = NaviHolderTable;
    [naviView layout];
    [naviView.rightBtn addTarget:self action:@selector(didClickRightButton) forControlEvents:UIControlEventTouchUpInside];
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
            self.naviView.titleView.text = @"无网络连接";
        } else {
            self.naviView.titleView.text = @"消息";
        }
    }];
    
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeRequestResponse:) name:@"RequestResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReloadNotification:) name:@"ReloadMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReloadNotification:) name:@"ReloadFriend" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeDeleteResponse:) name:@"DeleteResponse" object:nil];
    
    UITableView *friendTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVI_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVI_HEIGHT) style:UITableViewStylePlain];
    self.friendTable = friendTable;
    friendTable.delegate = self;
    friendTable.dataSource = self;
    friendTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendTable.backgroundColor = CATSKILL_WHITE;
    [self.view addSubview:friendTable];
    
    
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
    
    [_bubbleView.avatarView.btn addTarget:self action:@selector(didClickAvatar) forControlEvents:UIControlEventTouchUpInside];
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

- (void)didClickAvatar {
    UIImagePickerController *pickerCtr = [[UIImagePickerController alloc] init];
    pickerCtr.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerCtr.delegate = self;
    [self presentViewController:pickerCtr animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [[NetworkTool sharedNetTool] changeAvatar:image];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)observeRequestResponse:(NSNotification *)notification {
    if([notification.object isEqualToString:@"发送成功"]) {
        UIAlertController *requestAlert = [UIAlertController alertControllerWithTitle:notification.object message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [requestAlert addAction:okAction];
        [self presentViewController:requestAlert animated:YES completion:nil];
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
        if([friendCell.num.text isEqualToString:@"0"]) {
            friendCell.bubble.hidden = YES;
        } else {
            friendCell.bubble.hidden = NO;
        }
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
    if(lastMsg.type == MsgText) {
        cell.msg.text = lastMsg.content;
    } else {
        cell.msg.text = @"[图片]";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yy年M月d日";
    cell.time.text = [dateFormatter stringFromDate:lastMsg.time];
    cell.num.text = [NSString stringWithFormat:@"%ld", friend.unread];
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

//左滑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 从数据源中删除
    self.friendToDelete = self.user.friends[indexPath.row];
    [[NetworkTool sharedNetTool] deleteFriendWithName:self.friendToDelete.userName];
    
    // 从列表中删除
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)observeDeleteResponse:(NSNotification *)notification {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DataBaseTool sharedDBTool] deleteFriendAndMessages:self.friendToDelete];
        User *recordedUser = [[DataBaseTool sharedDBTool] getUserWithUserName:[User currentUser].userName];
        [[User currentUser] setCurrentUserWithUser:recordedUser];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.friendTable reloadData];
    });
    
}

@end
