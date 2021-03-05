# RunLoop-Custom-Source0
# 描述

自定义runloop事件源，类型为source0。这个例子是从苹果官方文档[Configuring Run Loop Sources](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW7)抽出来玩一下。

# 分析说明

## source0结构

```c
typedef struct {
    CFIndex	version;
    void *	info;
    const void *(*retain)(const void *info);
    void	(*release)(const void *info);
    CFStringRef	(*copyDescription)(const void *info);
    Boolean	(*equal)(const void *info1, const void *info2);
    CFHashCode	(*hash)(const void *info);
    void	(*schedule)(void *info, CFRunLoopRef rl, CFRunLoopMode mode);
    void	(*cancel)(void *info, CFRunLoopRef rl, CFRunLoopMode mode);
    void	(*perform)(void *info);
} CFRunLoopSourceContext;
```

| 成员     | 描述                                           |
| -------- | ---------------------------------------------- |
| info     | 传给回调函数的上下文参数                       |
| schedule | 向runloop添加source时，会触发该回调函数        |
| perform  | 手动触发添加的自定义事件源后，会触发该回调函数 |
| cancel   | 将source从runloop中移除时，会触发该回调函数    |

## 回调函数

```c
// 这些是runloop事件源回调函数
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine (void *info);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode) {
    NSLog(@"kk | current Thread : %@ | %s",[NSThread currentThread], __func__);
    RunLoopSource *obj = (__bridge RunLoopSource*)info;
    AppDelegate  *del = [AppDelegate sharedAppDelegate];
    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
 
    [del performSelectorOnMainThread:@selector(registerSource:)
                                withObject:theContext waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine (void *info) {
    NSLog(@"kk | current Thread : %@ | %s",[NSThread currentThread], __func__);
    RunLoopSource*  obj = (__bridge RunLoopSource*)info;
    [obj sourceFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode) {
    NSLog(@"kk | current Thread : %@ | %s",[NSThread currentThread], __func__);
    RunLoopSource* obj = (__bridge RunLoopSource*)info;
    AppDelegate* del = [AppDelegate sharedAppDelegate];
    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];

    [del performSelectorOnMainThread:@selector(removeSource:)
                                    withObject:theContext waitUntilDone:YES];
}
```

## RunLoopSource、RunLoopContext

```objc
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
```

## 创建自定义事件源

```objc
CFRunLoopSourceContext    context = {0, (__bridge void*)(self), NULL, NULL, NULL, NULL, NULL,
                                            &RunLoopSourceScheduleRoutine,
                                            &RunLoopSourceCancelRoutine,
                                            &RunLoopSourcePerformRoutine};
     
_runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
```

## 添加事件源到runloop

```c
CFRunLoopRef runLoop = CFRunLoopGetCurrent();
CFRunLoopAddSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
```

## 手动触发事件源

```c
CFRunLoopSourceSignal(_runLoopSource);
CFRunLoopWakeUp(runloop);
```

## 移除事件源

```c
CFRunLoopRef runloop = CFRunLoopGetCurrent();
CFRunLoopRemoveSource(runloop, _runLoopSource, kCFRunLoopDefaultMode);
```

