
#import <Foundation/Foundation.h>

@class Subtitle;
@interface SubtitleFactory: NSObject

- (Subtitle *)createSubtitle:(NSString *)mimetype;

@end

