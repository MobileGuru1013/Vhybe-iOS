//
//  WLISearchPostViewController.m
//  Friends
//
//  Created by Kapil on 14/05/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "WLISearchPostViewController.h"
#import "WLINearbyViewController.h"
#import "WLIFilterViewController.h"
#import "UIImage+FontAwesome.h"
#import "WLIUserCell.h"

@interface WLISearchPostViewController ()

@end

@implementation WLISearchPostViewController
{
    int i;
    CLLocationManager *locationManager;
    NSArray *arry_Nearby;
    NSArray *arry_Custom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Search";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    
    UIBarButtonItem *nearbyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithIcon:@"fa-map-marker" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:25] style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemNearbyTouchUpInside:)];
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithIcon:@"fa-filter" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:25] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemFilterTouchUpInside:)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:filterButton,nearbyButton, nil];
    locationManager = [[CLLocationManager alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    arry_Nearby = [NSMutableArray array];
    arry_Custom = [NSMutableArray array];
    
    if (self.sgmtNearCustom.selectedSegmentIndex == 0) {
        i=0;
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        [hud show:YES];
        CGRect frame = self.tblvFriends.frame;
        frame.origin.y = self.sgmtBGView.frame.origin.y+self.sgmtBGView.frame.size.height;
        self.tblvFriends.frame = frame;
    }
    else
    {
        self.srchLocation.hidden = NO;
        CGRect frame = self.tblvFriends.frame;
        frame.origin.y = self.srchLocation.frame.origin.y+self.srchLocation.frame.size.height;
        self.tblvFriends.frame = frame;
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions methods

- (void)barButtonItemNearbyTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    
    WLINearbyViewController *nearbyViewController = [[WLINearbyViewController alloc] initWithNibName:@"WLINearbyViewController" bundle:nil];
    UINavigationController *nearbyNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyViewController];
    nearbyNavigationController.navigationBar.translucent = NO;
    [self presentViewController:nearbyNavigationController animated:YES completion:nil];
}

- (void)barButtonItemFilterTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    
    WLIFilterViewController *filterViewController = [[WLIFilterViewController alloc] initWithNibName:@"WLIFilterViewController" bundle:nil completion:^(NSDictionary *info,NSString *backVC){
        NSLog(@"view2 is closed");
        self.backViewContoller = backVC;
        self.srchLocation.hidden = YES;
        [self CallSearchResults:info];
    }];
    UINavigationController *filterNavigationController = [[UINavigationController alloc] initWithRootViewController:filterViewController];
    filterNavigationController.navigationBar.translucent = NO;
    [self presentViewController:filterNavigationController animated:YES completion:nil];
}

- (IBAction)segmentValueChanged:(id)sender {
    if (self.sgmtNearCustom.selectedSegmentIndex == 0) {
        //[arry_Nearby removeAllObjects];
        arry_Nearby = nil;
        [self.tblvFriends reloadData];
        i=0;
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        self.srchLocation.hidden = YES;
        [hud show:YES];
        
        CGRect frame = self.tblvFriends.frame;
        frame.origin.y = self.sgmtBGView.frame.origin.y+self.sgmtBGView.frame.size.height;
        self.tblvFriends.frame = frame;
    }
    else
    {
        arry_Custom = nil;
        //[arry_Custom removeAllObjects];
        [self.tblvFriends reloadData];
        self.srchLocation.hidden = NO;
        CGRect frame = self.tblvFriends.frame;
        frame.origin.y = self.srchLocation.frame.origin.y+self.srchLocation.frame.size.height;
        self.tblvFriends.frame = frame;
    }   
}

-(void)CallSearchResults:(NSDictionary *)info
{
    if (self.backViewContoller.length) {
        self.backViewContoller=nil;
        self.sgmtNearCustom.selectedSegmentIndex = 1;
        self.srchLocation.hidden = YES;
    }
    NSLog(@"Info: %@",info);
    
    [sharedConnect usersForSearchString:[info objectForKey:@"SearchText"] interests:[info objectForKey:@"SearchInterest"] occupation:[info objectForKey:@"SearchOccupation"] gender:[info objectForKey:@"SearchGender"] maxage:[[info objectForKey:@"SearchMaxAge"] integerValue] minage:[[info objectForKey:@"SearchMinAge"] integerValue] maritalstatus:[info objectForKey:@"SearchStatus"] location:nil lat:[[info objectForKey:@"CurrentLatitude"] floatValue] longitude:[[info objectForKey:@"CurrentLongitude"] floatValue] page:0 pageSize:0 onCompletion:^(NSMutableArray *users, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            if (users) {
                if (self.sgmtNearCustom.selectedSegmentIndex == 0) {
                    arry_Nearby = users;
                    //[arry_Nearby addObjectsFromArray:users];
                }
                 else
                 {
                     arry_Custom = users;
                     //[arry_Custom addObjectsFromArray:users];
                 }
                [self.tblvFriends reloadData];
            }
            self.lbl_Background.hidden = YES;
            self.tblvFriends.hidden = NO;
        } else if (serverResponseCode == NOT_FOUND) {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"No results found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_Background.text = @"No results found.";
            self.lbl_Background.hidden = NO;
            self.tblvFriends.hidden = YES;
        } else if (serverResponseCode == NO_CONNECTION) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_Background.text = @"No connection. Please try again.";
            self.lbl_Background.hidden = NO;
            self.tblvFriends.hidden = YES;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_Background.text = @"Something went wrong. Please try again.";
            self.lbl_Background.hidden = NO;
            self.tblvFriends.hidden = YES;
        }

    }];
    
    [hud hide:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [hud hide:YES];
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil && i==0) {
        i++;
        [self CallSearchResults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:currentLocation.coordinate.longitude],@"CurrentLongitude",[NSNumber numberWithFloat:currentLocation.coordinate.latitude],@"CurrentLatitude",@"1",@"SearchType", nil]];
    }
    
    [locationManager stopUpdatingLocation];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

        static NSString *CellIdentifier = @"WLIUserCell";
        WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
    if (self.sgmtNearCustom.selectedSegmentIndex == 0) {
     cell.user = arry_Nearby[indexPath.row];
    }
    else
    {
    cell.user = arry_Custom[indexPath.row];
    }
    cell.cellBtn_Chat.hidden = YES;
    cell.buttonFollowUnfollow.hidden = YES;
    
        return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sgmtNearCustom.selectedSegmentIndex == 0) {
        return [arry_Nearby count];
    }
    else
    {
       return [arry_Custom count];
    }

}

#pragma mark - SearchBar methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    //[arry_Custom removeAllObjects];
    arry_Custom = nil;
    if (searchBar.text.length) {
        [self CallSearchResults:[NSDictionary dictionaryWithObjectsAndKeys:searchBar.text,@"SearchText",@"2",@"SearchType", nil]];
    }
}

@end
