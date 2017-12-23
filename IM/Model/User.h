//
//  User.h
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *passWord;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSMutableArray *friends;

//单例属性
@property (nonatomic, strong) NSString *jwt;
@property (nonatomic, strong) NSString *response;

+ (instancetype)currentUser;//获得最近登陆过用户的单例
- (void)setCurrentUserWithUser:(User *)currentUser;//由单例User调用，将参数的属性设置到单例
@end
