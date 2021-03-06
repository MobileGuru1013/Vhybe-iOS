//
//  PLToolbar.h v1.3
//
//  Created by Planet 1107 on 11/4/13.
//

// v 1.3 11/4/13 - Added support for ipad and landscape orientation
// TO DO - Need to track orientation changes and scroll depending on it. Now it works for both orientations if there is no change

#define KEYBOARD_ANIMATION_DURATION 0.4
#define PORTRAIT_KEYBOARD_HEIGHT 216

#import <UIKit/UIKit.h>

@interface PNTToolbar : UIToolbar <UITextFieldDelegate> {
    
    UIBarButtonItem *previousButton;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *doneButton;
}

@property (strong, nonatomic) UIScrollView* mainScrollView;
@property (assign, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (strong, nonatomic) NSArray *textFields;
@property (strong, nonatomic) NSArray* delegates;
@property (assign, nonatomic) BOOL hidePrevNextButtons;

+ (PNTToolbar *)defaultToolbar;

@end
