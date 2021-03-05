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

