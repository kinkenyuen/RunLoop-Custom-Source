//
//  RunLoopSource.h
//  RunLoop_CustomSource0
//
//  Created by jianqin_ruan on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 这些是runloop事件源回调函数
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine (void *info);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);

@interface RunLoopSource : NSObject
@property (readonly) CFRunLoopSourceRef runLoopSource;

/// 初始化source
- (id)init;

/// 将source添加到当前线程的runloop
- (void)addToCurrentRunLoop;

/// 从当前线程runloop移除source
- (void)invalidate;

// 回调方法
- (void)sourceFired;

//提供手动触发自定义源的方法
- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop;

@end

@interface RunLoopContext : NSObject
@property (readonly) CFRunLoopRef runLoop;
@property (readonly) RunLoopSource* source;
- (id)initWithSource:(RunLoopSource*)src andLoop:(CFRunLoopRef)loop;
@end

NS_ASSUME_NONNULL_END
