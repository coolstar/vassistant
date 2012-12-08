#import <UIKit/UIPopoverBackgroundView.h>

@interface VAssistantPopoverBG : UIPopoverBackgroundView {
    
}

@property (nonatomic, readwrite) CGFloat arrowOffset;
@property (nonatomic, readwrite) UIPopoverArrowDirection arrowDirection;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;

- (void)tint;

@end