//
//  WLISearchPostViewController.h
//  Friends
//
//  Created by Kapil on 14/05/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLISearchPostViewController : WLIViewController <CLLocationManagerDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *sgmtBGView;
@property (weak, nonatomic) IBOutlet UITableView *tblvFriends;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmtNearCustom;
@property (strong, nonatomic) NSString *backViewContoller;
@property (weak, nonatomic) IBOutlet UISearchBar *srchLocation;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Background;

//Methods
- (IBAction)segmentValueChanged:(id)sender;
-(void)CallSearchResults:(NSDictionary *)info;

@end
