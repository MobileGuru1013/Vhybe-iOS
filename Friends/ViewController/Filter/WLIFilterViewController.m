//
//  WLIFilterViewController.m
//  Friends
//
//  Created by Kapil on 18/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIFilterViewController.h"
#import "WLISearchPostViewController.h"
#import "NSString+FontAwesome.h"

#define kGoogleAutocompleteLink @"https://maps.googleapis.com/maps/api/place/autocomplete/json"

@interface WLIFilterViewController ()

@end

@implementation WLIFilterViewController
{
    NSArray *arryPickerValues;
    BOOL isInterests;
    BOOL isOccupation;
    BOOL isOccupationSelected;
    CGRect tbl_Frame;
    CGFloat mainView_Y;
    
    float locationLatitude;
    float locationLongitude;
    NSMutableArray *arryLocationsValue;
    NSMutableArray *arryLocationsID;
    NSArray *arry_Interests;
    NSArray *arry_Occupation;
    NSMutableArray *arry_InterestsSearch;
}



-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil completion:(void (^)(NSDictionary *, NSString *))completion
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
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Filter";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    self.names = [NSMutableArray array];
    self.ven_Interests.delegate = self;
    self.ven_Interests.dataSource = self;
    self.ven_Interests.placeholderText = NSLocalizedString(@"Interests", nil);
    self.ven_Interests.toLabelText = NSLocalizedString(@"", nil);
    [self.ven_Interests setColorScheme:[UIColor colorWithRed:53./255.0f green:53./255.0f blue:53./255.0f alpha:1.0f]];
    //[self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    //ilself.tokenField.delimiters = @[@",", @";", @"--"];
    //[self.tokenField becomeFirstResponder];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserInterests"]) {
        arry_Interests = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInterests"]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserOccupation"]) {
        arry_Occupation = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserOccupation"]];
    }
    tbl_Frame = self.tblvLocation.frame;
    isInterests = NO;
    isOccupation = NO;
    isOccupationSelected = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.ageRangeSlider = [[REDRangeSlider alloc] initWithFrame:CGRectMake(3, self.ageLowerRange.frame.origin.y+self.ageLowerRange.frame.size.height+20, self.view_Age.frame.size.width-40, self.ageLowerRange.frame.size.height)];
    self.ageRangeSlider.backgroundWidth = self.view_Age.frame.size.width-10;
    
    self.ageRangeSlider.maxValue = 100;
    self.ageRangeSlider.minValue = 11;
    [self.ageRangeSlider addTarget:self action:@selector(rangeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view_Age addSubview:self.ageRangeSlider];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FilterInterests"]) {
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterInterests"];
        NSArray *str_arry = [str componentsSeparatedByString:@","];
        for (int i=0; i<[str_arry count]-1; i++) {
            [self.names addObject:[str_arry objectAtIndex:i]];
        }
        [self.ven_Interests reloadData];
        [self.ven_Interests collapse];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FilterOccupation"]) {
        self.txt_Occupation.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterOccupation"];
        isOccupationSelected = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FilterGender"]) {
        self.sgmt_Gender.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FilterGender"] integerValue];
    }
    else
        self.sgmt_Gender.selectedSegmentIndex = 2;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FilterageLowerRange"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterageUpperRange"]) {
        self.ageRangeSlider.leftValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FilterageLowerRange"] integerValue];
        self.ageLowerRange.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterageLowerRange"];
        self.ageRangeSlider.rightValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FilterageUpperRange"] integerValue];
        self.ageUpperRange.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterageUpperRange"];
    }
    else
    {
        self.ageRangeSlider.leftValue = 11;
        self.ageRangeSlider.rightValue = 100;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FilterStatus"]) {
        self.sgmt_Status.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FilterStatus"] integerValue];
    }
    else
        self.sgmt_Status.selectedSegmentIndex = 2;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FilterlocationLongitude"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterlocationLatitude"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterLocation"]) {
        locationLongitude = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FilterlocationLongitude"] floatValue];
        locationLatitude = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FilterlocationLatitude"] floatValue];
        self.txtLocation.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FilterLocation"];
    }
    
    [self updateSliderLabels];
    
    // register keyboard notifications to appear / disappear the keyboard
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    mainView_Y = self.view.frame.origin.y;
    
    self.lbl_Interests.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Interests.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"];
    self.lbl_Interests.textColor = [UIColor whiteColor];
    self.lbl_Interests.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.ven_Interests.layer.masksToBounds=YES;
    self.ven_Interests.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.ven_Interests.layer.borderWidth= 1.0f;
    self.ven_Interests.verticalInset = 2.0;
    self.ven_Interests.placeholderText = @"Interests";
    /*self.ven_Interests.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.ven_Interests.leftViewMode = UITextFieldViewModeAlways;*/
    
    self.lbl_Gender.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Gender.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-thin"];
    self.lbl_Gender.textColor = [UIColor whiteColor];
    self.lbl_Gender.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    CGRect Genderframe = self.sgmt_Gender.frame;
    Genderframe.size.height = self.lbl_Gender.frame.size.height+8;
    self.sgmt_Gender.frame = Genderframe;
    CALayer *view_GenderSgmtBorder = [CALayer layer];
    view_GenderSgmtBorder.frame = CGRectMake(self.view_Gender.frame.size.width-1, 0.0f, 1.0f, self.view_Gender.frame.size.height);
    view_GenderSgmtBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.view_Gender.layer addSublayer:view_GenderSgmtBorder];
    
    self.lbl_Age.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Age.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"];
    self.lbl_Age.textColor = [UIColor whiteColor];
    self.lbl_Age.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.view_Age.layer.masksToBounds=YES;
    self.view_Age.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.view_Age.layer.borderWidth= 1.0f;
    
    self.lbl_Status.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Status.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-venus-mars"];
    self.lbl_Status.textColor = [UIColor whiteColor];
    self.lbl_Status.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    CGRect Statusframe = self.sgmt_Status.frame;
    Statusframe.size.height = self.lbl_Status.frame.size.height+8;
    self.sgmt_Status.frame = Genderframe;
    CALayer *view_StatusSgmtBorder = [CALayer layer];
    view_StatusSgmtBorder.frame = CGRectMake(self.view_Status.frame.size.width-1, 0.0f, 1.0f, self.view_Status.frame.size.height);
    view_StatusSgmtBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.view_Status.layer addSublayer:view_StatusSgmtBorder];
    
    self.lbl_Locations.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Locations.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"];
    self.lbl_Locations.textColor = [UIColor whiteColor];
    self.lbl_Locations.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtLocation.layer.masksToBounds=YES;
    self.txtLocation.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtLocation.layer.borderWidth= 1.0f;
    self.txtLocation.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtLocation.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_Occupation.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Occupation.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-briefcase"];
    self.lbl_Occupation.textColor = [UIColor whiteColor];
    self.lbl_Occupation.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txt_Occupation.layer.masksToBounds=YES;
    self.txt_Occupation.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txt_Occupation.layer.borderWidth= 1.0f;
    self.txt_Occupation.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txt_Occupation.leftViewMode = UITextFieldViewModeAlways;
    
    self.tblvLocation.layer.masksToBounds=YES;
    self.tblvLocation.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.tblvLocation.layer.borderWidth= 1.0f;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.ageLowerRange.text = @"11";
    self.ageUpperRange.text = @"100";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.tblvLocation.hidden = YES;
    isInterests = NO;
    isOccupation = NO;
    self.tblvLocation.frame = tbl_Frame;
    [self.ven_Interests collapse];
    [self.ven_Interests resignFirstResponder];
    [self.txtInterests resignFirstResponder];
    [self.txt_Occupation resignFirstResponder];
    [self.txtLocation resignFirstResponder];
    [self keyboardWillDisappear:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while moving to the other screen.
    /*[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];*/
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

- (IBAction)SearchButtonPressed:(id)sender {
    NSString *Gender;
    NSString *Status;
    NSMutableDictionary *send =[[NSMutableDictionary alloc] init];
    
    if (self.names) {
        NSMutableString *str = [[NSMutableString alloc] initWithString:@""];
        for (NSString *interests in self.names) {
            [str appendString:[NSString stringWithFormat:@"%@,",interests]];
        }
        if (str.length) {
            [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"FilterInterests"];
            [send setValue:str forKey:@"SearchInterest"];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"FilterInterests"];
    }
    
    if (self.sgmt_Gender.selectedSegmentIndex == 0) {
        Gender = @"male";
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)self.sgmt_Gender.selectedSegmentIndex] forKey:@"FilterGender"];
        [send setValue:Gender forKey:@"SearchGender"];
    }
    else if (self.sgmt_Gender.selectedSegmentIndex == 1) {
        Gender = @"female";
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)self.sgmt_Gender.selectedSegmentIndex] forKey:@"FilterGender"];
        [send setValue:Gender forKey:@"SearchGender"];
    }
    if (self.sgmt_Status.selectedSegmentIndex == 0) {
        Status = @"single";
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)self.sgmt_Status.selectedSegmentIndex] forKey:@"FilterStatus"];
        [send setValue:Gender forKey:@"SearchStatus"];
    }
    else if (self.sgmt_Status.selectedSegmentIndex == 1) {
        Status = @"married";
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)self.sgmt_Status.selectedSegmentIndex] forKey:@"FilterStatus"];
        [send setValue:Gender forKey:@"SearchStatus"];
    }
    if (self.ageLowerRange && self.ageUpperRange) {
        [[NSUserDefaults standardUserDefaults] setObject:self.ageLowerRange.text forKey:@"FilterageLowerRange"];
        [[NSUserDefaults standardUserDefaults] setObject:self.ageUpperRange.text forKey:@"FilterageUpperRange"];
        [send setValue:self.ageUpperRange.text forKey:@"SearchMaxAge"];
        [send setValue:self.ageLowerRange.text forKey:@"SearchMinAge"];
    }
    
    if (isOccupationSelected) {
        [[NSUserDefaults standardUserDefaults] setObject:self.txt_Occupation.text forKey:@"FilterOccupation"];
        [send setValue:self.txt_Occupation.text forKey:@"SearchOccupation"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"FilterOccupation"];
    }
    
    if (locationLongitude && locationLatitude) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",locationLongitude] forKey:@"FilterlocationLongitude"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",locationLatitude]  forKey:@"FilterlocationLatitude"];
        [[NSUserDefaults standardUserDefaults] setObject:self.txtLocation.text forKey:@"FilterLocation"];
        [send setValue:[NSNumber numberWithFloat:locationLongitude] forKey:@"CurrentLongitude"];
        [send setValue:[NSNumber numberWithFloat:locationLatitude] forKey:@"CurrentLatitude"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"FilterlocationLongitude"];
    }
    [send setValue:@"3" forKey:@"SearchType"];
    
    _completion(send,@"FilterVC");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)GenderSegmentValueChanged:(id)sender {
}

- (IBAction)StatusSegmentValueChanged:(id)sender {
}

- (IBAction)GenderPickerShow:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    arryPickerValues = @[@"Male",@"Female",@"Both"];
    //isGenderPicker = YES;
}

- (IBAction)StatusPickerShow:(id)sender {
    [self touchesBegan:nil withEvent:nil];
    arryPickerValues = @[@"Single",@"Married",@"Both"];
    //isGenderPicker = NO;
}

#pragma mark - Label  Slider

- (IBAction)rangeSliderValueChanged:(id)sender {
    [self updateSliderLabels];
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    /*CGPoint lowerCenter;
    lowerCenter.x = (self.ageRangeSlider..x + self.ageRangeSlider.frame.origin.x);
    lowerCenter.y = (self.ageRangeSlider.center.y - 30.0f);
    self.ageLowerRange.center = lowerCenter;*/
    self.ageLowerRange.text = [NSString stringWithFormat:@"%d", (int)self.ageRangeSlider.leftValue];
    
    /*CGPoint upperCenter;
    upperCenter.x = (self.ageRangeSlider.upperCenter.x + self.ageRangeSlider.frame.origin.x);
    upperCenter.y = (self.ageRangeSlider.center.y - 30.0f);
    self.ageUpperRange.center = upperCenter;*/
    self.ageUpperRange.text = [NSString stringWithFormat:@"%d", (int)self.ageRangeSlider.rightValue];
}

#pragma mark - PickerView

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arryPickerValues.count;
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = arryPickerValues[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}

/*// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return arryPickerValues[row];
}
*/

// The data to return for the row and component (column) that's being passed in
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

#pragma mark - Keyboard Notification
/*
- (void)keyboardWillAppear:(NSNotification *)n
{
   CGFloat keyboard_Y = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    if ((txtField_Y+txtField_Height)>keyboard_Y) {
        CGFloat view_Y = (txtField_Y+txtField_Height)-keyboard_Y+20;
        CGRect frame = self.view.frame;
        frame.origin.y = 0-view_Y;
        self.view.frame = frame;
    }
}
*/
- (void)keyboardWillDisappear:(NSNotification *)n
{
    if(self.view.frame.origin.y!=mainView_Y)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = mainView_Y;
        self.view.frame = frame;
    }
//    txtField_Y = 0;
//    txtField_Height = 0;
}

#pragma mark - textField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 2) {
        isOccupation = YES;
        isOccupationSelected = NO;
        [self.txt_Occupation setText:@""];
        CGRect frame = self.tblvLocation.frame;
        frame.origin.y = self.txt_Occupation.frame.origin.y+self.txt_Occupation.frame.size.height;
        self.tblvLocation.frame = frame;
    }else
    {
        isOccupation = NO;
        [self.txtLocation setText:@""];
        locationLatitude = 0.0;
        locationLongitude = 0.0;
    }
    [self.view setFrame:CGRectMake(0,mainView_Y - (textField.frame.origin.y-mainView_Y), self.view.frame.size.width, self.view.frame.size.height)];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 2)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",textField.text];
        arry_InterestsSearch = [NSMutableArray arrayWithArray:[arry_Occupation filteredArrayUsingPredicate:predicate]];
        [self.tblvLocation reloadData];
        self.tblvLocation.hidden = NO;
    }
    else
    {
        if (![textField.text isEqualToString:@""]) {
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@?input=%@&types=%@&key=%@",kGoogleAutocompleteLink, textField.text, @"(cities)", @"AIzaSyBAXCzXn17NxPOpVHUQIn-ZmfbdPswOipI"];
            NSURL *url = [[NSURL alloc] initWithString:urlAsString];
            NSLog(@"%@", urlAsString);
            [hud show:YES];
            [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (error) {
                    [self GoogleAutoCompleteFailed:error];
                } else {
                    [self GoogleAutoCompleteResponse:data];
                }
            }];
        }
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.tblvLocation.hidden = YES;
}

#pragma mark - Google Autocomplete

-(void)GoogleAutoCompleteResponse:(NSData *)response
{
    NSError *error;
    [hud hide:YES];
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    NSLog(@"Response: %@",parsedObject);
    if([[parsedObject valueForKey:@"status"] isEqualToString:@"OK"])
    {
        arryLocationsValue = [[NSMutableArray alloc] init];
        arryLocationsID = [[NSMutableArray alloc] init];
        self.tblvLocation.hidden = NO;
        for (NSDictionary *objects in [parsedObject valueForKey:@"predictions"]) {
            [arryLocationsValue addObject:[objects valueForKey:@"description"]];
            [arryLocationsID addObject:[objects valueForKey:@"place_id"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblvLocation reloadData];
        });
        
    }
    else
    {
        NSLog(@"Status:%@, Error: %@",[parsedObject valueForKey:@"status"],[parsedObject valueForKey:@"error_message"]);
    }
    
}

-(void)GoogleAutoCompleteFailed:(NSError *)error
{
    NSLog(@"Error: %@",error);
}

-(void)GooglePlacesResponse:(NSData *)response
{
    NSError *error;
    
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    NSLog(@"Response: %@",parsedObject);
    if([[parsedObject valueForKey:@"status"] isEqualToString:@"OK"])
    {
        locationLatitude = [[[[[parsedObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
        locationLongitude = [[[[[parsedObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
    }
    else
    {
        NSLog(@"Status:%@, Error: %@",[parsedObject valueForKey:@"status"],[parsedObject valueForKey:@"error_message"]);
    }
    
}

-(void)GooglePlacesFailed:(NSError *)error
{
    NSLog(@"Error: %@",error);
}

#pragma mark - TableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isInterests || isOccupation)
        return [arry_InterestsSearch count];
    else
        return [arryLocationsValue count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if (isInterests || isOccupation)
        cell.textLabel.text = [arry_InterestsSearch objectAtIndex:indexPath.row];
    else
        cell.textLabel.text = [arryLocationsValue objectAtIndex:indexPath.row];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tblvLocation.hidden = YES;
    if (isInterests) {
        [self.names addObject:[arry_InterestsSearch objectAtIndex:indexPath.row]];
        [self.ven_Interests reloadData];
        [self.ven_Interests collapse];
        [self.ven_Interests resignFirstResponder];
        isInterests = NO;
        self.tblvLocation.frame = tbl_Frame;
    }
    else if (isOccupation)  {
        self.txt_Occupation.text = [arry_InterestsSearch objectAtIndex:indexPath.row];
        [self.txt_Occupation resignFirstResponder];
        [self keyboardWillDisappear:nil];
        isOccupation = NO;
        isOccupationSelected = YES;
        self.tblvLocation.frame = tbl_Frame;
    }
    else
    {
        self.txtLocation.text = [arryLocationsValue objectAtIndex:indexPath.row];
        [self.txtLocation resignFirstResponder];
        [self keyboardWillDisappear:nil];
        NSString *urlAsString = [NSString stringWithFormat:@"%@?placeid=%@&key=%@",@"https://maps.googleapis.com/maps/api/place/details/json", [arryLocationsID objectAtIndex:[indexPath row]], @"AIzaSyBAXCzXn17NxPOpVHUQIn-ZmfbdPswOipI"];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        NSLog(@"%@", urlAsString);
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (error) {
                [self GooglePlacesFailed:error];
            } else {
                [self GooglePlacesResponse:data];
            }
        }];
    }
    
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    //[self.names addObject:text];
    //[self.ven_Interests reloadData];
    [tokenField collapse];
    [tokenField resignFirstResponder];
    self.tblvLocation.hidden = YES;
    isInterests = NO;
    self.tblvLocation.frame = tbl_Frame;
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.names removeObjectAtIndex:index];
    [self.ven_Interests reloadData];
}

-(void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text
{
    isInterests = YES;
    CGRect frame = self.tblvLocation.frame;
    frame.origin.y = self.ven_Interests.frame.origin.y+self.ven_Interests.frame.size.height;
    self.tblvLocation.frame = frame;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",text];
    arry_InterestsSearch = [NSMutableArray arrayWithArray:[arry_Interests filteredArrayUsingPredicate:predicate]];
    [self.tblvLocation reloadData];
    self.tblvLocation.hidden = NO;
}

#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.names[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.names count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%tu Interests", [self.names count]];
}

@end
