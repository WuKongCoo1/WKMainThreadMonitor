//
//  WKMainThreadMonitor.m
//  WKMainThreadMonitor
//
//  Created by Jacky Walker on 2019/8/28.
//  Copyright © 2019 Jacky Walker. All rights reserved.
//

#import "WKMainThreadMonitor.h"

@interface WKMainThreadMonitor ()

@property (strong, nonatomic) NSThread *monitorThread;
@property (strong, nonatomic) NSDate *recordDate;
@property (assign, nonatomic) CFRunLoopActivity activity;
@property (assign, nonatomic) NSTimeInterval monitoringDuration;
@property (assign, nonatomic) NSTimeInterval repeateTimeInterval;

@end

@implementation WKMainThreadMonitor
@synthesize isMonitoring = _isMonitoring;
+ (instancetype)sharedMonitor
{
    static WKMainThreadMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WKMainThreadMonitor alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.repeateTimeInterval = 0.0001;
        self.monitoringDuration = 0.3;
        [self monitorThread];
        [self performSelectorOnMainThread:@selector(addMainThreadObserver) withObject:nil waitUntilDone:YES];
    }
    return self;
}

- (void)startWithDuration:(NSTimeInterval)monitoringDuration timeInterval:(NSTimeInterval)repeateTimeInterval
{
    if (_isMonitoring) {
        NSLog(@"Already monitoring!");
        return;
    }
    _isMonitoring = YES;
    _recordDate = [NSDate date];
    _monitoringDuration = monitoringDuration;
    _repeateTimeInterval = repeateTimeInterval;
    
    [self performSelector:@selector(startMonitor) onThread:self.monitorThread withObject:nil waitUntilDone:NO];
}


- (void)startMonitor
{
    __weak typeof(self) weakSelf = self;
    [NSTimer scheduledTimerWithTimeInterval:_repeateTimeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.recordDate == NULL) {
            return ;
        }
        
        NSDate *currenDate = [NSDate date];
        NSTimeInterval difftime = [currenDate timeIntervalSinceDate:strongSelf.recordDate];
        if (difftime > strongSelf.monitoringDuration) {
            NSLog(@"occur main thread blocked");
        }
    }];
}

- (void)addMainThreadObserver
{
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    
    CFRunLoopObserverRef obsver = CFRunLoopObserverCreate(NULL, kCFRunLoopAllActivities, YES, 0, monitoreCallback, &context);
    CFRunLoopAddObserver([currentRunLoop getCFRunLoop], obsver, kCFRunLoopCommonModes);
}

- (void)updateRecordDate
{
    if (_recordDate == NULL) {
        _recordDate = [NSDate date];
    }
}

- (void)recordeDate
{
    switch (self.activity) {
        case kCFRunLoopEntry:
//            NSLog(@"kCFRunLoopEntry------");
            [self updateRecordDate];
            break;
        case kCFRunLoopBeforeTimers:
//            NSLog(@"kCFRunLoopBeforeTimers------");
            [self updateRecordDate];
            break;
        case kCFRunLoopBeforeSources:
//            NSLog(@"kCFRunLoopBeforeSources------");
            [self updateRecordDate];
            break;
        case kCFRunLoopBeforeWaiting:
//            NSLog(@"kCFRunLoopBeforeWaiting------");
            self.recordDate = NULL;
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"kCFRunLoopAfterWaiting------");
            [self updateRecordDate];
            break;
        case kCFRunLoopExit:
            self.recordDate = NULL;
//            NSLog(@"kCFRunLoopExit------");
            break;
            
        default:
//            NSLog(@"kRunLoopCallback------");
            break;
    }
}

void monitoreCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    WKMainThreadMonitor *monitor = (__bridge WKMainThreadMonitor *)info;
    monitor.activity = activity;
    [monitor recordeDate];
}


#pragma mark - getter && setter
- (NSThread *)monitorThread
{
    if (_monitorThread == NULL) {
        ({
            NSThread *thread = [[NSThread alloc] initWithBlock:^{
                NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
                [currentRunLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
                [currentRunLoop run];
            }];
            [thread setName:@"com.wk.monitor.thread"];
            
            [thread start];
            _monitorThread = thread;
        });
    }
    return _monitorThread;
}

- (BOOL)isMonitoring
{
    return _isMonitoring;
}



@end
