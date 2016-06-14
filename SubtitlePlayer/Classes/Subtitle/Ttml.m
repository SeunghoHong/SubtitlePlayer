
#import "Ttml.h"

@implementation Ttml

+ (BOOL)sniff:(NSString *)mimetype {
    NSArray *mimetypes = @[@"application/ttml+xml"];
    for (NSString *type in mimetypes) {
        if ([type.lowercaseString isEqualToString:mimetype.lowercaseString])
            return YES;
    }
    return NO;
}

- (void)parse:(NSData *)data {
    NSLog(@"not implemented");
}

@end
