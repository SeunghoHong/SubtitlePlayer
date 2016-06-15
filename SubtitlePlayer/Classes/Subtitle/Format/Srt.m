
#import "Srt.h"

/*
 1
 00:00:13,800 --> 00:00:16,150
 No, that's not how it is.
 
 2
 00:00:16,150 --> 00:00:17,380
 I didn't mean that.
 */

@interface Srt ()

@property (nonatomic, strong) id startMs;

@end

@implementation Srt

+ (BOOL)sniff:(NSString *)mimetype {
    NSArray *mimetypes = @[@"application/x-subrip"];
    for (NSString *type in mimetypes) {
        if ([type.lowercaseString isEqualToString:mimetype.lowercaseString])
            return YES;
    }
    return NO;
}

// TODO: move NSString category
- (uint64_t)srtTimeToMs:(NSString *)time {
    NSArray *token = [time componentsSeparatedByString:@":"];
    uint64_t h = [[token objectAtIndex:0] longLongValue]*60*60*1000;
    uint64_t m = [[token objectAtIndex:1] longLongValue]*60*1000;
    
    NSArray *seconds = [[token objectAtIndex:2] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",."]];
    uint64_t s = ([[seconds objectAtIndex:0] longLongValue]*1000) + round2([[seconds objectAtIndex:1] longLongValue], -2);

    return h + m + s;
}

- (BOOL)getTimes:(NSString *)string startMs:(uint64_t *)startMs endMs:(uint64_t *)endMs {
    NSString *split = @"-->";
    if ([string rangeOfString:split].location == NSNotFound) {
        return NO;
    }

    NSArray *times = [string componentsSeparatedByString:split];
    if (times.count == 2) {
        *startMs = [self srtTimeToMs:[times objectAtIndex:0]];
        *endMs = [self srtTimeToMs:[times objectAtIndex:1]];
    } else {
        NSLog(@"invalid format");
        return NO;
    }
    return YES;
}

- (void)parse:(NSData *)data {
    self.titles = [NSMutableDictionary dictionary];

    // TODO: bom check
    NSString *subtitle = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (subtitle == nil) {
        NSLog(@"unknown encoding");
        return;
    }

    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"[^0-9.]" options:0 error:nil];
    NSArray *lines = [subtitle componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        NSLog(@"%@", line);
        uint64_t startMs = 0ll;
        uint64_t endMs = 0ll;
        NSString *replace = [regexp stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length)  withTemplate:@""];
        if ([line isEqualToString:replace]) {
            NSLog(@"new");
            continue;
        }

        if ([self getTimes:line startMs:&startMs endMs:&endMs]) {
            NSLog(@"time : %llu -> %llu", startMs, endMs);
            Title *title = [[Title alloc] init];
            title.startMs = startMs;
            title.endMs = endMs;
            self.startMs = [NSNumber numberWithUnsignedLongLong:startMs];
            // If title with startMs already exists, use it.
            if ([self.titles.allKeys indexOfObject:self.startMs] == NSNotFound)
                [self.titles setObject:title forKey:self.startMs];
            continue;
        }

        NSLog(@"text : %@", line);
        Title *title = [self.titles objectForKey:self.startMs];
        [title.texts addObject:line];
    }
}

@end
