//
//  CommentsPopView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "CommentsPopView.h"
#import "Masonry.h"
#import "NSNotification+Extension.h"
#import "MenuPopView.h"
#import "NetworkHelper.h"

#define COMMENT_CELL @"CommentCell"
#define COMMENT_HEADER @"CommentHeader"
#define COMMENT_FOOTER @"CommentFooter"

@interface CommentsPopView () <UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate,UIScrollViewDelegate, CommentTextViewDelegate>

@property (nonatomic, assign) NSString                         *awemeId;
@property (nonatomic, strong) Visitor                          *vistor;

@property (nonatomic, assign) NSInteger                        pageIndex;
@property (nonatomic, assign) NSInteger                        pageSize;

@property (nonatomic, strong) UIView                           *container;
@property (nonatomic, strong) UITableView                      *tableView;
@property (nonatomic, strong) NSMutableArray<Comment *>        *data;
@property (nonatomic, strong) CommentTextView                  *textView;
@property (nonatomic, strong) LoadMoreControl                     *loadMore;
@end

@implementation CommentsPopView
- (instancetype)initWithAwemeId:(NSString *)awemeId {
    self = [super init];
    if (self) {
        self.frame = SCREEN_FRAME;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        _awemeId = awemeId;
        _vistor = readVisitor();
        
        _pageIndex = 0;
        _pageSize = 20;
        
        _data = [NSMutableArray array];
        
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT*3/4)];
        _container.backgroundColor = ColorBlackAlpha60;
        [self addSubview:_container];
        
        
        UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*3/4) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0f, 10.0f)];
        CAShapeLayer* shape = [[CAShapeLayer alloc] init];
        [shape setPath:rounded.CGPath];
        _container.layer.mask = shape;
        
        UIBlurEffect *blurEffect =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualEffectView.frame = self.bounds;
        visualEffectView.alpha = 1.0f;
        [_container addSubview:visualEffectView];
        
        
        _label = [[UILabel alloc] init];
        _label.textColor = ColorGray;
        _label.text = @"0条评论";
        _label.font = SmallFont;
        _label.textAlignment = NSTextAlignmentCenter;
        [_container addSubview:_label];
        
        _close = [[UIImageView alloc] init];
        _close.image = [UIImage imageNamed:@"icon_closetopic"];
        _close.contentMode = UIViewContentModeCenter;
        [_close addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        [_container addSubview:_close];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.container);
            make.height.mas_equalTo(35);
        }];
        [_close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.label);
            make.right.equalTo(self.label).inset(10);
            make.width.height.mas_equalTo(30);
        }];
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH, SCREEN_HEIGHT*3/4 - 35 - 50) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ColorClear;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:CommentListCell.class forCellReuseIdentifier:COMMENT_CELL];
        
        _loadMore = [[LoadMoreControl alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 50) surplusCount:10];
        [_loadMore startLoading];
        __weak __typeof(self) wself = self;
        [_loadMore setOnLoad:^{
            [wself loadData:wself.pageIndex pageSize:wself.pageSize];
        }];
        [_tableView addSubview:_loadMore];
        
        [_container addSubview:_tableView];
        
        _textView = [[CommentTextView alloc] init];
        _textView.delegate = self;
        
        [self loadData:_pageIndex pageSize:_pageSize];
        
    }
    return self;
}

// comment textView delegate
-(void)onSendText:(NSString *)text {
    __weak __typeof(self) wself = self;
    PostCommentRequest *request = [PostCommentRequest new];
    request.aweme_id = _awemeId;
    request.udid = UDID;
    request.text = text;
    __block NSURLSessionDataTask *task = [NetworkHelper postWithUrlPath:POST_COMMENT_URL request:request success:^(id data) {
        CommentResponse *response = [[CommentResponse alloc] initWithDictionary:data error:nil];
        Comment *comment = response.data;
        for(NSInteger i = wself.data.count-1; i>=0; i--) {
            if(wself.data[i].taskId == task.taskIdentifier) {
                wself.data[i] = comment;
                break;
            }
        }
        [UIWindow showTips:@"评论成功"];
    } failure:^(NSError *error) {
        [UIWindow showTips:@"评论失败"];
    }];
    
    Comment *comment = [[Comment alloc] init:_awemeId text:text taskId:task.taskIdentifier];
    comment.user_type = @"visitor";
    comment.visitor = _vistor;
    
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_data insertObject:comment atIndex:0];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [UIView setAnimationsEnabled:YES];
}

// tableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommentListCell cellHeight:_data[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL];
    [cell initData:_data[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = _data[indexPath.row];
    if(!comment.isTemp && [@"visitor" isEqualToString:comment.user_type] && [MD5_UDID isEqualToString:comment.visitor.udid]) {
        MenuPopView *menu = [[MenuPopView alloc] initWithTitles:@[@"删除"]];
        __weak __typeof(self) wself = self;
        menu.onAction = ^(NSInteger index) {
            [wself deleteComment:comment];
        };
        [menu show];
    }
}

//delete comment
- (void)deleteComment:(Comment *)comment {
    __weak __typeof(self) wself = self;
    DeleteCommentRequest *request = [DeleteCommentRequest new];
    request.cid = comment.cid;
    request.udid = UDID;
    [NetworkHelper deleteWithUrlPath:DELETE_COMMENT_BY_ID_URL request:request success:^(id data) {
        NSInteger index = [wself.data indexOfObject:comment];
        [wself.tableView beginUpdates];
        [wself.data removeObjectAtIndex:index];
        [wself.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [wself.tableView endUpdates];
        [UIWindow showTips:@"评论删除成功"];
    } failure:^(NSError *error) {
        [UIWindow showTips:@"评论删除失败"];
    }];
}

//guesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view.superview class]) isEqualToString:@"CommentListCell"]) {
        return NO;
    }else {
        return YES;
    }
}

- (void)handleGuesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_container];
    if(![_container.layer containsPoint:point]) {
        [self dismiss];
        return;
    }
    point = [sender locationInView:_close];
    if([_close.layer containsPoint:point]) {
        [self dismiss];
    }
}

//update method
- (void)show {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.container.frame;
                         frame.origin.y = frame.origin.y - frame.size.height;
                         self.container.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
    [self.textView show];
}

- (void)dismiss {
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = self.container.frame;
                         frame.origin.y = frame.origin.y + frame.size.height;
                         self.container.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [self.textView dismiss];
                     }];
}

//load data
- (void)loadData:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    __weak __typeof(self) wself = self;
    CommentListRequest *request = [CommentListRequest new];
    request.page = pageIndex;
    request.size = pageSize;
    request.aweme_id = _awemeId;
    [NetworkHelper getWithUrlPath:FIND_COMMENT_BY_PAGE_URL request:request success:^(id data) {
        CommentListResponse *response = [[CommentListResponse alloc] initWithDictionary:data error:nil];
        NSArray<Comment *> *array = response.data;
        
        wself.pageIndex++;
        
        [UIView setAnimationsEnabled:NO];
        [wself.tableView beginUpdates];
        [wself.data addObjectsFromArray:array];
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
        for(NSInteger row = wself.data.count - array.count; row<wself.data.count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPaths addObject:indexPath];
        }
        [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [wself.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        [wself.loadMore endLoading];
        if(!response.has_more) {
            [wself.loadMore loadingAll];
        }
        wself.label.text = [NSString stringWithFormat:@"%ld条评论",response.total_count];
    } failure:^(NSError *error) {
        [wself.loadMore loadingFailed];
    }];
}

//UIScrollViewDelegate Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY < 0) {
        self.frame = CGRectMake(0, -offsetY, self.frame.size.width, self.frame.size.height);
    }
    if (scrollView.isDragging && offsetY < -50) {
        [self dismiss];
    }
}
@end


#pragma comment tableview cell

#define MAX_CONTENT_WIDTH SCREEN_WIDTH - 55 - 35
//cell
@implementation CommentListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorClear;
        self.clipsToBounds = YES;
        _avatar = [[UIImageView alloc] init];
        _avatar.image = [UIImage imageNamed:@"img_find_default"];
        _avatar.clipsToBounds = YES;
        _avatar.layer.cornerRadius = 14;
        [self addSubview:_avatar];
        
        _likeIcon = [[UIImageView alloc] init];
        _likeIcon.contentMode = UIViewContentModeCenter;
        _likeIcon.image = [UIImage imageNamed:@"icCommentLikeBefore_black"];
        [self addSubview:_likeIcon];
        
        _nickName = [[UILabel alloc] init];
        _nickName.numberOfLines = 1;
        _nickName.textColor = ColorWhiteAlpha60;
        _nickName.font = SmallFont;
        [self addSubview:_nickName];
        
        _content = [[UILabel alloc] init];
        _content.numberOfLines = 0;
        _content.textColor = ColorWhiteAlpha80;
        _content.font = MediumFont;
        [self addSubview:_content];
        
        _date = [[UILabel alloc] init];
        _date.numberOfLines = 1;
        _date.textColor = ColorGray;
        _date.font = SmallFont;
        [self addSubview:_date];
        
        _likeNum = [[UILabel alloc] init];
        _likeNum.numberOfLines = 1;
        _likeNum.textColor = ColorGray;
        _likeNum.font = SmallFont;
        [self addSubview:_likeNum];
        
        _splitLine = [[UIView alloc] init];
        _splitLine.backgroundColor = ColorWhiteAlpha10;
        [self addSubview:_splitLine];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).inset(15);
        make.width.height.mas_equalTo(28);
    }];
    [_likeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self).inset(15);
        make.width.height.mas_equalTo(20);
    }];
    [_nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self.avatar.mas_right).offset(10);
        make.right.equalTo(self.likeIcon.mas_left).inset(25);
    }];
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickName.mas_bottom).offset(5);
        make.left.equalTo(self.nickName);
        make.width.mas_lessThanOrEqualTo(MAX_CONTENT_WIDTH);
    }];
    [_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.content.mas_bottom).offset(5);
        make.left.right.equalTo(self.nickName);
    }];
    [_likeNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.likeIcon);
        make.top.equalTo(self.likeIcon.mas_bottom).offset(5);
    }];
    [_splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.date);
        make.right.equalTo(self.likeIcon);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

-(void)initData:(Comment *)comment {
    NSURL *avatarUrl;
    if([@"user" isEqualToString:comment.user_type]) {
        avatarUrl = [NSURL URLWithString:comment.user.avatar_thumb.url_list.firstObject];
        _nickName.text = comment.user.nickname;
    }else {
        avatarUrl = [NSURL URLWithString:comment.visitor.avatar_thumbnail.url];
        _nickName.text = [comment.visitor formatUDID];
    }
    
    __weak __typeof(self) wself = self;
    [_avatar setImageWithURL:avatarUrl progressBlock:^(CGFloat persent) {
    } completedBlock:^(UIImage *image, NSError *error) {
        image = [image drawCircleImage];
        wself.avatar.image = image;
    }];
    _content.text = comment.text;
    _date.text = [NSDate formatTime:comment.create_time];
    _likeNum.text = [NSString formatCount:comment.digg_count];
    
}

+(CGFloat)cellHeight:(Comment *)comment {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:comment.text];
    [attributedString addAttribute:NSFontAttributeName value:MediumFont range:NSMakeRange(0, attributedString.length)];
    CGSize size = [attributedString multiLineSize:MAX_CONTENT_WIDTH];
    return size.height + 30 + 30;
}
@end







#pragma TextView

#define LEFT_INSET                 15
#define RIGHT_INSET                60
#define TOP_BOTTOM_INSET           15

//#define LEFT_INSET 16
//#define RIGHT_INSET 50
//#define TOP_BOTTOM_INSET 15
@interface CommentTextView ()<UITextViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGFloat            textHeight;
@property (nonatomic, assign) CGFloat            keyboardHeight;
@property (nonatomic, retain) UILabel            *placeHolderLabel;
@property (nonatomic, strong) UIImageView        *atImageView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@end

@implementation CommentTextView
- (instancetype)init {
    self = [super init];
    if(self) {
        self.frame = SCREEN_FRAME;
        self.backgroundColor = ColorClear;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = ColorBlackAlpha40;
        
        _textView.clipsToBounds = NO;
        _textView.textColor = ColorWhite;
        _textView.font = BigFont;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.scrollEnabled = NO;
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _textView.textContainerInset = UIEdgeInsetsMake(TOP_BOTTOM_INSET, LEFT_INSET, TOP_BOTTOM_INSET, RIGHT_INSET);
        _textView.textContainer.lineFragmentPadding = 0;
        _textHeight = ceilf(_textView.font.lineHeight);
        
        _placeHolderLabel = [[UILabel alloc]init];
        _placeHolderLabel.text = @"有爱评论，说点儿好听的~";
        _placeHolderLabel.textColor = ColorGray;
        _placeHolderLabel.font = BigFont;
        [_textView addSubview:_placeHolderLabel];
        [_textView setValue:_placeHolderLabel forKey:@"_placeholderLabel"];
        
        _atImageView = [[UIImageView alloc] init];
        _atImageView.contentMode = UIViewContentModeCenter;
        _atImageView.image = [UIImage imageNamed:@"iconWhiteaBefore"];
        [_textView addSubview:_atImageView];
        [self addSubview:_textView];
        
        
        _textView.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateViewFrame];
}

- (void)updateViewFrame {
    [self updateTextViewFrame];
    
    _atImageView.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 50, 50);
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0f, 10.0f)];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    _textView.layer.mask = shape;
    
}

- (void)updateTextViewFrame {
    CGFloat textViewHeight = _keyboardHeight > 0 ? _textHeight + 2*TOP_BOTTOM_INSET : ceilf(_textView.font.lineHeight) + 2*TOP_BOTTOM_INSET;
    _textView.frame = CGRectMake(0, SCREEN_HEIGHT - _keyboardHeight - textViewHeight, SCREEN_WIDTH, textViewHeight);
}

//keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    _keyboardHeight = [notification keyBoardHeight];
    [self updateTextViewFrame];
    _atImageView.image = [UIImage imageNamed:@"iconBlackaBefore"];
    _textView.backgroundColor = ColorWhite;
    _textView.textColor = ColorBlack;
    self.backgroundColor = ColorBlackAlpha60;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    [self updateTextViewFrame];
    _atImageView.image = [UIImage imageNamed:@"iconWhiteaBefore"];
    _textView.backgroundColor = ColorBlackAlpha40;
    _textView.textColor = ColorWhite;
    self.backgroundColor = ColorClear;
}

//textView delegate
-(void)textViewDidChange:(UITextView *)textView {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
    
    if([textView.attributedText.string isEqualToString:@""]){
        _textHeight = ceilf(_textView.font.lineHeight);
    }else {
        _textHeight = [attributedText multiLineSize:SCREEN_WIDTH - LEFT_INSET - RIGHT_INSET].height;
    }
    [self updateTextViewFrame];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        if(_delegate) {
            [_delegate onSendText:textView.text];
            textView.text = @"";
            _textHeight = ceilf(textView.font.lineHeight);
            [textView resignFirstResponder];
        }
        return NO;
    }
    return YES;
}

//handle guesture tap
- (void)handleGuesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_textView];
    if(![_textView.layer containsPoint:point]) {
        [_textView resignFirstResponder];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        if(hitView.backgroundColor == ColorClear) {
            return nil;
        }
    }
    return hitView;
}

//update method
- (void)show {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)dealloc {
}

@end

