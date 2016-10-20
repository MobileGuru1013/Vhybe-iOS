//
//  WLIWelcomeViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIWelcomeViewController.h"
#import "UIDevice+Resolutions.h"

@implementation WLIWelcomeViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)loadView {
    
    [super loadView];
    if ([UIDevice currentDevice].resolution == UIDeviceResolution_iPhoneRetina35 || [UIDevice currentDevice].resolution == UIDeviceResolution_iPhoneStandard) {
        self.imageViewLogo.frame = CGRectMake(self.imageViewLogo.frame.origin.x, 126.0f, self.imageViewLogo.frame.size.width, self.imageViewLogo.frame.size.height);
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods

- (IBAction)buttonLoginTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showLogin)]) {
        [self.delegate showLogin];
    }
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showRegister)]) {
        [self.delegate showRegister];
    }
}

@end
