//
//  WLIActivityIndicator.h
//
//  Copyright 2014 Planet1107.
//

#import <UIKit/UIKit.h>

#define kDefaultSpinDurationTime 0.8f

@interface WLIActivityIndicator : UIView

@property (assign) float spinDurationTime;

- (id)initWithFrame:(CGRect)frame;
- (void)startAnimating;
- (void)stopAnimating;

@end
