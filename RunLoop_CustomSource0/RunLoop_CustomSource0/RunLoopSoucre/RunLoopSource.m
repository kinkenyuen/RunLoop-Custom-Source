//
//  RunLoopSource.m
//  RunLoop_CustomSource0
//
//  Created by jianqin_ruan on 2021/3/2.
//

#import "RunLoopSource.h"
#import "AppDelegate.h"

@implementation RunLoopSource

- (instancetype)init
{
    //创建一个自定义runloop source
    //参数2是回调函数触发时传入的上下文
    //函数参数最后3个传入对应的回调函数
    CFRunLoopSourceContext    context = {0, (__bridge void*)(self), NULL, NULL, NULL, NULL, NULL,
                                            &RunLoopSourceScheduleRoutine,
                                            &RunLoopSourceCancelRoutine,
                                            &RunLoopSourcePerformRoutine};
     
    _runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    
    return self;
}

- (void)addToCurrentRunLoop {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)invalidate {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(runloop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)sourceFired {
    NSLog(@"kk | current Thread : %@ | %s",[NSThread currentThread], __func__);
}

- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop
{
    CFRunLoopSourceSignal(_runLoopSource);
    CFRunLoopWakeUp(runloop);
}

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

@end

@implementation RunLoopContext

- (id)initWithSource:(RunLoopSource*)src andLoop:(CFRunLoopRef)loop {
    if (self = [super init]) {
        _source = src;
        _runLoop = loop;
    }
    return self;
}

@end
