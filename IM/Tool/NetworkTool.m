//
//  NetworkTool.m
//  IM
//
//  Created by Gary Lee on 2017/12/22.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "DataBaseTool.h"
#import "NetworkTool.h"
#import "AFNetworking.h"
#import "SocketRocket.h"
#import "User.h"
#import "Friend.h"
#import "Message.h"

static NetworkTool *tool;

@interface NetworkTool() <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *requestWS;
@property (nonatomic, strong) SRWebSocket *messageWS;

@end

@implementation NetworkTool

+ (instancetype)sharedNetTool {
    static dispatch_once_t net_oncetoken;
    dispatch_once(&net_oncetoken, ^{
        tool = [[NetworkTool alloc] init];
    });
    return tool;
}

#pragma mark - WebSocket Handshake
- (void)WSHandshake {
    AFHTTPSessionManager *requestHandshakeManager = [AFHTTPSessionManager manager];
    [requestHandshakeManager POST:@"http://133.130.102.196:7341/user/friends/request" parameters:@{@"jwt":[User currentUser].jwt} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSLog(@"request handshake success:%@", responseObject);
        NSURL *requestURL = [NSURL URLWithString:@"ws://133.130.102.196:7341/user/friends/request"];
        _requestWS = [[SRWebSocket alloc] initWithURL:requestURL];
        _requestWS.delegate = self;
        [_requestWS open];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSLog(@"request handshake error :%@", error);
    }];
    
    AFHTTPSessionManager *messageHandshakeManager = [AFHTTPSessionManager manager];
    [messageHandshakeManager POST:@"http://133.130.102.196:7341/message" parameters:@{@"jwt":[User currentUser].jwt} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSLog(@"message handshake success:%@", responseObject);
        NSURL *requestURL = [NSURL URLWithString:@"ws://133.130.102.196:7341/message"];
        _messageWS = [[SRWebSocket alloc] initWithURL:requestURL];
        _messageWS.delegate = self;
        [_messageWS open];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSLog(@"message handshake error :%@", error);
    }];
}

#pragma mark - User Operation
- (void)registerWithUser:(User *)user {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *regUrl = @"http://133.130.102.196:7341/user/register";
    NSDictionary *regParam = @{@"username":user.userName, @"password":user.passWord};
    [manager POST:regUrl parameters:regParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        [DataBaseTool sharedDBTool].operatedUser = user;
        [[DataBaseTool sharedDBTool] recordUser:user];
        [User currentUser].jwt = responseObject[@"jwt"];
        [User currentUser].response = @"success";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserResponse" object:[User currentUser].response];
        [self WSHandshake];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableLeaves error:nil];
        [User currentUser].response = errorDict[@"error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserResponse" object:[User currentUser].response];
    }];
}

- (void)loginWithUser:(User *)user {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *loginUrl = @"http://133.130.102.196:7341/user/login";
    NSDictionary *loginParam = @{@"username":user.userName, @"password":user.passWord};
    [manager POST:loginUrl parameters:loginParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        [DataBaseTool sharedDBTool].operatedUser = user;
        User *recordedUser = [[DataBaseTool sharedDBTool] getUserWithUserName:user.userName];//没写头像
        if(recordedUser) {//本地有登陆用户的数据
            [[User currentUser] setCurrentUserWithUser:recordedUser];
            [User currentUser].jwt = responseObject[@"jwt"];
            [User currentUser].response = @"success";
        } else {//本地不存在登陆用户的数据
            [[DataBaseTool sharedDBTool] recordUser:user];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserResponse" object:[User currentUser].response];
        [self WSHandshake];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSLog(@"%@", error);
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableLeaves error:nil];
        [User currentUser].response = errorDict[@"error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserResponse" object:[User currentUser].response];
    }];
}

#pragma mark - Friends Operation
- (void)getFriendsList {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *friendUrl = @"http://133.130.102.196:7341/user/friends";
    manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    [manager.requestSerializer setValue:[User currentUser].jwt forHTTPHeaderField:@"Authorization"];
    [manager GET:friendUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSArray *friendsArr = responseObject;
        NSLog(@"friends:%@", friendsArr);
        for(NSDictionary *friend in friendsArr) {
            if(![[User currentUser].friendNames containsObject:friend[@"username"]]) {
                Friend *tempFriend = [[Friend alloc] init];
                tempFriend.userName = friend[@"username"];//没写头像
                [[DataBaseTool sharedDBTool] recordFriend:tempFriend];
            }
        }
        User *recordedUser = [[DataBaseTool sharedDBTool] getUserWithUserName:[User currentUser].userName];
        [[User currentUser] setCurrentUserWithUser:recordedUser];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@,,,%@", error, errorDict);
    }];
}

- (void)getFriendRequestHistory {
    NSDictionary *dict = @{@"type":@"history"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [_requestWS send:data];
}

- (void)sendFriendRequestWithName:(NSString *)userName {
    NSDictionary *dict = @{@"type":@"send_request",@"username":userName};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [_requestWS send:data];
}

- (void)deleteFriendWithName:(NSString *)userName {
    NSDictionary *dict = @{@"type":@"reject_request",@"username":userName};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [_requestWS send:data];
}

- (void)disposeFriendRequest:(BOOL)dispose ID:(NSString *)id {
    if(dispose) {//同意
        NSDictionary *dict = @{@"type":@"agree_request", @"id":id};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        [_requestWS send:data];
    } else {//拒绝
        NSDictionary *dict = @{@"type":@"reject_request",@"id":id};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        [_requestWS send:data];
    }
}

#pragma mark - Message Operation
- (void)sendMessage:(Message *)msg toFriend:(NSString *)userName {
    NSDictionary *dict = @{@"type":@"send_message", @"to":userName, @"content":msg.content, @"create_time":@(msg.time.timeIntervalSince1970)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [_messageWS send:data];
}

- (void)getMessageHistorySince:(NSTimeInterval)time {
    NSDictionary *dict = @{@"type":@"history", @"start_time":@(time), @"end_time":@([NSDate date].timeIntervalSince1970)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [_messageWS send:data];
}

#pragma mark - WebSocket Delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    if(webSocket == _requestWS) {
        NSLog(@"requestWS:open");
        [self getFriendsList];//好友列表http
        [self getFriendRequestHistory];//好友请求历史
    }
    if(webSocket == _messageWS) {
        NSLog(@"messageWS:open");
        //聊天记录
        NSTimeInterval time = 0;
        User *currentUser = [User currentUser];
        for(Friend *friend in currentUser.friends) {
            Message *msg = friend.msgs.lastObject;
            NSTimeInterval tempTime = msg.time.timeIntervalSince1970;
            if(tempTime > time) {
                time = tempTime;
            }
        }
        [self getMessageHistorySince:time];
        
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"all ws receive:%@", dict);
    NSString *type = dict[@"type"];
    if(webSocket == _requestWS) {
        if([type isEqualToString:@"send_request"]) {//发送好友请求成功
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestResponse" object:@"发送成功"];
        }
        if([type isEqualToString:@"receive_request"]) {//收到好友请求
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestResponse" object:@"receive_request" userInfo:dict];
        }
        if([type isEqualToString:@"history"]) {//好友请求历史
            NSArray *requestsArr = dict[@"requests"];
            for(NSDictionary *request in requestsArr) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestResponse" object:@"receive_request" userInfo:request];
            }
        }
        if([type isEqualToString:@"agree_request"]) {//同意好友请求成功
            
        }
    }
    if(webSocket == _messageWS) {
        if([type isEqualToString:@"history"]) {//聊天记录
            NSArray *msgArr = dict[@"messages"];
            for(NSDictionary *msg in msgArr) {
                Message *tempMsg = [[Message alloc] init];
                tempMsg.type = MsgText;
                tempMsg.content = msg[@"content"];
                NSTimeInterval time = [msg[@"create_time"] doubleValue];
                tempMsg.time = [NSDate dateWithTimeIntervalSince1970:time];
                NSString *friendName = @"";
                if([msg[@"from"] isEqualToString:[User currentUser].userName]) {
                    tempMsg.direction = MsgPost;
                    friendName = msg[@"to"];
                } else {
                    tempMsg.direction = MsgReceive;
                    friendName = msg[@"from"];
                }
                User *currentUser = [User currentUser];
                for(Friend *friend in currentUser.friends) {
                    if([friend.userName isEqualToString:friendName]) {
                        [[DataBaseTool sharedDBTool] recordMessage:tempMsg ofFriend:friend];
                    }
                }
            }
        }
        if([type isEqualToString:@"receive_message"]) {
            
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"ws error:%@", error);
    if(webSocket == _requestWS) {
        
    }
    if(webSocket == _messageWS) {
        
    }
}
@end
