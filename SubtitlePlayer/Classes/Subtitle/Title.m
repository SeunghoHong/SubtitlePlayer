
#import "Title.h"

@implementation Title

- (instancetype)init {
	self = [super init];
	if (self) {
        self.texts = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
    self.texts = nil;
}

@end


