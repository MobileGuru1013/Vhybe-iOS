//
//  WLINewPostViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import <AdobeCreativeSDKFoundation/AdobeCreativeSDKFoundation.h>
//#import <AviarySDK/AviarySDK.h>

@interface WLINewPostViewController : WLIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AFPhotoEditorControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPost;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostImage;
@property (strong, nonatomic) IBOutlet UITextView *textViewPost;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PostText;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PostImage;

- (IBAction)buttonPostImageTouchUpInside:(id)sender;
- (IBAction)buttonSendTouchUpInside:(id)sender;

@end
