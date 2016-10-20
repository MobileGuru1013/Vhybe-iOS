//
//  WLINewPostViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLINewPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+FontAwesome.h"

@implementation WLINewPostViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"New post";
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
        //[AFPhotoEditorController setAPIKey:kAviaryKey secret:kAviarySecret];
        //[[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:@"c7834edb43a04d5291cd91a35528eac9" withClientSecret:@"920308d7-bab6-47d2-a681-e86e1d3ea6da" enableSignUp:NO];
        [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:@"c7834edb43a04d5291cd91a35528eac9" withClientSecret:@"920308d7-bab6-47d2-a681-e86e1d3ea6da"];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.imageViewPost.layer.cornerRadius = 3.0f;
    self.imageViewPost.layer.masksToBounds = YES;
    self.textViewPost.layer.cornerRadius = 3.0f;
    
    [self.textViewPost becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.lbl_PostText.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_PostText.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil"];
    self.lbl_PostText.textColor = [UIColor whiteColor];
    self.lbl_PostText.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.lbl_PostText.layer.cornerRadius= 5;
    self.lbl_PostText.layer.masksToBounds=YES;
    self.textViewPost.layer.masksToBounds=YES;
    self.textViewPost.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.textViewPost.layer.borderWidth= 1.0f;
    self.textViewPost.layer.cornerRadius= 5;
    
    self.lbl_PostImage.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_PostImage.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-picture-o"];
    self.lbl_PostImage.textColor = [UIColor whiteColor];
    self.lbl_PostImage.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.lbl_PostImage.layer.cornerRadius= 5;
    self.lbl_PostImage.layer.masksToBounds=YES;
    self.buttonPostImage.layer.masksToBounds=YES;
    self.buttonPostImage.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.buttonPostImage.layer.borderWidth= 1.0f;
    self.buttonPostImage.layer.cornerRadius= 5;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Buttons methods

- (IBAction)buttonPostImageTouchUpInside:(id)sender {
    
    if ([self.textViewPost isFirstResponder]) {
        [self.textViewPost resignFirstResponder];
    }
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (IBAction)buttonSendTouchUpInside:(id)sender {
    
    if (!self.textViewPost.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } /*else if (!self.imageViewPost.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }*/ else {
        [hud show:YES];
        if ([self.textViewPost isFirstResponder]) {
            [self.textViewPost resignFirstResponder];
        }
        [sharedConnect sendPostWithTitle:self.textViewPost.text postKeywords:nil postImage:self.imageViewPost.image onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
            [hud hide:YES];
            self.imageViewPost.image = nil;
            self.textViewPost.text = @"";
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}


#pragma mark - UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    AFPhotoEditorController *photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
    photoEditorController.delegate = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:photoEditorController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.textViewPost isFirstResponder]) {
            [self.textViewPost becomeFirstResponder];
        }
    }];
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}


#pragma - AFPhotoEditorController methods

- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    
    self.imageViewPost.image = image;
    [self.buttonPostImage setTitle:@"" forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.textViewPost isFirstResponder]) {
            [self.textViewPost becomeFirstResponder];
        }
    }];
}

- (void) photoEditorCanceled:(AFPhotoEditorController *)editor {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
