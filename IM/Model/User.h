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

+ (instancetype)currentUser;//获得最近登陆过用户的单例
@end
