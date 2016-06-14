
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

typedef void (^PeriodicBlock)   (CMTime time);

extern NSString *const SubtitlePlayerPreparationNotificaition;
extern NSString *const SubtitlePlayerErrorNotification;

@interface SubtitlePlayer: NSObject

@property (nonatomic, weak) UILabel *titleLabel;

- (void)prepare:(NSData *)data mimetype:(NSString *)mimetype;

@end

@interface SubtitlePlayer (PlaybackControl)

@property (nonatomic, readonly) float rate;

- (void)play;
- (void)pause;

@end

@interface SubtitlePlayer (TimeControl)

@property (nonatomic, readonly) CMTime duration; 

- (CMTime)currentTime;
- (void)seekToTime:(CMTime)time;

@end

@interface SubtitlePlayer (TimeObservation)

- (void)addPeriodicTimeObserveForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;

@end

@interface SubtitlePlayer (Format)

- (NSArray *)generateWebVTT;

@end

