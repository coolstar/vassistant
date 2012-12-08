#include "VAssistantPopoverBG.h"

@implementation VAssistantPopoverBG

@synthesize arrowOffset, arrowDirection;

-(id)init {
    self = [super init];
    if (self){
        [self tint];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        [self tint];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self tint];
    }
    return self;
}

-(UIPopoverArrowDirection)arrowDirection {
    return UIPopoverArrowDirectionAny;
}

-(CGFloat)arrowOffset {
    return 0;
}

+(CGFloat)arrowBase {
    return 40;
}

+(CGFloat)arrowHeight {
    return 20;
}

+(UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(10,10,10,10);
}

-(void)tint {
    [self setBackgroundColor:[UIColor blackColor]];
}

@end