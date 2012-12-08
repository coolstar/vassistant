/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/
#import <UIKit/UIKit.h>
//#import <SpringBoard/SBShowcaseViewController.h>
#import "VAssistantViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
@interface UIPopoverController()
	-(id)popoverView;
@end
#endif

@interface SBAwayController
-(BOOL)isLocked;
@end

@interface VAssistantController : SBShowcaseViewController
@end

%hook SBAwayController

- (void)handleMenuButtonTap {
	%orig;
	if (![self isLocked]){
		return;
	}

	SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
	if ([[uicontroller showcaseController] showcase] != nil){
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		[uicontroller _dismissShowcase:0.25 unhost:TRUE];
	}
}

%end

@interface SpringBoard : NSObject
-(void)_activateVAssistant;
@end

static UIWindow *VAssistantWindow;

%hook SpringBoard

%new;
-(void)_activateVAssistant {
	if ([self respondsToSelector:@selector(clearMenuButtonTimer)]) {
			[self performSelector:@selector(clearMenuButtonTimer)];
	}
	SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
	if (![uicontroller isSwitcherShowing]){
		[uicontroller dismissSwitcherAnimated:NO];
	}
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
	if ([[UIDevice currentDevice] userInterfaceIdiom] == 
UIUserInterfaceIdiomPad){
		VAssistantViewController *vc = [[VAssistantViewController alloc] init];
		UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:vc];
		pc.popoverContentSize = CGSizeMake(320,140);
		//pc.popoverBackgroundViewClass = [VAssistantPopoverBG class];

		//UIView *rootView = [uicontroller window];
		//NSLog(@"%@",rootView);
		
		VAssistantWindow = [[UIWindow alloc] initWithFrame:[[uicontroller window] frame]];
		[VAssistantWindow setWindowLevel:9999.0f];
		[VAssistantWindow setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:(2.0f / 255.0f)]];
		[VAssistantWindow makeKeyAndVisible];

		[pc setDelegate:self];
		[pc presentPopoverFromRect:CGRectMake(384,1024,0,0) inView:VAssistantWindow permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		UIView *view = vc.view;
		CGRect frame = view.frame;
		frame.origin.y = -(480-140);
		view.frame = frame;
		vc.parent = pc;
		[[[pc popoverView] layer] setZPosition:999999];
	} else {
#endif
		if ([[uicontroller showcaseController] showcase] == nil){
		SBUIController *vassistantController = [[objc_getClass("VAssistantController") alloc] init];
			[uicontroller _revealShowcase:vassistantController duration:0.25 from:[uicontroller _showcaseContextForOffset:0.0] to:[uicontroller _showcaseContextForOffset:140.0]];
		}
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
	}
#endif
}

%new
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[popoverController release];
	[VAssistantWindow resignKeyWindow];
	[VAssistantWindow setHidden:YES];
	[VAssistantWindow release];
}

-(void)menuButtonWasHeld {
	[self _activateVAssistant];
}

-(void)_menuButtonWasHeld {
	[self _activateVAssistant];
}

%end

%hook UIStatusBar
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[(SpringBoard *)[UIApplication sharedApplication] _activateVAssistant];
	%orig;
}
%end
