//
//  Friend.h
//  IM
//
//  Created by Gary Lee on 2017/12/11.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Friend : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSMutableArray *msgs;
@property (nonatomic, assign) NSInteger unread;

@end
