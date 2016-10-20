//
//  WLIFilterViewController.h
//  Friends
//
//  Created by Kapil on 18/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

@import UIKit;
#import "WLIViewController.h"
#import "REDRangeSlider.h"
#import <Foundation/Foundation.h>
#import "VENTokenField.h"

@interface WLIFilterViewController : WLIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,VENTokenFieldDataSource,VENTokenFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ageLowerRange;
@property (weak, nonatomic) IBOutlet UILabel *ageUpperRange;
@property (weak, nonatomic) IBOutlet UITextField *txtInterests;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (weak, nonatomic) IBOutlet UITableView *tblvLocation;
@property (strong,nonatomic) void(^completion)(NSDictionary *info,NSString *backVC);
@property (weak, nonatomic) IBOutlet UILabel *lbl_Interests;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Gender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Age;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Status;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Locations;
@property (weak, nonatomic) IBOutlet UIView *view_Gender;
@property (weak, nonatomic) IBOutlet UIView *view_Age;
@property (weak, nonatomic) IBOutlet UIView *view_Status;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmt_Gender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmt_Status;
@property (weak, nonatomic) IBOutlet VENTokenField *ven_Interests;
@property (strong, nonatomic) NSMutableArray *names;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Occupation;
@property (weak, nonatomic) IBOutlet UITextField *txt_Occupation;

@property (strong, nonatomic) REDRangeSlider *ageRangeSlider;

//Methods
- (void)updateSliderLabels;
- (void)rangeSliderValueChanged:(id)sender;
- (IBAction)SearchButtonPressed:(id)sender;
- (IBAction)GenderSegmentValueChanged:(id)sender;
- (IBAction)StatusSegmentValueChanged:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil completion:(void(^)(NSDictionary *,NSString *))completion;

@end
