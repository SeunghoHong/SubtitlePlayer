
#import <Foundation/Foundation.h>

// TODO: move
#define round2(x,dig) (floor((x)*pow(10,dig)+0.5)/pow(10,dig))

@interface Title: NSObject
@property (nonatomic, strong) NSMutableArray *texts;
// MARK: time number is unsigned long long value
@property (nonatomic, assign) uint64_t startMs;
@property (nonatomic, assign) uint64_t endMs;
@end
