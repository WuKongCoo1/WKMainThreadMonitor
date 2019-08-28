//
//  WKMainThreadMonitor.h
//  WKMainThreadMonitor
//
//  Created by Jacky Walker on 2019/8/28.
//  Copyright © 2019 Jacky Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMainThreadMonitor : NSObject

@property (assign, nonatomic, readonly) BOOL isMonitoring;

+ (instancetype)sharedMonitor;
/**
 启动监控

 @param monitoringDuration 表示卡顿时长，设置的值表示几秒钟认为是卡顿
 @param repeateTimeInterval 检测时长，设置0.01表示间隔0.01秒后进行检测
 */
- (void)startWithDuration:(NSTimeInterval)monitoringDuration timeInterval:(NSTimeInterval)repeateTimeInterval;


@end

NS_ASSUME_NONNULL_END
