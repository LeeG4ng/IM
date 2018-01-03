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
#import "NetworkTool.h"
#import "DataBaseTool.h"

@interface ChatController () <UITextViewDelegate, ClickBtn, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) Friend *currentFriend;
@property (nonatomic, strong) InputView *inputView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

//    [self layout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReloadNotification:) name:@"ReloadMessage" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    _currentFriend = [User currentUser].friends[_friendIndex];
    [self clearUnread];
    [self.tableView reloadData];
    [self layout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearUnread];
}

- (void)clearUnread {
    _currentFriend.unread = 0;
    [[DataBaseTool sharedDBTool] updateFriendInfo:_currentFriend];
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
    inputView.textView.delegate = self;
    
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
    _currentFriend = [User currentUser].friends[_friendIndex];
    return _currentFriend;
}

#pragma mark - TableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger msgIndex = self.currentFriend.msgs.count-1-indexPath.row/2;
    Message *currentMsg = self.currentFriend.msgs[msgIndex];
    if(indexPath.row%2 == 0) {//TimeCell
        static NSString *timeCellID = @"timeCellID";
        TimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:timeCellID];
        if(!timeCell) {
            timeCell = [[TimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeCellID];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yy年MM月d日 H:m:ss";
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
        postCell.avatarView.image = [User currentUser].avatar;
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
        receiveCell.avatarView.image = self.currentFriend.avatar;
        receiveCell.textLable.text = currentMsg.content;
        receiveCell.pictureView.image = currentMsg.picture;
        [receiveCell layout];
        return receiveCell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentFriend.msgs.count*2;
}

- (void)getReloadNotification:(NSNotification *)notification {
    [self.tableView reloadData];
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
        make.bottom.equalTo(self.view);
    }];
    
}

- (void)hideKeyboard {
    NSLog(@"tap gesture");
    [self.tableView reloadData];
    id responder = [UIResponder currentFirstResponder];
    if([responder isKindOfClass:[UITextField class]] || [responder isKindOfClass:[UITextView class]]) {
        UIView *view = responder;
        [view resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"kb appear");
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _inputView.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"kb hide");
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _inputView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

#pragma mark - Click Button
- (void)didClickBtn:(UIButton *)btn {
    [self hideKeyboard];
    if(btn.tag == 2000) {//点击图片按钮
        NSLog(@"click imgBtn");
        [self sendPicture];
    }
    if(btn.tag == 2001) {//点击发送按钮
        NSLog(@"click sendBtn");
        [self sendMessage];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendMessage];
        return NO;
    }
    return YES;
}

#pragma mark - Message Operation
- (void)sendMessage {
    Message *msg = [[Message alloc] init];
    msg.type = MsgText;
    msg.content = _inputView.textView.text;
    msg.time = [NSDate date];
    [[NetworkTool sharedNetTool] sendMessage:msg toFriend:self.currentFriend.userName];
    _inputView.textView.text = @"";
}

- (void)sendPicture {
    UIImagePickerController *pickerCtr = [[UIImagePickerController alloc] init];
    pickerCtr.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerCtr.delegate = self;
    [self presentViewController:pickerCtr animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        Message *msg = [[Message alloc] init];
        msg.type = MsgPicture;
        msg.time = [NSDate date];
        msg.picture = image;
        [[NetworkTool sharedNetTool] sendMessage:msg toFriend:self.currentFriend.userName];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}



@end
