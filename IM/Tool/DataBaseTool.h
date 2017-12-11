//
//  DataBaseTool.h
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@class Friend;
@class Message;

@interface DataBaseTool : NSObject

+ (instancetype)sharedDBTool;

- (BOOL)addUser:(User *)user;
- (BOOL)addFriend:(Friend *)friend OfUser:(User *)user;

@end
