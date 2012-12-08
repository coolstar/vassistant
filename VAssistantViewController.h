#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CPDistributedMessagingCenter.h"

@interface SBShowcaseController : NSObject
	-(id)showcase;
@end
    
@interface SBShowcaseViewController : SBShowcaseController
@end

static CPDistributedMessagingCenter *VAserver;

@interface SBUIController {
	SBShowcaseController *showcaseController;
}

-(id)_showcaseContextForOffset:(float)offset;
-(BOOL)_revealShowcase:(id)showcase duration:(double)duration from:(id)from to:(id)to;
-(void)_dismissShowcase:(double)arg1 unhost:(BOOL)arg2;
-(void)dismissSwitcherAnimated:(BOOL)arg1;
+(id)sharedInstance;
-(BOOL)isSwitcherShowing;
-(id)window;
-(SBShowcaseController *)showcaseController;
-(void)_adjustViewHierarchyForShowcase:(id)showcase withContext:(id)context;

@property (nonatomic,retain) SBShowcaseController *showcaseController;

@end

@class UIStatusBar,UIPopoverController;
@interface VAssistantViewController : UIViewController <AVAudioSessionDelegate,UITableViewDelegate,UITableViewDataSource> {
    UIButton *mic;
    UIImageView *progressspinner,*volumemeter;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    BOOL recording, resized;
    NSTimer *audiomon;
    NSMutableArray *queries;
    UITableView *tableview;
    UIStatusBar *statusbar;
    UIPopoverController *parent;
}

-(void)drawBG;
-(void)drawmicbtn;
-(void)initAudio;
-(void)initTable;
-(void)initServer;
- (void)playiPod:(NSString *)search prop:(NSString *)prop;
- (void)pushCellFromVA:(NSString *)text;
- (void)pushCellFromVA:(NSString *)text voicemsg:(NSString *)voice;
@property (nonatomic, retain) UIPopoverController *parent;

@end
