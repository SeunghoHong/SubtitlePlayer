
#import <Foundation/Foundation.h>
#import "Title.h"

@class Title;
@protocol SubtitleProtocol <NSObject>
@required
+ (BOOL)sniff:(NSString *)mimetype;
- (void)parse:(NSData *)data;

- (Title *)getTitle:(NSNumber *)startTime;

- (NSString *)generateWebVTT:(uint64_t)intervalMs;
@end

@interface Subtitle: NSObject <SubtitleProtocol>

@property (nonatomic, strong) NSMutableDictionary *titles;

+ (Subtitle *)create:(NSString *)mimetype;

+ (BOOL)sniff:(NSString *)mimetype;
- (void)parse:(NSData *)data;

- (Title *)getTitle:(NSNumber *)startTime;

- (NSArray *)generateWebVTT:(uint64_t)intervalMs;

@end

