//
//  TextField.m
//  IM
//
//  Created by Gary Lee on 2017/12/17.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "TextField.h"

@implementation TextField

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    rect.origin.x += 23;
    return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 50, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 50, 0);
}
@end
