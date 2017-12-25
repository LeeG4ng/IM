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
        //delete
        [self getFriendsList];
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
        NSArray *arr = responseObject;
        NSLog(@"friends:%@,,,%@", arr, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@,,,%@", error, errorDict);
    }];
}

- (void)getFriendRequestHistory {
    
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

#pragma mark - WebSocket Delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"open");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@", dict);
    if(webSocket == _requestWS) {
        if([dict[@"info"] isEqualToString:@"received"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestResponse" object:@"发送成功"];
        }
        if([dict[@"type"] isEqualToString:@"receive_request"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestResponse" object:@"receive_request" userInfo:dict];
        }
    }
    if(webSocket == _messageWS) {
        
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    if(webSocket == _requestWS) {
        
    }
    if(webSocket == _messageWS) {
        
    }
}
@end
