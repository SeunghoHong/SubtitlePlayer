
#import "Ass.h"

/*
 // https://www.matroska.org/technical/specs/subtitles/ssa.html

 [Script Info]
 ......
 [Events]
 Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
 Comment: 0,0:00:11.86,0:00:11.94,OP Romaji,,0000,0000,0000,,OP
 .....

 Dialogue: 0,0:00:25.50,0:00:30.71,OP Romaji,,0000,0000,0000,,{\blur3}suujuuoku mono kodou no kazu sae
 Dialogue: 0,0:00:30.71,0:00:37.64,OP Romaji,,0000,0000,0000,,{\blur3}anata ni wa matataki teido no saji na toukyuu
 */

// TODO: apply style override code and check if case compare is necessary.

@interface Ass ()

@end

@implementation Ass

+ (BOOL)sniff:(NSString *)mimetype {
    NSArray *mimetypes = @[@"application/x-ass"];
    for (NSString *type in mimetypes) {
        if ([type.lowercaseString isEqualToString:mimetype.lowercaseString])
            return YES;
    }
    return NO;
}

// TODO: move NSString category
- (uint64_t)assTimeToMs:(NSString *)time {
    NSArray *token = [time componentsSeparatedByString:@":"];
    uint64_t h = [[token objectAtIndex:0] longLongValue]*60*60*1000;
    uint64_t m = [[token objectAtIndex:1] longLongValue]*60*1000;
    
    NSArray *seconds = [[token objectAtIndex:2] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",."]];
    uint64_t s = ([[seconds objectAtIndex:0] longLongValue]*1000) + round2([[seconds objectAtIndex:1] longLongValue], -2);
    
    return h + m + s;
}

- (void)parse:(NSData *)data {
    self.titles = [NSMutableDictionary dictionary];

    BOOL foundEvent = NO;
    BOOL foundFormat = NO;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    NSInteger textIndex = 0;

    // TODO: bom check
    NSString *subtitle = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (subtitle == nil) {
        NSLog(@"unknown encoding");
        return;
    }

    NSArray *lines = [subtitle componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {

        NSLog(@"%@", line);
        if ([[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            continue;
        }

        if ([[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString hasPrefix:@"[events]"]) {
            foundEvent = YES;
            continue;
        }

        if (foundEvent && [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString hasPrefix:@"format:"]) {
            NSArray *compoments = [line componentsSeparatedByString:@","];
            for (NSInteger i = 0; i < compoments.count; i++) {
                NSString *component = [[compoments objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
                if ([component isEqualToString:@"start"]) {
                    startIndex = i;
                } else if ([component isEqualToString:@"end"]) {
                    endIndex = i;
                } else if ([component isEqualToString:@"text"]) {
                    textIndex = i;
                }
            }
            foundFormat = YES;
            continue;
        }

        if (foundEvent && foundFormat &&
            [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString hasPrefix:@"dialogue:"] ) {
            NSArray *components = [line componentsSeparatedByString:@","];
            // TODO: compare format.count and components.count
            uint64_t startMs = [self assTimeToMs:[components objectAtIndex:startIndex]];
            uint64_t endMs = [self assTimeToMs:[components objectAtIndex:endIndex]];
            NSString *text = [components objectAtIndex:textIndex];

            NSNumber *key = [NSNumber numberWithUnsignedLongLong:startMs];
            Title *title = nil;
            if ([self.titles.allKeys indexOfObject:key] == NSNotFound) {
                title = [[Title alloc] init];
                title.startMs = startMs;
                title.endMs = endMs;
                [self.titles setObject:title forKey:key];
            } else {
                title = [self.titles objectForKey:key];
            }
            [title.texts addObject:text];
            NSLog(@"%llu --> %llu : %@", startMs, endMs, text);
        }
    }
}

@end
