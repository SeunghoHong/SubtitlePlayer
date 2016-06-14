
#import "Webvtt.h"

static NSString* const startTag = @"WEBVTT";
static NSString* const timestampTag = @"X-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000";
static NSString* const emptyTag = @"";
static NSString* const emptyTitle = @"";

NSString* const empty = @"Off";
NSString* const emptySrt = @"WEBVTT\nX-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000\n";

@implementation Webvtt

+ (BOOL)sniff:(NSString *)mimetype {
    NSArray *mimetypes = @[@"text/vtt"];
    for (NSString *type in mimetypes) {
        if ([type.lowercaseString isEqualToString:mimetype.lowercaseString])
            return YES;
    }
    return NO;
}

// TODO: move NSString category
+ (NSString*)clockTime:(uint64_t)time {
    
    // 00:00:00.000
    uint64_t h = time / (60 * 60 * 1000);
    time -= h * (60 * 60 * 1000);
    uint64_t m = time / (60 * 1000);
    time -= m * (60 * 1000);
    uint64_t s = time / 1000;
    time -= s * (1000);
    uint64_t ms = time;
    
    return [NSString stringWithFormat:@"%02llu:%02llu:%02llu.%03llu", h, m, s, ms];
}

+ (NSString *)genetateWebVTT:(NSArray *)titles {
    NSMutableArray* array = [NSMutableArray array];
    [array addObject:startTag];
    [array addObject:timestampTag];
    [array addObject:emptyTag];

    for (Title *title in titles) {
        [array addObject:[NSString stringWithFormat:@"%@ --> %@", [Webvtt clockTime:title.startMs], [Webvtt clockTime:title.endMs]]];
        for (NSString *text in title.texts) {
            [array addObject:text];
        }
        [array addObject:emptyTag];
    }
    [array addObject:emptyTag];
    return [array componentsJoinedByString:@"\n"];
}

@end
