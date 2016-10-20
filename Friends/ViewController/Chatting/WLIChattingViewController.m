//
//  WLIChattingViewController.m
//  Friends
//
//  Created by The Pranav Khandelwal on 5/25/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIChattingViewController.h"

#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "ChatManager.h"
#import "DatabaseManager.h"


@interface WLIChattingViewController ()<UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) MJRefreshHeaderView *head;
@property (strong, nonatomic) ChatModel *chatModel;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation WLIChattingViewController
{
    UUInputFunctionView *IFView;
    CGFloat MainView_Y;
    WLIUser *currentUser;
    int chatLoad;
    int chatLimit;
    
    BOOL isGallery;
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil completion:(void (^)(NSString *))completion
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if( self )
    {
        //store completion block
        _completion = completion;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isGallery = NO;
    
    currentUser = [WLIConnect sharedConnect].currentUser;
    
    [[ChatManager getInstance] chatServerSetup];
    
    [[ChatManager getInstance] subscribe:self.channelID];
    
    chatLoad = 0;
    chatLimit = 50;
    
    [self initBar];
    [self addRefreshViews];
    [self loadBaseViewsAndData];
}

- (void)receiveMessage:(NSNotification*)notification {
    NSLog(@"receiveMessage %@", notification.userInfo);
    
    NSString *str_fromid = [notification.userInfo objectForKey:@"fromId"];
    
    if ([str_fromid integerValue] == [WLIConnect sharedConnect].currentUser.userID) {
        NSDictionary *dic;
        if ([[notification.userInfo objectForKey:@"isImage"] isEqualToString:@"1"]) {
             dic = @{@"strContent": [notification.userInfo objectForKey:@"key"], @"type":@(UUMessageTypePicture)};
             //[[DatabaseManager getInstance] saveChat:@{@"to_user_id":[NSNumber numberWithInt:self.toUserID.userID],@"from_user_id":[NSNumber numberWithInt:[WLIConnect sharedConnect].currentUser.userID],@"message":[notification.userInfo objectForKey:@"key"],@"created_date":[[NSDate date] description],@"unread":@0,@"isImage":@1,@"server_date":[[NSDate date] description]}];
        }else
        {
            dic = @{@"strContent": [notification.userInfo objectForKey:@"key"], @"type":@(UUMessageTypeText)};
            //[[DatabaseManager getInstance] saveChat:@{@"to_user_id":[NSNumber numberWithInt:self.toUserID.userID],@"from_user_id":[NSNumber numberWithInt:[WLIConnect sharedConnect].currentUser.userID],@"message":[notification.userInfo objectForKey:@"key"],@"created_date":[[NSDate date] description],@"unread":@0,@"isImage":@0,@"server_date":[[NSDate date] description]}];
        }
        
        
        [self.chatModel addMYSpecifiedItem:dic];
        [self.chatTableView reloadData];
        [self tableViewScrollToBottom];

    }else{
        
        NSDictionary *dic;
        if ([[notification.userInfo objectForKey:@"isImage"] isEqualToString:@"1"]) {
            dic = @{@"strContent": [notification.userInfo objectForKey:@"key"], @"type":@(UUMessageTypePicture)};
            //[[DatabaseManager getInstance] saveChat:@{@"to_user_id":[NSNumber numberWithInt:[WLIConnect sharedConnect].currentUser.userID],@"from_user_id":[NSNumber numberWithInt:self.toUserID.userID],@"message":[notification.userInfo objectForKey:@"key"],@"created_date":[[NSDate date] description],@"unread":@0,@"isImage":@1,@"server_date":[[NSDate date] description]}];
        }else
        {
           dic = @{@"strContent": [notification.userInfo objectForKey:@"key"], @"type":@(UUMessageTypeText)};
            //[[DatabaseManager getInstance] saveChat:@{@"to_user_id":[NSNumber numberWithInt:[WLIConnect sharedConnect].currentUser.userID],@"from_user_id":[NSNumber numberWithInt:self.toUserID.userID],@"message":[notification.userInfo objectForKey:@"key"],@"created_date":[[NSDate date] description],@"unread":@0,@"isImage":@0,@"server_date":[[NSDate date] description]}];
            
        }
        
        
        [self.chatModel addOtherSpecifiedItem:dic];
        [self.chatTableView reloadData];
        [self tableViewScrollToBottom];
    
    }
    
    
    
   
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:@"chatmessage" object:nil];
    MainView_Y = self.view.frame.origin.y;
    [self loadPreviousChat];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //_completion(@"ChattingVC");
}

- (void)initBar
{
    //self.title = @"Chat";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    //self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:nil action:nil];
    
}


- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    
    //load more
    int pageNum = 3;
    
    _head = [MJRefreshHeaderView header];
    _head.scrollView = self.chatTableView;
    _head.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        //[weakSelf.chatModel addRandomItemsToDataSource:pageNum];
        [weakSelf loadPreviousChat];
        
        if (weakSelf.chatModel.dataSource.count>pageNum) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.chatTableView reloadData];
                [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }
        [weakSelf.head endRefreshing];
    };
}

- (void)loadBaseViewsAndData
{
    self.chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.chatModel = [[ChatModel alloc]init];
    [self.chatModel populateRandomDataSource];
    
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
//    IFView.frame = CGRectMake(0, 400, self.view.frame.size.width, self.view.frame.size.height);
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust UUInputFunctionView's originPoint
    //CGRect newFrame = IFView.frame;
    CGRect newFrame = self.view.frame;
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = keyboardEndFrame.size.height+40;
        //newFrame.origin.y = self.view.frame.size.height-(keyboardEndFrame.size.height+40);
    newFrame.origin.y = MainView_Y-keyboardEndFrame.size.height;
    }else{
        self.bottomConstraint.constant = 40;
        //newFrame.origin.y = self.view.frame.size.height-40;
        newFrame.origin.y = MainView_Y;
    }
    self.view.frame = newFrame;
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSLog(@"%@",self.chatModel.dataSource);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    [[ChatManager getInstance] sendMessage:message withfromid:[NSString stringWithFormat:@"%d",[WLIConnect sharedConnect].currentUser.userID] isImage:@"0" toUser:self.toUserID];
    [sharedConnect sendChatDataUserID:[WLIConnect sharedConnect].currentUser.userID toUser:self.toUserID.userID message:message onCompletion:^(ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            NSLog(@"Message Saved Successfully");
        }
        else if (serverResponseCode == NO_CONNECTION)
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else
        {
             NSLog(@"Some Error Occurred.");
        }
    }];
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
//    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    [sharedConnect sendChatImageFromUser:[WLIConnect sharedConnect].currentUser.userID toUser:self.toUserID.userID userAvatar:image onCompletion:^(NSString *imageUrl, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            [[ChatManager getInstance] sendMessage:imageUrl withfromid:[NSString stringWithFormat:@"%d",[WLIConnect sharedConnect].currentUser.userID] isImage:@"1" toUser:self.toUserID];

        } else if (serverResponseCode == NO_CONNECTION) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
//    NSDictionary *dic = @{@"picture": image, @"type":@(UUMessageTypePicture)};
//    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    //NSDictionary *dic = @{@"voice": voice, @"strVoiceTime":[NSString stringWithFormat:@"%d",(int)second], @"type":@(UUMessageTypeVoice)};
//    [self dealTheFunctionData:dic];
}



#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
    // headIamgeIcon is clicked
    /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tip" message:@"HeadImageClick !!!" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];*/
}

-(void)loadPreviousChat
{
    NSMutableArray *results = [NSMutableArray array];
    //results = [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_chat_detail WHERE (to_user_id = %d AND from_user_id = %d) OR (to_user_id = %d AND from_user_id = %d) ORDER BY chat_detail_id DESC LIMIT %d OFFSET %d;",currentUser.userID,self.toUserID.userID,self.toUserID.userID,currentUser.userID,chatLimit,chatLoad*50]];
    results = [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT * FROM tbl_chat_detail WHERE (to_user_id = %d AND from_user_id = %d) OR (to_user_id = %d AND from_user_id = %d) ORDER BY server_date DESC LIMIT %d OFFSET %d;",currentUser.userID,self.toUserID.userID,self.toUserID.userID,currentUser.userID,chatLimit,chatLoad*50]];
    //NSLog(@"Results: %@",results);
    if (results.count == 50) {
        chatLoad++;
        chatLimit=50;
    }
    else
        chatLimit=0;
    self.chatModel.toUser = self.toUserID;
    for (NSDictionary *result in results) {
        if ([[result objectForKey:@"isImage"] intValue] == 1) {
            [self.chatModel loadPreviousImage:result];
        }else
        [self.chatModel loadPreviousChat:result];
    }
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];

}

-(void)viewWillUnload
{
    [[ChatManager getInstance] chatServerClose];
}

@end
