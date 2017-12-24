//
//  ChatController.m
//  IM
//
//  Created by Gary Lee on 2017/12/19.
//  Copyright © 2017年 UniqueStudio. All rights reserved.
//

#import "ChatController.h"
#import "UIResponder+FirstResponder.h"
#import "NaviView.h"
#import "InputView.h"
#import "Masonry.h"
#import "User.h"
#import "Friend.h"
#import "PostCell.h"
#import "ReceiveCell.h"
#import "TimeCell.h"

@interface ChatController () <UITextViewDelegate, ClickBtn, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Friend *currentFriend;
@property (nonatomic, strong) InputView *inputView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation ChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self layout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
//    if (@available(iOS 11.0, *)) {
//        [_tableView setContentOffset:CGPointMake(0, UIEdgeInsetsInsetRect(self.tableView.frame, self.tableView.safeAreaInsets).size.height)];
//    } else {
//        // Fallback on earlier versions
//    }
//    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentFriend.msgs.count*2 - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)layout {
    self.view.backgroundColor = CATSKILL_WHITE;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = CATSKILL_WHITE;
    [self.view addSubview:tableView];
    tableView.estimatedRowHeight = 50;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 48, 0);
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 48, 0);
    _tableView = tableView;
    
    tableView.frame = CGRectMake(0, NAVI_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVI_HEIGHT);
    
    NaviView *naviView = [[NaviView alloc] init];
    naviView.titleView.text = self.currentFriend.userName;
    naviView.holder = NaviHolderChat;
    [self.view addSubview:naviView];
//    naviView.bounds = CGRectMake(0, 0, SCREEN_WIDTH, NAVI_HEIGHT);
    [naviView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.and.width.equalTo(self.view);
        make.height.mas_equalTo(@(NAVI_HEIGHT));
    }];
    [naviView layout];
    [naviView.leftBtn addTarget:self action:@selector(didClickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    
    InputView *inputView = [[InputView alloc] init];
    [self.view addSubview:inputView];
    _inputView = inputView;
    inputView.delegate = self;
    
    [inputView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.bottom.and.width.equalTo(self.view);
        make.height.equalTo(inputView.textView).with.offset(8);
    }];
    inputView.textView.delegate = self;
}

- (void)didClickLeftBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (Friend *)currentFriend {
    if(!_currentFriend) {
        _currentFriend = [User currentUser].friends[_friendIndex];
    }
    return _currentFriend;
}

#pragma mark - TableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger msgIndex = _currentFriend.msgs.count-1-indexPath.row/2;
    Message *currentMsg = _currentFriend.msgs[msgIndex];
    if(indexPath.row%2 == 0) {//TimeCell
        static NSString *timeCellID = @"timeCellID";
        TimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:timeCellID];
        if(!timeCell) {
            timeCell = [[TimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellID];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yy年MM月d日 H:m:s";
        timeCell.timeLable.text = [dateFormatter stringFromDate:currentMsg.time];
        [timeCell layout];
        return timeCell;
    } else if(currentMsg.direction == MsgPost) {//PostCell
        static NSString *postCellID = @"postCellID";
        PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:postCellID];
        if(!postCell) {
            postCell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postCellID];
        }
        postCell.type = currentMsg.type;
        postCell.avatarView.image = _currentFriend.avatar;
        postCell.textLable.text = currentMsg.content;
        postCell.pictureView.image = currentMsg.picture;
        [postCell layout];
        return postCell;
    } else {//ReceiveCell
        static NSString *receiveCellID = @"receiveCellID";
        ReceiveCell *receiveCell = [tableView dequeueReusableCellWithIdentifier:receiveCellID];
        if(!receiveCell) {
            receiveCell = [[ReceiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:receiveCellID];
        }
        receiveCell.type = currentMsg.type;
        receiveCell.avatarView.image = _currentFriend.avatar;
        receiveCell.textLable.text = currentMsg.content;
        receiveCell.pictureView.image = currentMsg.picture;
        [receiveCell layout];
        return receiveCell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentFriend.msgs.count*2;
}

#pragma mark - AutoResizing
- (void)textViewDidChange:(UITextView *)textView {
    static CGFloat maxHeight = 100;
    static CGFloat originHeight = 40;
    CGFloat newHeight;
    CGSize newSise = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    
    if(newSise.height < originHeight) {//小于原始高度
        newHeight = originHeight;
        textView.scrollEnabled = NO;
    } else if(newSise.height < maxHeight) {//小于最大高度
        newHeight = newSise.height;
        textView.scrollEnabled = NO;
    } else {//大于最大高度
        newHeight = maxHeight;
        textView.scrollEnabled = YES;
    }
    
    [textView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(_inputView).with.offset(1);
        make.centerY.equalTo(_inputView);
        make.right.equalTo(_inputView.imgBtn.mas_left).with.offset(-25);
        make.height.mas_equalTo(@(newHeight));
    }];
    
    [_inputView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.and.width.equalTo(self.view);
        make.height.equalTo(textView).with.offset(8);
        make.bottom.equalTo(self.view).with.offset(-self.keyboardHeight);
    }];
}

- (void)hideKeyboard {
    NSLog(@"tap gesture");
    id responder = [UIResponder currentFirstResponder];
    if([responder isKindOfClass:[UITextField class]] || [responder isKindOfClass:[UITextView class]]) {
        UIView *view = responder;
        [view resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notify {
    NSLog(@"kb appear");
    CGFloat keyboardHeight = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.keyboardHeight = keyboardHeight;
    CGRect frame = _inputView.frame;
    frame.origin.y -= keyboardHeight;
    _inputView.frame = frame;
}

- (void)keyboardWillHide:(NSNotification *)notify {
    NSLog(@"kb hide");
    CGFloat keyboardHeight = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect frame = _inputView.frame;
    frame.origin.y += keyboardHeight;
    _inputView.frame = frame;
    
}

#pragma mark - Click Button
- (void)didClickBtn:(UIButton *)btn {
    if(btn.tag == 2000) {//点击图片按钮
        NSLog(@"click imgBtn");
    }
    if(btn.tag == 2001) {//点击发送按钮
        NSLog(@"click sendBtn");
    }
}

@end
