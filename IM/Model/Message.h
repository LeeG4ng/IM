//
//  Message.h
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MsgDirection) {MsgReceive, MsgPost};

@interface Message : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) MsgDirection direction;
@property (nonatomic, strong) NSDate *time;

@end
