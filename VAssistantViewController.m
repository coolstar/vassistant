#import "VAssistantViewController.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f

@interface AssistantCells : UITableViewCell {
}

@end

@implementation AssistantCells

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x += 20;
    textLabelFrame.size.width -= 25;
    self.textLabel.frame = textLabelFrame;
}

@end


@interface SpeechCells : UITableViewCell {
}

@end

@implementation SpeechCells

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width -= 20;
    self.textLabel.frame = textLabelFrame;
}

@end


@interface UIStatusBar : UIView 

    -(void)setShowsOnlyTime:(BOOL)arg1;
    -(void)requestStyle:(UIStatusBarStyle)style;
    
@end

@implementation VAssistantViewController
@synthesize parent;

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    resized = false;
    [self drawBG];
    [self drawmicbtn];
    [self initAudio];
    [self initTable];
#if TARGET_IPHONE_SIMULATOR
    [self performSelector:@selector(simulateQuery:) withObject:@"Test Query" afterDelay:0.5];
#else
        [self initServer];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/va.txt"]){
        NSString *q = [NSString stringWithContentsOfFile:@"/User/va.txt" encoding:NSUTF8StringEncoding error:nil];
        [self performSelector:@selector(simulateQuery:) withObject:q afterDelay:0.5];
    }
#endif
}

-(void)simulateQuery:(NSString *)q {
	[self performSelector:@selector(pushCellFromUser:) withObject:q];
#if TARGET_IPHONE_SIMULATOR
    [self performSelector:@selector(pushCellFromVA:) withObject:@"Test Response"];
    [self pushSnippet:nil snippet:[NSDictionary dictionaryWithObjectsAndKeys:@"CSWeatherView",@"class",nil]];
#else
	[[CPDistributedMessagingCenter centerNamed:@"org.coolstar.vassistantserver"] sendMessageName:@"parseQuery" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:q,@"query",nil]];
#endif
}

-(void)drawBG {
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.view.frame];
    //[bg setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/bg.png"]];
    [bg setImage:[UIImage imageNamed:@"BulletinListLinen"]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        [bg setAlpha:0.65];
        [bg setContentMode:UIViewContentModeCenter];
    } else {
#endif
        [bg setAlpha:0.75];
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
    }
#endif
    [self.view addSubview:bg];
    [bg release];
    
    statusbar = [[objc_getClass("UIStatusBar") alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,20)];
    [statusbar requestStyle:UIStatusBarStyleBlackTranslucent];
    [statusbar setShowsOnlyTime:NO];
    [self.view addSubview:statusbar];
    [statusbar setNeedsDisplay];
    [statusbar autorelease];
    
}

-(void)drawmicbtn {
    mic = [[UIButton alloc] initWithFrame:CGRectMake(160-32,480-84,64,64)];
    [mic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/mic.png"] forState:UIControlStateNormal];
    [mic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/mic-on.png"] forState:UIControlStateHighlighted];
    [mic setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/buttonbg.png"] forState:UIControlStateNormal];
    [mic setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/buttonbg-on.png"] forState:UIControlStateHighlighted];
    [mic addTarget:self action:@selector(micPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mic];
    
    progressspinner = [[UIImageView alloc] initWithFrame:mic.frame];
    [progressspinner setAnimationImages:
	    [NSArray arrayWithObjects:
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/1.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/2.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/3.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/4.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/5.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/6.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/7.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/8.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/9.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/10.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/11.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/12.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/13.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/14.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/15.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/16.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/17.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/18.png"],
	     [UIImage imageWithContentsOfFile:@"/Library/VAssistant/loading/19.png"], nil]];
    progressspinner.animationDuration = 60*19/1000;
    [progressspinner setHidden:YES];
    [self.view addSubview:progressspinner];
}

-(void)initAudio {
    AVAudioSession *audiosession = [AVAudioSession sharedInstance];
    [audiosession setDelegate:self];
    [audiosession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audiosession setActive:YES error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:6];
    [recordSettings setObject:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/org.coolstar.vassistant.query.wav"]] settings:recordSettings error:nil];
    [recordSettings release];
    recording = NO;
    
    volumemeter = [[UIImageView alloc] initWithFrame:mic.frame];
    [volumemeter setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/indicator.png"]];
    volumemeter.layer.zPosition = progressspinner.layer.zPosition;
    volumemeter.contentMode = UIViewContentModeBottom;
    [volumemeter setHidden:YES];
    volumemeter.clipsToBounds = YES;
    [self.view addSubview:volumemeter];
    
    player = nil;
    
}

-(void)initServer {
    if (VAserver){
	[VAserver unregisterForMessageName:@"DisplayMSG"];
	[VAserver unregisterForMessageName:@"completeQuery"];
	[VAserver unregisterForMessageName:@"PerformAction"];
	[VAserver unregisterForMessageName:@"DisplaySnippet"];
	[VAserver registerForMessageName:@"DisplayMSG" target:self selector:@selector(pushCellFromVA:withObject:)];
	[VAserver registerForMessageName:@"completeQuery" target:self selector:@selector(completeQuery:)];
	[VAserver registerForMessageName:@"PerformAction" target:self selector:@selector(performaction:action:)];
	[VAserver registerForMessageName:@"DisplaySnippet" target:self selector:@selector(pushSnippet:snippet:)];
	return;
    }
    VAserver = [[CPDistributedMessagingCenter centerNamed:@"org.coolstar.vassistantclient"] retain];
    [VAserver runServerOnCurrentThread];
    [VAserver registerForMessageName:@"DisplayMSG" target:self selector:@selector(pushCellFromVA:withObject:)];
    [VAserver registerForMessageName:@"completeQuery" target:self selector:@selector(completeQuery:)];
    [VAserver registerForMessageName:@"PerformAction" target:self selector:@selector(performaction:action:)];
    [VAserver registerForMessageName:@"DisplaySnippet" target:self selector:@selector(pushSnippet:snippet:)];
}

-(void)performaction:(NSString *)sig action:(NSDictionary *)action {
    NSString *actionname = [action objectForKey:@"action"];
    NSString *args = [action objectForKey:@"args"];
    if ([actionname isEqualToString:@"iPod-Pause"]){
	[[MPMusicPlayerController iPodMusicPlayer] pause];
    } else if ([actionname isEqualToString:@"iPod-Play-Name"]){
	[self playiPod:args prop:MPMediaItemPropertyTitle];
    } else if ([actionname isEqualToString:@"iPod-Play-Artist"]){
	[self playiPod:args prop:MPMediaItemPropertyArtist];
    } else if ([actionname isEqualToString:@"iPod-Play-Album"]){
	[self playiPod:args prop:MPMediaItemPropertyAlbumTitle];
    }
}

- (void)playiPod:(NSString *)search prop:(NSString *)prop {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
	MPMediaPropertyPredicate *filterpred = [MPMediaPropertyPredicate predicateWithValue:search
									    forProperty:prop
									 comparisonType:MPMediaPredicateComparisonContains];
	[query addFilterPredicate:filterpred];
    NSArray *songs = [query items];
    if ([songs count] < 1) {
	if (prop == MPMediaItemPropertyAlbumTitle){
	    [self pushCellFromVA:[@"Sorry, I didn't find an album in your library called " stringByAppendingString:search]];
	} else if (prop == MPMediaItemPropertyTitle){
	    [self pushCellFromVA:[@"Sorry, I didn't find a song in your library called " stringByAppendingString:search]];
	} else if (prop == MPMediaItemPropertyArtist){
	    [self pushCellFromVA:[@"Sorry, I didn't find an artist in your library called " stringByAppendingString:search]];
	}
    } else {
	MPMusicPlayerController *iPod = [MPMusicPlayerController iPodMusicPlayer];
	if (prop == MPMediaItemPropertyTitle){
	    MPMediaItem *song = [songs objectAtIndex:0];
	    [iPod setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:song]]];
	} else {
	    [iPod setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:songs]];
	}
	[iPod play];
    }
}

- (void)initTable {
	queries = [[NSMutableArray alloc] init];
    
	tableview = [[UITableView alloc] initWithFrame:CGRectMake(10,30,300,356)];
	tableview.delegate = self;
	tableview.dataSource = self;
    tableview.allowsSelection = NO;
	[tableview reloadData];
	[tableview setBackgroundColor:[UIColor clearColor]];
	[tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.view addSubview:tableview];
    statusbar.layer.zPosition = tableview.layer.zPosition+1;
}

- (void)micPressed:(id)sender {
    
    if (player != nil){
	[player release];
	player = nil;
    }
    
	if (recording == NO){
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/VAssistant/begin.wav"] error:nil];
	} else {
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/VAssistant/complete.wav"] error:nil];
	}
	[player play];
	[self performSelector:@selector(toggleListen:) withObject:sender afterDelay:1];
}

- (void)toggleListen:(id)sender {
	if (recording == YES){
		recording = NO;
		[recorder stop];
		recorder.meteringEnabled = NO;
		[volumemeter setHidden:YES];
		[audiomon invalidate];
		audiomon = nil;
		[mic setEnabled:NO];
		[progressspinner startAnimating];
		[progressspinner setHidden:NO];
		[self performSelectorInBackground:@selector(processSpeech:) withObject:nil];
	} else {
		if ([recorder prepareToRecord] == YES){
			recorder.meteringEnabled = YES;
			recording = YES;
			[volumemeter setHidden:NO];
			[recorder record];
			audiomon = [NSTimer scheduledTimerWithTimeInterval:0.03
														target:self
						      selector:@selector(audioCallback:)
						      userInfo:nil
						       repeats:YES];
		} else {
			recording = NO;
		}
	}
}

-(void)processSpeech:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    system("flac --sample-rate=16000 /var/mobile/Library/org.coolstar.vassistant.query.wav");
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/org.coolstar.vassistant.query.flac"]];
    
    NSData *flacFile = [NSData dataWithContentsOfURL:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com/speech-api/v1/recognize?lang=en"]];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"Content-Type" forHTTPHeaderField:@"audio/x-flac; rate=16000"];
    [request addValue:@"audio/x-flac; rate=16000" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:flacFile];
    [request setValue:[NSString stringWithFormat:@"%d",[flacFile length]] forHTTPHeaderField:@"Content-length"];
    NSHTTPURLResponse *urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    NSString *rawgspeech = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/org.coolstar.vassistant.query.wav"] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/org.coolstar.vassistant.query.flac"] error:nil];
    
    if ([rawgspeech isEqualToString:@""]){
		[self performSelectorOnMainThread:@selector(pushCellFromVA:) withObject:@"Sorry, I didn't understand what you said." waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(completeQuery:) withObject:nil waitUntilDone:NO];
	} else {
		NSRange range = [rawgspeech rangeOfString:@"{\"utterance\":\""];
		if (range.location != NSNotFound){
			NSString *gspeechhalf = [rawgspeech substringFromIndex:range.location+14];
			NSRange range2 = [gspeechhalf rangeOfString:@"\",\"confidence"];
			NSString *gspeech = [gspeechhalf substringToIndex:range2.location];
			NSLog(@"%@",gspeech);
			[self performSelectorOnMainThread:@selector(pushCellFromUser:) withObject:gspeech waitUntilDone:NO];
			[[CPDistributedMessagingCenter centerNamed:@"org.coolstar.vassistantserver"] sendMessageName:@"parseQuery" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:gspeech,@"query",nil]];
			[gspeechhalf retain];
			[gspeechhalf release];
		} else {
			[self performSelectorOnMainThread:@selector(pushCellFromVA:) withObject:@"There's something wrong, and I can't take your requests right now. Please try again in a little while." waitUntilDone:NO];
			[self performSelectorOnMainThread:@selector(completeQuery:) withObject:nil waitUntilDone:NO];
		}
	}
    
    [rawgspeech release];
    [request release];
    [pool drain];
}

-(void)pushCellFromVA:(NSString *)msg withObject:(NSDictionary *)obj {
    if ([obj objectForKey:@"speech"] == nil){
	[self performSelector:@selector(pushCellFromVA:) withObject:[obj objectForKey:@"text"]];
	return;
    }
    [self pushCellFromVA:[obj objectForKey:@"text"] voicemsg:[obj objectForKey:@"speech"]];
}

- (void)pushCellFromVA:(NSString *)text {
    [self pushCellFromVA:text voicemsg:text];
}

- (void)pushCellFromVA:(NSString *)text voicemsg:(NSString *)voice {
    if (!resized){
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		[UIView beginAnimations:@"resize" context:nil];
		[UIView setAnimationDuration:0.25];
		parent.popoverContentSize = CGSizeMake(320,460);
		CGRect frame = self.view.frame;
		frame.origin.y = -20;
		self.view.frame = frame;
		[UIView commitAnimations];
	} else {
#endif
		SBUIController *uicontroller = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
		[UIView beginAnimations:nil context:nil];
	    [UIView setAnimationDuration:0.25];
		[uicontroller _adjustViewHierarchyForShowcase:[uicontroller showcaseController] withContext:[uicontroller _showcaseContextForOffset:480.0]];
	    [UIView commitAnimations];
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
	}
#endif
	resized = YES;
    }
	[queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:text,@"msg",@"VA",@"source",@"assistant",@"type",nil]];
    [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
	[tableview reloadData];
}

- (void)pushSnippet:(NSString *)name snippet:(NSDictionary *)viewdesc {
    if ([[viewdesc objectForKey:@"class"] isEqualToString:@"UIWebView"]){
	   UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(0,5,300,200)];
	   [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[viewdesc objectForKey:@"url"]]]];
	   [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"snippet",@"type",wv,@"view",nil]];
	   [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
	   [tableview reloadData];
    } else if ([[viewdesc objectForKey:@"class"] isEqualToString:@"CSImageView"]){
        UIImageView *pc = [[UIImageView alloc] initWithFrame:CGRectMake(0,5,300,200)];
        NSData *data = [viewdesc objectForKey:@"data"];
        UIImage *image = [UIImage imageWithData:data];
        [pc setImage:image];
        pc.layer.cornerRadius = 5;
        pc.layer.masksToBounds = YES;
        
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"snippet",@"type",[pc autorelease],@"view",nil]];
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
        [tableview reloadData];
    } else if ([[viewdesc objectForKey:@"class"] isEqualToString:@"CSDictionaryView"]){
        UIView *dc = [[UIView alloc] initWithFrame:CGRectMake(0,5,300,200)];
        
        UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,300,43)];
        [navbar setTintColor:[UIColor orangeColor]];
        
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Dictionary (Wordnik)"];
        [navbar pushNavigationItem:[item autorelease] animated:NO];
        
        [dc addSubview:[navbar autorelease]];
        
        UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0,43,300,200-43)];
        [tv setText:[viewdesc objectForKey:@"text"]];
        [tv setFont:[UIFont systemFontOfSize:16]];
        tv.editable = NO;
        [dc addSubview:[tv autorelease]];
        dc.layer.cornerRadius = 5;
        dc.layer.masksToBounds = YES;
        
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"snippet",@"type",[dc autorelease],@"view",nil]];
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
        [tableview reloadData];
    } else if ([[viewdesc objectForKey:@"class"] isEqualToString:@"CSThesaurusView"]){
        UIView *dc = [[UIView alloc] initWithFrame:CGRectMake(0,5,300,200)];
        
        UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,300,43)];
        [navbar setTintColor:[UIColor orangeColor]];
        
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Thesaurus (Wordnik)"];
        [navbar pushNavigationItem:[item autorelease] animated:NO];
        
        [dc addSubview:[navbar autorelease]];
        
        UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0,43,300,200-43)];
        [tv setText:[viewdesc objectForKey:@"text"]];
        [tv setFont:[UIFont systemFontOfSize:16]];
        tv.editable = NO;
        [dc addSubview:[tv autorelease]];
        dc.layer.cornerRadius = 5;
        dc.layer.masksToBounds = YES;
        
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"snippet",@"type",[dc autorelease],@"view",nil]];
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
        [tableview reloadData];
    } else if ([[viewdesc objectForKey:@"class"] isEqualToString:@"CSWeatherView"]){
        NSDictionary *data = [viewdesc objectForKey:@"data"];
        
        NSDate *dated = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
        NSDateComponents *components = [calendar components:units fromDate:dated];
        NSInteger year = [components year];
        NSInteger day = [components day];
        
        NSDateFormatter *calMonth = [[[NSDateFormatter alloc] init] autorelease];
        [calMonth setDateFormat:@"MMM."];
        
        NSString *currentDate = [NSString stringWithFormat:@"%@ %i, %i", [calMonth stringFromDate:dated], day, year];
        
        
        UIView *wc = [[UIView alloc] initWithFrame:CGRectMake(0,5,300,140)];
        
        UIImageView *wpic = [[UIImageView alloc] initWithFrame:CGRectMake(0,10,128,128)];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(134,12,172,21)];
        date.textAlignment = UITextAlignmentCenter;
        date.font = [UIFont boldSystemFontOfSize:17.0];
        [date setTextColor:[UIColor whiteColor]];
        [date setBackgroundColor:[UIColor clearColor]];
        [date setText:currentDate];
        [wc addSubview:[date autorelease]];
        
        
        UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(133,46,174,45)];
        temp.textAlignment = UITextAlignmentCenter;
        temp.font = [UIFont boldSystemFontOfSize:53.0];
        [temp setTextColor:[UIColor whiteColor]];
        [temp setBackgroundColor:[UIColor clearColor]];
        [temp setText:[data objectForKey:@"temp"]];
        [wc addSubview:[temp autorelease]];
        
        UILabel *city = [[UILabel alloc] initWithFrame:CGRectMake(142,94,156,21)];
        city.textAlignment = UITextAlignmentCenter;
        city.font = [UIFont boldSystemFontOfSize:17.0];
        [city setTextColor:[UIColor whiteColor]];
        [city setBackgroundColor:[UIColor clearColor]];
        [city setText:[data objectForKey:@"city"]];
        [wc addSubview:[city autorelease]];
        
        /*NSDictionary *dic = [viewdesc objectForKey:@"weatherdic"];
        int cond = [[[[dic objectForKey:@"items"] objectAtIndex:0] objectForKey:@"condition"] intValue];*/
        int cond = [[data objectForKey:@"condition"] intValue];
        switch (cond) {
            case 0: {
                    CAGradientLayer *gradlayer = [CAGradientLayer layer];
                    gradlayer.frame = wc.bounds;
                    gradlayer.colors=[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:((float)179.0/(float)255.0) blue:1 alpha:1] CGColor],(id)[[UIColor colorWithRed:0 green:((float)123.0/(float)255.0) blue:1 alpha:1] CGColor], nil];
                    gradlayer.locations=[NSArray arrayWithObjects:(id)[NSNumber numberWithInt:0],(id)[NSNumber numberWithInt:1],nil];
                    gradlayer.zPosition = -1;
                    [wc.layer addSublayer:gradlayer];
                
                    //[wc setBackgroundColor:[UIColor colorWithRed:0 green:(128.0/255.0) blue:1 alpha:1]];
                    [wpic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/Weather/Sunny.png"]];
                    break;
                }
            case 1: {
                CAGradientLayer *gradlayer = [CAGradientLayer layer];
                gradlayer.frame = wc.bounds;
                gradlayer.colors=[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:((float)179.0/(float)255.0) blue:1 alpha:1] CGColor],(id)[[UIColor colorWithRed:0 green:((float)123.0/(float)255.0) blue:1 alpha:1] CGColor], nil];
                gradlayer.locations=[NSArray arrayWithObjects:(id)[NSNumber numberWithInt:0],(id)[NSNumber numberWithInt:1],nil];
                gradlayer.zPosition = -1;
                [wc.layer addSublayer:gradlayer];
                
                //[wc setBackgroundColor:[UIColor colorWithRed:0 green:(128.0/255.0) blue:1 alpha:1]];
                [wpic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/Weather/Fair.png"]];
                break;
            }
            case 2: {
                CAGradientLayer *gradlayer = [CAGradientLayer layer];
                gradlayer.frame = wc.bounds;
                gradlayer.colors= [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor],(id)[[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] CGColor], nil];
                gradlayer.locations=[NSArray arrayWithObjects:(id)[NSNumber numberWithInt:0],(id)[NSNumber numberWithInt:1],nil];
                gradlayer.zPosition = -1;
                [wc.layer addSublayer:gradlayer];
                
                //[wc setBackgroundColor:[UIColor colorWithRed:0 green:(128.0/255.0) blue:1 alpha:1]];
                [wpic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/Weather/Overcast.png"]];
                break;
            }
            case 3: {
                CAGradientLayer *gradlayer = [CAGradientLayer layer];
                gradlayer.frame = wc.bounds;
                gradlayer.colors= [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor],(id)[[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] CGColor], nil];
                gradlayer.locations=[NSArray arrayWithObjects:(id)[NSNumber numberWithInt:0],(id)[NSNumber numberWithInt:1],nil];
                gradlayer.zPosition = -1;
                [wc.layer addSublayer:gradlayer];
                
                //[wc setBackgroundColor:[UIColor colorWithRed:0 green:(128.0/255.0) blue:1 alpha:1]];
                [wpic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/Weather/Precipitation.png"]];
                break;
            }
            case 4: {
                CAGradientLayer *gradlayer = [CAGradientLayer layer];
                gradlayer.frame = wc.bounds;
                gradlayer.colors= [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor],(id)[[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1] CGColor], nil];
                gradlayer.locations=[NSArray arrayWithObjects:(id)[NSNumber numberWithInt:0],(id)[NSNumber numberWithInt:1],nil];
                gradlayer.zPosition = -1;
                [wc.layer addSublayer:gradlayer];
                
                //[wc setBackgroundColor:[UIColor colorWithRed:0 green:(128.0/255.0) blue:1 alpha:1]];
                [wpic setImage:[UIImage imageWithContentsOfFile:@"/Library/VAssistant/Weather/Snow.png"]];
                break;
            }
            default:
                break;
        }
        [wc addSubview:[wpic autorelease]];
        wc.layer.cornerRadius = 5;
        wc.layer.masksToBounds = YES;
        
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"snippet",@"type",[wc autorelease],@"view",nil]];
        [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
        [tableview reloadData];
    } else {
	   return;
    }
    if (!resized){
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
	[UIView beginAnimations:@"resize" context:nil];
		[UIView setAnimationDuration:0.25];
	parent.popoverContentSize = CGSizeMake(320,460);
		CGRect frame = self.view.frame;
		frame.origin.y = -20;
		self.view.frame = frame;
	[UIView commitAnimations];
	} else {
#endif
	    SBUIController *uicontroller = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
	    [UIView beginAnimations:nil context:nil];
	    [UIView setAnimationDuration:0.25];
	    [uicontroller _adjustViewHierarchyForShowcase:[uicontroller showcaseController] withContext:[uicontroller _showcaseContextForOffset:480.0]];
	    [UIView commitAnimations];
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
	}
#endif
    }
}

- (void)pushCellFromUser:(NSString *)text {
    if (!resized){
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            [UIView beginAnimations:@"resize" context:nil];
            [UIView setAnimationDuration:0.25];
            parent.popoverContentSize = CGSizeMake(320,460);
            CGRect frame = self.view.frame;
            frame.origin.y = -20;
            self.view.frame = frame;
            [UIView commitAnimations];
        } else {
#endif
            SBUIController *uicontroller = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.25];
            [uicontroller _adjustViewHierarchyForShowcase:[uicontroller showcaseController] withContext:[uicontroller _showcaseContextForOffset:480.0]];
            [UIView commitAnimations];
#if __IPHONE_OS_VERSION_MAX_ALLOWED != __IPHONE_3_0
        }
#endif
    }
	[queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:text,@"msg",@"usr",@"source",@"speech",@"type",nil]];
    [queries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"space",@"type",nil]];
	[tableview reloadData];
}

- (void)completeQuery:(id)sender {
    [progressspinner stopAnimating];
    [progressspinner setHidden:YES];
    [mic setEnabled:YES];
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	return [queries count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)path {
    
    UITableViewCell *cell = nil;
    static NSString *speechid = @"speechCell";
    static NSString *assistantID = @"assistantCell";
    static NSString *spaceid = @"spaceCell";
    static NSString *snippetid = @"snippetCell";
    NSString *type = [[queries objectAtIndex:[path row]] objectForKey:@"type"];
    if ([type isEqualToString:@"speech"]){
        cell = [tv dequeueReusableCellWithIdentifier:speechid];
        if (cell == nil){
            cell = [[[SpeechCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:speechid] autorelease];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
            [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            UIImageView *speechbg = [[[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/VAssistant/rightbubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11,13,23,30)]] autorelease];
            [speechbg setAlpha:0.75];
            [cell setBackgroundView:speechbg];
            cell.textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            cell.textLabel.shadowOffset = CGSizeMake(2,2);
        }
        cell.textLabel.text = [NSString stringWithFormat:@"\"%@\"",[[queries objectAtIndex:[path row]] objectForKey:@"msg"]];
    
    
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    
        CGSize size = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.textLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    } else if ([type isEqualToString:@"assistant"]){
        cell = [tv dequeueReusableCellWithIdentifier:assistantID];
        if (cell == nil){
            cell = [[[AssistantCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:assistantID] autorelease];
            [cell.textLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
            [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
            [cell.textLabel setNumberOfLines:0];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            cell.textLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            cell.textLabel.shadowOffset = CGSizeMake(2,2);
            
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
            UIImageView *speechbg = [[[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/VAssistant/leftbubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11,30,23,13)]] autorelease];
            [speechbg setAlpha:0.75];
            [cell setBackgroundView:speechbg];
        }
        cell.textLabel.text = [[queries objectAtIndex:[path row]] objectForKey:@"msg"];
        
        
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        
        
        CGSize size = [cell.textLabel.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.textLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    } else if ([type isEqualToString:@"space"]){
	cell = [tv dequeueReusableCellWithIdentifier:spaceid];
	if (cell == nil){
	    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:spaceid] autorelease];
	    [cell.contentView setBackgroundColor:[UIColor clearColor]];
	}
    } else if ([type isEqualToString:@"snippet"]){
	cell = [tv dequeueReusableCellWithIdentifier:snippetid];
	if (cell == nil){
	    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:snippetid] autorelease];
	}
	[cell.contentView addSubview:[[queries objectAtIndex:[path row]] objectForKey:@"view"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)path {
    NSString *type = [[queries objectAtIndex:[path row]] objectForKey:@"type"];
    if ([type isEqualToString:@"assistant"]){
	NSString *text = [[queries objectAtIndex:[path row]] objectForKey:@"msg"];
    
	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = MAX(size.height+10, 44.0f);
	return height + (CELL_CONTENT_MARGIN * 0.75);
    } else if ([type isEqualToString:@"speech"]){
        NSString *text = [[queries objectAtIndex:[path row]] objectForKey:@"msg"];
        
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height+20, 44.0f);
        return height + (CELL_CONTENT_MARGIN * 0.75);
    } else if ([type isEqualToString:@"space"]){
	return 10;
    } else if ([type isEqualToString:@"snippet"]){
	return [[[queries objectAtIndex:[path row]] objectForKey:@"view"] frame].size.height;
    }
    return 0;
}

- (void)audioCallback:(id)sender {
	[recorder updateMeters];
	float audiovol = [recorder averagePowerForChannel:0];
	audiovol = pow(10, (0.05 * audiovol));
    
	CGRect volumemeterframe = volumemeter.frame;
	float height = (audiovol*32)+21;
	float y = mic.frame.origin.y + mic.frame.size.height - height;
    
	volumemeterframe.size.height = height;
	volumemeterframe.origin.y = y;
    
	volumemeter.frame = volumemeterframe;
}

-(void)dealloc {
    
    if (recording == YES){
	recording = NO;
	[recorder stop];
	recorder.meteringEnabled = NO;
	[audiomon invalidate];
	audiomon = nil;
    }
    
    if (player != nil){
	[player release];
	player = nil;
    }
    
    [mic release];
    [progressspinner release];
    [recorder release];
    [volumemeter release];
    
    [tableview release];
    [queries release];
    
    [super dealloc];
}

@end
