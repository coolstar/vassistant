#import <UIKit/UIKit.h>
#import "VAssistantViewController.h"

static VAssistantViewController *VAssistantvc;
@interface VAssistantController : SBShowcaseViewController {
		}
@end

%subclass VAssistantController : SBShowcaseViewController

- (id)view {
	UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	VAssistantViewController *vc = [[VAssistantViewController alloc] init];
	VAssistantvc = vc;
	UIView *subview = vc.view;
	CGRect screenframe = [[UIScreen mainScreen] bounds];
	CGRect viewframe = subview.frame;
	viewframe.origin.x = (screenframe.size.width/2)-(viewframe.size.width/2);
	viewframe.origin.y = (screenframe.size.height-viewframe.size.height);
	subview.frame = viewframe;
	[view addSubview:subview];
	[view autorelease];
	return view;
}

-(void)viewDidDisappear {
	VAssistantViewController *vc = VAssistantvc;
	[vc release];
	[self release];
}

%end
