//
//  WLICommentsViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLICommentsViewController.h"
#import "WLICommentCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import "NSString+FontAwesome.h"

@implementation WLICommentsViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.comments = [NSMutableArray array];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //self.title = @"Comments";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    [self reloadData:YES];
    //self.viewEnterComment.frame = CGRectMake(0, CGRectGetMaxY(self.tableViewRefresh.frame), CGRectGetWidth(self.viewEnterComment.frame), CGRectGetHeight(self.viewEnterComment.frame));
    //[self.view addSubview:self.viewEnterComment];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lbl_Comment.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Comment.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil"];
    self.lbl_Comment.textColor = [UIColor whiteColor];
    self.lbl_Comment.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.textFieldEnterComment.layer.masksToBounds=YES;
    self.textFieldEnterComment.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.textFieldEnterComment.layer.borderWidth= 1.0f;
    self.textFieldEnterComment.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.textFieldEnterComment.leftViewMode = UITextFieldViewModeAlways;

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    int page = reloadAll ? 1 : (self.comments.count / kDefaultPageSize) + 1;
    [sharedConnect commentsForPostID:self.post.postID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *comments, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.comments removeAllObjects];
        }
        [self.comments addObjectsFromArray:comments];
        loadMore = comments.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLICommentCell";
        WLICommentCell *cell = (WLICommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLICommentCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.comment = self.comments[indexPath.row];
        return cell;
    } else {
        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
        return self.comments.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WLIComment *comment = self.comments[indexPath.row];
        [sharedConnect removeCommentWithCommentID:comment.commentID onCompletion:^(ServerResponse serverResponseCode) {
            
        }];
    }
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [WLICommentCell sizeWithComment:self.comments[indexPath.row]].height;
    } else if (indexPath.section == 0){
        return 44 * loadMore * self.comments.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.31 animations:^{
        self.viewEnterComment.center = CGPointMake(self.viewEnterComment.center.x, self.viewEnterComment.center.y - 210);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.31 animations:^{
        self.viewEnterComment.center = CGPointMake(self.viewEnterComment.center.x, self.viewEnterComment.center.y + 210);
    } completion:^(BOOL finished) {
        if (self.textFieldEnterComment.text.length) {
            
            [hud show:YES];
            [sharedConnect sendCommentOnPostID:self.post.postID withCommentText:self.textFieldEnterComment.text onCompletion:^(WLIComment *comment, ServerResponse serverResponseCode) {
                [hud hide:YES];
                [self.comments insertObject:comment atIndex:0];
                [self.tableViewRefresh reloadData];
                self.textFieldEnterComment.text = @"";
            }];
        }
    }];
}

@end
