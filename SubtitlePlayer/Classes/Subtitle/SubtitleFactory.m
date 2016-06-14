
#import "SubtitleFactory.h"

#import "Srt.h"
#import "Smi.h"
#import "Ass.h"
#import "Ttml.h"
#import "Webvtt.h"

@implementation SubtitleFactory

- (Subtitle *)createSubtitle:(NSString *)mimetype {
	NSLog(@"create subtitle %@", mimetype);
	Subtitle *subtitle = nil;
	if ([Srt sniff:mimetype]) {
		subtitle = [[Srt alloc] init];
	} else if ([Smi sniff:mimetype]) {
		subtitle = [[Smi alloc] init];
	} else if ([Ass sniff:mimetype]) {
		subtitle = [[Ass alloc] init];
	} else if ([Ttml sniff:mimetype]) {
		subtitle = [[Ttml alloc] init];
	} else if ([Webvtt sniff:mimetype]) {
		subtitle = [[Webvtt alloc] init];
	} else {
		NSLog(@"unknown type %@", mimetype);
	}
	return subtitle;
}

@end

