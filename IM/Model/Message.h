//
//  Message.h
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MsgDirection) {MsgReceive, MsgPost};
typedef NS_ENUM(NSInteger, MsgType) {MsgText, MsgPicture};

@interface Message : NSObject

@property (nonatomic, strong) NSString *friendName;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIImage *picture;
@property (nonatomic, assign) MsgType type;
@property (nonatomic, assign) MsgDirection direction;
@property (nonatomic, strong) NSDate *time;

@end
