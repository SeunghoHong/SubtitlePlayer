
#import "Subtitle.h"
#import "SubtitleFactory.h"

#import "Webvtt.h"

@interface Subtitle ()

@property (nonatomic, strong) NSArray *times;

@end

@implementation Subtitle

+ (Subtitle *)create:(NSString *)mimetype {
	SubtitleFactory *factory = [[SubtitleFactory alloc] init];
	return [factory createSubtitle:mimetype];
}

+ (BOOL)sniff:(NSString *)mimetype {
    NSLog(@"not implemented");
    return NO;
}

- (void)parse:(NSData *)data {
	NSLog(@"not implemented");
}

- (Title *)getTitle:(NSNumber *)startTime {
    return [self.titles objectForKey:startTime];
}

- (NSArray *)times {
    if (_times == nil) {
        NSArray *allKeys = self.titles.allKeys;
        _times = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    }
    return _times;
}

- (NSArray *)generateWebVTT:(uint64_t)intervalMs {
    NSMutableArray *webvtts = [NSMutableArray array];
    uint64_t standardMs = intervalMs;

    if (intervalMs == 0ll) {
        // make one file
        NSMutableArray *array = [NSMutableArray array];
        for (NSNumber *key in self.times) {
            [array addObject:[self.titles objectForKey:key]];
        }
        [webvtts addObject:[Webvtt genetateWebVTT:array]];
    } else {
        // make webvtt files
        NSMutableArray *array = [NSMutableArray array];
        for (NSNumber *key in self.times) {
            if (standardMs < key.unsignedLongLongValue) {
                [webvtts addObject:[Webvtt genetateWebVTT:array]];
                [array removeAllObjects];
                standardMs += intervalMs;
            }
            [array addObject:[self.titles objectForKey:key]];
        }
    }

    return webvtts;
}

@end

