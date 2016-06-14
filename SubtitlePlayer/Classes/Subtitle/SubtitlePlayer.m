
#import "SubtitlePlayer.h"
#import "Subtitle.h"

#import <QuartzCore/QuartzCore.h>

NSString *const SubtitlePlayerPreparationNotificaition	= @"SubtitlePlayerPreparationNotificaition";
NSString *const SubtitlePlayerErrorNotification			= @"SubtitlePlayerErrorNotification";

@interface SubtitlePlayer ()

@property (nonatomic, strong) Subtitle *subtitle;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) CMTime current;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) CMTime saved;

@property (nonatomic, assign) float rate;
@property (nonatomic, strong) CADisplayLink *looper;

@property (nonatomic, assign) CMTime interval;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) PeriodicBlock block;
@property (nonatomic, assign) CMTime standard;

@end

@implementation SubtitlePlayer

- (instancetype)init {
	self = [super init];
	if (self) {
        self.rate = 0.0f;
        self.saved = kCMTimeZero;
        self.standard = kCMTimeZero;
	}
	return self;
}

- (void)dealloc {
}

- (uint64_t)duratonMs {
    NSArray *allKeys = self.subtitle.titles.allKeys;
    NSArray *sorted = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *last = sorted.lastObject;
    
    //NSNumber *first = sorted.firstObject;
    //uint64_t durationMs = 0ll;
    //durationMs = last.unsignedLongLongValue - first.unsignedLongLongValue;
    //durationMs += the duration of last object
    // return durationMs
    
    return last.unsignedLongLongValue;
}

- (void)prepare:(NSData *)data mimetype:(NSString *)mimetype {
	self.subtitle = [Subtitle create:mimetype];
	if (self.subtitle) {
		[self.subtitle parse:data];
        self.duration = CMTimeMake([self duratonMs], 1000);
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:SubtitlePlayerPreparationNotificaition object:self userInfo:nil];
		});
	} else {
		NSLog(@"unknow type");
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:SubtitlePlayerErrorNotification object:self userInfo:nil];
		});
	}
}

- (void)createLooper {
	if (self.looper == nil) {
    	self.looper = [CADisplayLink displayLinkWithTarget:self
    	                                          selector:@selector(updatePosition:)];
    	[self.looper addToRunLoop:[NSRunLoop currentRunLoop]
     	                  forMode:NSDefaultRunLoopMode];
    	self.looper.paused = YES;
	}
}

- (void)deleteLooper {
	if (self.looper != nil) {
    	[self.looper removeFromRunLoop:[NSRunLoop currentRunLoop]
    	                       forMode:NSDefaultRunLoopMode];
    	self.looper = nil;
	}
}

- (void)play{
	[self createLooper];
    self.looper.paused = NO;
    self.rate = 1.0f;
    self.date = [NSDate date];
}

- (void)pause{
	self.looper.paused = YES;
	[self deleteLooper];
    self.rate = 0.0f;
    self.saved = self.current;
}

- (void)updatePosition:(CADisplayLink *)sender {
    NSTimeInterval elapsed = 0 - [self.date timeIntervalSinceNow];
    // MARK: 100 ms
    CMTime time = CMTimeMake(elapsed*10, 10);
    self.current = CMTimeAdd(time, self.saved);

    if (CMTimeCompare(self.standard, self.current) < 0) {
        dispatch_async(self.queue, ^(void) {
            self.standard = CMTimeAdd(self.standard, self.interval);
            if (self.block != nil)
                self.block(self.standard);
        });
    }

    Title *title = [self.subtitle getTitle:[NSNumber numberWithUnsignedLongLong:(CMTimeGetSeconds(self.current) * 1000)]];
    if (title) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.titleLabel.text = [title.texts componentsJoinedByString:@"\n"];
        });
    }
}

- (CMTime)currentTime{
    return CMTimeMake(0, 0);
}

- (void)seekToTime:(CMTime)time{
}

- (void)addPeriodicTimeObserveForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block {
    self.interval = interval;
    self.queue = queue;
    self.block = (PeriodicBlock)block;
}

- (void)setQueue:(dispatch_queue_t)queue {
    if (queue == NULL || queue == nil)
        _queue = dispatch_queue_create("com.inisoft.subtitleplayer.periodic", NULL);
    else
        _queue = queue;
}

- (NSArray *)generateWebVTT {
    return [self.subtitle generateWebVTT:60000ll];
}

@end

