//
//  ChatListController.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "ChatListController.h"
#import "EmotionHelper.h"
#import "RefreshControl.h"
#import "PhotoView.h"
#import "WebSocketManager.h"
#import "NetworkHelper.h"
#import "ChatTextView.h"
#import "TimeCell.h"
#import "SystemMessageCell.h"
#import "ImageMessageCell.h"
#import "TextMessageCell.h"

NSString * const kTimeCell          = @"TimeCell";
NSString * const kSystemMessageCell = @"SystemMessageCell";
NSString * const kImageMessageCell  = @"ImageMessageCell";
NSString * const kTextMessageCell   = @"TextMessageCell";

@interface ChatListController () <UITableViewDelegate, UITableViewDataSource, ChatTextViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) RefreshControl                      *refreshControl;
@property (nonatomic, strong) UITableView                         *tableView;
@property (nonatomic, strong) NSMutableArray<GroupChat *>         *data;
@property (nonatomic, strong) ChatTextView                        *textView;
@property (nonatomic, assign) NSInteger                           pageIndex;
@property (nonatomic, assign) NSInteger                           pageSize;
@property (nonatomic, strong) Visitor                             *visitor;
@end


@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _visitor = readVisitor();
    
    _data = [NSMutableArray array];
    
    _pageIndex = 0;
    _pageSize = 20;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, ScreenWidth, ScreenHeight - SafeAreaTopHeight - 10)];
    _tableView.backgroundColor = ColorClear;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceVertical = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    } else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    [_tableView registerClass:TimeCell.class forCellReuseIdentifier:kTimeCell];
    [_tableView registerClass:SystemMessageCell.class forCellReuseIdentifier:kSystemMessageCell];
    [_tableView registerClass:ImageMessageCell.class forCellReuseIdentifier:kImageMessageCell];
    [_tableView registerClass:TextMessageCell.class forCellReuseIdentifier:kTextMessageCell];
    [self.view addSubview:_tableView];
    
    _refreshControl = [RefreshControl new];
    __weak __typeof(self) weakSelf = self;
    [_refreshControl setOnRefresh:^{
        [weakSelf loadData:weakSelf.pageIndex pageSize:weakSelf.pageSize];
    }];
    [_tableView addSubview:_refreshControl];
    
    _textView = [ChatTextView new];
    _textView.delegate = self;
    
    [self loadData:_pageIndex pageSize:_pageSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:WebSocketDidReceiveMessageNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarTitle:@"QSHI"];
    [self setNavigationBarTitleColor:ColorWhite];
    [self setNavigationBarBackgroundColor:ColorThemeGrayDark];
    [self setStatusBarBackgroundColor:ColorThemeGrayDark];
    [_textView show];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_textView dismiss];
}

-(void)receiveMessage:(NSNotification *)notification {
    NSString *json = (NSString *)[notification object];
    NSError *error;
    GroupChat *chat = [[GroupChat alloc] initWithString:json error:&error];
    if(error) {
        return;
    }
    chat.cellAttributedString = [self cellAttributedString:chat];
    chat.contentSize = [self cellContentSize:chat];
    chat.cellHeight = [self cellHeight:chat];
    
    BOOL shouldScrollToBottom = NO;
    if(_tableView.visibleCells.lastObject && [_tableView indexPathForCell:_tableView.visibleCells.lastObject].row == _data.count - 1) {
        shouldScrollToBottom = YES;
    }
    
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_data addObject:chat];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_data.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    if(shouldScrollToBottom) {
        [self scrollToBottom];
    }
}


//load data
- (void)loadData:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    __weak __typeof(self) wself = self;
    GroupChatListRequest *request = [GroupChatListRequest new];
    request.page = pageIndex;
    request.size = pageSize;
    [NetworkHelper getWithUrlPath:FindGroupChatByPagePath request:request success:^(id data) {
        GroupChatListResponse *response = [[GroupChatListResponse alloc] initWithDictionary:data error:nil];
        NSArray<GroupChat *> *array = response.data;
        
        NSInteger preCount = wself.data.count;
        
        [UIView setAnimationsEnabled:NO];
        [wself processData:array];

        NSInteger curCount = wself.data.count;
        
        if(wself.pageIndex++ == 0 || preCount == 0 || (curCount - preCount) <= 0) {
            [wself scrollToBottom];
        }else {
            [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:curCount - preCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        [wself.refreshControl endRefresh];
        if(!response.has_more) {
            [wself.refreshControl loadAll];
        }
        [UIView setAnimationsEnabled:YES];
    } failure:^(NSError *error) {
        [wself.refreshControl endRefresh];
    }];
}

- (void)processData:(NSArray<GroupChat *> *)data {
    if(data.count == 0) {
        return;
    }
    NSMutableArray<GroupChat *> *tempArray = [NSMutableArray new];
    for(GroupChat *chat in data) {
        if((![@"system" isEqualToString:chat.msg_type]) &&
           (tempArray.count == 0 || (tempArray.count > 0 && labs([tempArray.lastObject create_time] - chat.create_time) > 60*5))) {
            GroupChat *timeChat = [GroupChat new];
            timeChat.msg_type = @"time";
            timeChat.msg_content = [NSDate formatTime:chat.create_time];
            timeChat.create_time = chat.create_time;
            timeChat.cellAttributedString = [self cellAttributedString:timeChat];
            timeChat.contentSize = [self cellContentSize:timeChat];
            timeChat.cellHeight = [self cellHeight:timeChat];
            [tempArray addObject:timeChat];
        }
        chat.cellAttributedString = [self cellAttributedString:chat];
        chat.contentSize = [self cellContentSize:chat];
        chat.cellHeight = [self cellHeight:chat];
        [tempArray addObject:chat];
    }
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[tempArray count])];
    [self.data insertObjects:tempArray atIndexes:indexes];
    [self.tableView reloadData];
}

//delete chat
- (void)deleteChat:(UITableViewCell *)cell {
    if(!cell) {
        return;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if(!indexPath) {
        return;
    }
    NSInteger index = indexPath.row;
    
    GroupChat *chat = [_data objectAtIndex:index];
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    if(index-1 < _data.count && [@"time" isEqualToString:_data[index - 1].msg_type]) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index - 1 inSection:0]];
    }
    if(index < _data.count) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    if(indexPaths.count == 0) {
        return;
    }
    __weak __typeof(self) wself = self;
    DeleteGroupChatRequest *request = [DeleteGroupChatRequest new];
    request.udid = UDID;
    request.id = chat.id;
    [NetworkHelper deleteWithUrlPath:DeleteGroupChatByIdPath request:request success:^(id data) {
        [wself.tableView beginUpdates];
        [wself.data removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPaths.firstObject.row, indexPaths.count)]];
        [wself.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        [wself.tableView endUpdates];
    } failure:^(NSError *error) {
        [UIWindow showTips:@"删除失败"];
    }];
}

- (void)scrollToBottom {
    if(self.data.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.data.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

//chat textview delegate
-(void)onSendText:(NSString *)text {
    @synchronized(_data) {
        GroupChat *chat = [[GroupChat alloc] initTextChat:text];
        chat.visitor = _visitor;
        chat.cellAttributedString = [self cellAttributedString:chat];
        chat.contentSize = [self cellContentSize:chat];
        chat.cellHeight = [self cellHeight:chat];
        
        [UIView setAnimationsEnabled:NO];
        [_tableView beginUpdates];
        [_data addObject:chat];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_data.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        [self scrollToBottom];
        
        NSInteger index = [_data indexOfObject:chat];
        
        __weak __typeof(self) wself = self;
        PostGroupChatTextRequest *request = [PostGroupChatTextRequest new];
        request.udid = UDID;
        request.text = text;
        [NetworkHelper postWithUrlPath:PostGroupChatTextPath request:request success:^(id data) {
            GroupChatResponse *response = [[GroupChatResponse alloc] initWithDictionary:data error:nil];
            [chat updateTempTextChat:response.data];
            [wself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(NSError *error) {
            chat.isCompleted = NO;
            chat.isFailed = YES;
            [wself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

-(void)onSendImages:(NSMutableArray<UIImage *> *)images {
    @synchronized(_data) {
        __weak __typeof(self) wself = self;
        for(UIImage *image in images) {
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            GroupChat *chat = [[GroupChat alloc] initImageChat:image];
            chat.visitor = _visitor;
            chat.contentSize = [self cellContentSize:chat];
            chat.cellHeight = [self cellHeight:chat];
            
            [UIView setAnimationsEnabled:NO];
            [_tableView beginUpdates];
            [_data addObject:chat];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_data.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView endUpdates];
            [UIView setAnimationsEnabled:YES];
            
            NSInteger index = [_data indexOfObject:chat];
            
            PostGroupChatImageRequest *request = [PostGroupChatImageRequest new];
            request.udid = UDID;
            [NetworkHelper uploadWithUrlPath:PostGroupChatImagePath data:data request:request progress:^(CGFloat percent) {
                chat.percent = percent;
                chat.isCompleted = NO;
                chat.isFailed = NO;
                ImageMessageCell *cell = [wself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                if (cell != nil) {
                    [cell updateUploadStatus:chat];
                }
            } success:^(id data) {
                GroupChatResponse *response = [[GroupChatResponse alloc] initWithDictionary:data error:nil];
                [chat updateTempImageChat:response.data];
                [wself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            } failure:^(NSError *error) {
                chat.percent = 0;
                chat.isCompleted = NO;
                chat.isFailed = YES;
                ImageMessageCell *cell = [wself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                if (cell != nil) {
                    [cell updateUploadStatus:chat];
                }
            }];
        }
    }
    [self scrollToBottom];
}


- (void)onEditBoardHeightChange:(CGFloat)height {
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
    [self scrollToBottom];
}

//tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChat *chat = _data[indexPath.row];
    return chat.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChat *chat = _data[indexPath.row];
    __weak __typeof(self) wself = self;
    if([chat.msg_type isEqualToString:@"system"]){
        SystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kSystemMessageCell forIndexPath:indexPath];
        [cell initData:chat];
        return cell;
    }else if([chat.msg_type isEqualToString:@"text"]){
        TextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextMessageCell forIndexPath:indexPath];
        __weak __typeof(cell) wcell = cell;
        cell.onMenuAction = ^(MenuActionType actionType) {
            if(actionType == DeleteAction) {
                [wself deleteChat:wcell];
            }else if(actionType == CopyAction) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = chat.msg_content;
            }
        };
        [cell initData:chat];
        return cell;
    }else  if([chat.msg_type isEqualToString:@"image"]){
        ImageMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kImageMessageCell forIndexPath:indexPath];
        __weak __typeof(cell) wcell = cell;
        cell.onMenuAction = ^(MenuActionType actionType) {
            if(actionType == DeleteAction) {
                [wself deleteChat:wcell];
            }
        };
        [cell initData:chat];
        return cell;
    }else {
        TimeCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeCell forIndexPath:indexPath];
        [cell initData:_data[indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
}

- (NSMutableAttributedString *)cellAttributedString:(GroupChat *)chat {
    if([chat.msg_type isEqualToString:@"system"]){
        return [SystemMessageCell cellAttributedString:chat];
    }else if([chat.msg_type isEqualToString:@"text"]){
        return [TextMessageCell cellAttributedString:chat];
    }else  if([chat.msg_type isEqualToString:@"image"]){
        return nil;
    }else {
        return [TimeCell cellAttributedString:chat];
    }
}

- (CGFloat)cellHeight:(GroupChat *)chat {
    if([chat.msg_type isEqualToString:@"system"]){
        return [SystemMessageCell cellHeight:chat];
    }else if([chat.msg_type isEqualToString:@"text"]){
        return [TextMessageCell cellHeight:chat];
    }else  if([chat.msg_type isEqualToString:@"image"]){
        return [ImageMessageCell cellHeight:chat];
    }else {
        return [TimeCell cellHeight:chat];
    }
}

- (CGSize)cellContentSize:(GroupChat *)chat {
    if([chat.msg_type isEqualToString:@"system"]){
        return [SystemMessageCell contentSize:chat];
    }else if([chat.msg_type isEqualToString:@"text"]){
        return [TextMessageCell contentSize:chat];
    }else  if([chat.msg_type isEqualToString:@"image"]){
        return [ImageMessageCell contentSize:chat];
    }else {
        return [TimeCell contentSize:chat];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
