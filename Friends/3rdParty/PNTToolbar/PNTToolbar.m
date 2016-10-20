//
//  PLToolbar.m v1.3
//
//  Created by Planet 1107 on 11/4/13.
//

#import "PNTToolbar.h"

@implementation PNTToolbar

int keyboardHeight() {
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    int keyboardHeight = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        keyboardHeight = 353;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        keyboardHeight = 443;
    } else {
        keyboardHeight = 303;
    }
    return keyboardHeight;
}

+ (PNTToolbar *)defaultToolbar {
    
    PNTToolbar *toolbar = [[PNTToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    toolbar.barStyle = UIBarStyleDefault;
    return toolbar;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        previousButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous",nil) style:UIBarButtonItemStyleBordered target:self
                                                         action:@selector(previousField:)];
        [previousButton setTintColor:[UIColor colorWithRed:255.0f/255.0f green:80.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
        
        nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next",nil)
                                                      style:UIBarButtonItemStyleBordered target:self
                                                     action:@selector(nextField:)];
        [nextButton setTintColor:[UIColor colorWithRed:255.0f/255.0f green:80.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
        
        UIBarButtonItem *spaceBetweenButtons = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                             target:nil action:nil];
        
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
        [doneButton setTintColor:[UIColor colorWithRed:255.0f/255.0f green:80.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
        
        if (self.hidePrevNextButtons) {
            [self setItems:[NSArray arrayWithObjects:spaceBetweenButtons, doneButton, nil]];
        } else {
            [self setItems:[NSArray arrayWithObjects:previousButton, nextButton, spaceBetweenButtons, doneButton, nil] ];
        }
    }
    return self;
}

- (void)resignKeyboard:(id)sender {
    
    [self keyboardWillHide:nil];
    for (UITextField* textField in self.textFields) {
        [textField resignFirstResponder];
    }
    
}

- (void)previousField:(id)sender {
    
    NSUInteger indexOfActiveTextFiled = [self.textFields indexOfObjectPassingTest:^BOOL(UITextField* textField, NSUInteger idx, BOOL* stop) {
        return textField.isFirstResponder;
        
    }];
    if (indexOfActiveTextFiled > 0) {
        [self.textFields[indexOfActiveTextFiled-1] becomeFirstResponder];
    }
    
    
}

- (void)nextField:(id)sender {
    
    NSUInteger indexOfActiveTextFiled = [self.textFields indexOfObjectPassingTest:^BOOL(UITextField* textField, NSUInteger idx, BOOL* stop) {
        return textField.isFirstResponder;
        
    }];
    if (indexOfActiveTextFiled < self.textFields.count-1) {
        [self.textFields[indexOfActiveTextFiled+1] becomeFirstResponder];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGPoint point = CGPointMake(self.mainScrollView.contentOffset.x, 0);
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        self.mainScrollView.contentOffset = point;
    } ];
    
    self.keyboardVisible = NO;
}

#pragma mark - Setter methods

- (void)setTextFields:(NSArray *)textFields {
    
    NSMutableArray* delegates = [NSMutableArray array];
    _textFields = textFields;
    for (UITextField* textField in textFields) {
        if (textField.delegate && textField.delegate != self) {
            [delegates addObject:textField.delegate];
        } else {
            [delegates addObject:[NSNull null]];
        }
        textField.delegate = self;
        textField.inputAccessoryView = self;
    }
    self.delegates = delegates;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIView* viewRoot = [UIApplication sharedApplication].delegate.window;
    CGPoint point = [viewRoot convertPoint:CGPointMake(0, CGRectGetMinY(self.mainScrollView.frame)) fromView:self.mainScrollView.superview];
    int windowHeight = 0;
    if (!CGAffineTransformIsIdentity(viewRoot.transform)) {
        windowHeight = viewRoot.frame.size.width;
    } else {
        windowHeight = viewRoot.frame.size.height;
    }
    CGRect visibleArea = CGRectMake(viewRoot.frame.origin.x, point.y, viewRoot.frame.size.width, windowHeight - keyboardHeight() - point.y);
    CGRect textFieldRect = [viewRoot convertRect:textField.frame fromView:textField.superview];
    int offsetDown = CGRectGetMaxY(textFieldRect) - CGRectGetMaxY(visibleArea);
    int offsetUp = CGRectGetMinY(textFieldRect) - CGRectGetMinY(visibleArea);
    if (offsetDown > 0) {
        [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + offsetDown+10) animated:YES];
    } else if (offsetUp < 0) {
        [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + offsetUp-10) animated:YES];
    }
    
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegates[index] textFieldDidBeginEditing:textField];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegates[index] textField:textField shouldChangeCharactersInRange:range replacementString:string];
    } else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegates[index] textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegates[index] textFieldShouldBeginEditing:textField];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegates[index] textFieldShouldClear:textField];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.delegates[index] textFieldShouldEndEditing:textField];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    int index = [self.textFields indexOfObject:textField];
    if ([self.delegates[index] respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegates[index] textFieldShouldReturn:textField];
    } else {
        return YES;
    }
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    UIView* viewRoot = [UIApplication sharedApplication].delegate.window;
    CGPoint point = [viewRoot convertPoint:CGPointMake(0, CGRectGetMinY(self.mainScrollView.frame)) fromView:self.mainScrollView.superview];
    int windowHeight = 0;
    if (!CGAffineTransformIsIdentity(viewRoot.transform)) {
        windowHeight = viewRoot.frame.size.width;
    } else {
        windowHeight = viewRoot.frame.size.height;
    }
    CGRect visibleArea = CGRectMake(viewRoot.frame.origin.x, point.y, viewRoot.frame.size.width, windowHeight - keyboardHeight() - point.y);
    CGRect textViewRect = [viewRoot convertRect:textView.frame fromView:textView.superview];
    int offsetDown = CGRectGetMaxY(textViewRect) - CGRectGetMaxY(visibleArea);
    int offsetUp = CGRectGetMinY(textViewRect) - CGRectGetMinY(visibleArea);
    if (offsetDown > 0) {
        [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + offsetDown+10) animated:YES];
    } else if (offsetUp < 0) {
        [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, self.mainScrollView.contentOffset.y + offsetUp-10) animated:YES];
    }
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [self.delegates[index] textViewDidBeginEditing:textView];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegates[index] textViewDidChange:textView];
    }
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [self.delegates[index] textViewShouldBeginEditing:textView];
    } else {
        return YES;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [self.delegates[index] textViewShouldEndEditing:textView];
    } else {
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [self.delegates[index] textViewDidEndEditing:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegates[index] textView:textView shouldChangeTextInRange:range replacementText:text];
    } else {
        return YES;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    int index = [self.textFields indexOfObject:textView];
    if ([self.delegates[index] respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.delegates[index] textViewDidChangeSelection:textView];
    }
}

@end