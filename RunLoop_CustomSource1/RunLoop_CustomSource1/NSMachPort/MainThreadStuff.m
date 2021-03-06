//
//  MainThreadStuff.m
//  RunLoop_CustomSource1
//
//  Created by jianqin_ruan on 2021/3/6.
//

#import "MainThreadStuff.h"
#import "MyWorkerClass.h"

@interface MainThreadStuff () <NSMachPortDelegate>
@property (nonatomic, strong) NSMutableArray *distantPorts;
@end

@implementation MainThreadStuff

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.distantPorts = [NSMutableArray array];
    }
    return self;
}

- (void)launchThread {
    NSPort* myPort = [NSMachPort port];
    if (myPort)
    {
        // 通过代理方法处理子线程发送的消息
        [myPort setDelegate:self];
 
        // 向主线程runloop添加port
        [[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];
 
        // 开启子线程，并将主线程自己的port对象传入
        [NSThread detachNewThreadSelector:@selector(LaunchThreadWithPort:)
               toTarget:[[MyWorkerClass alloc] init] withObject:myPort];
    }
}
 
// 处理子线程消息
- (void)handlePortMessage:(id)portMessage
{
    //由于苹果没有暴露NSPortMessage的接口，但是文档又有方法接口的描述
    //所以换用另外一种获取方式
    unsigned int messageId = (int)[[portMessage valueForKeyPath:@"msgid"] unsignedIntegerValue];
    
    NSPort* distantPort = nil;
    if (messageId == kCheckinMessage)
    {
        // 获取远程port，即子线程的本地port
        distantPort = [portMessage valueForKeyPath:@"remotePort"];
        
        // 获取消息内容
        NSMutableArray *arr = [[portMessage valueForKeyPath:@"components"] mutableCopy];
        for (int i = 0; i < arr.count; i++) {
            NSData *data = [arr objectAtIndex:i];
            NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"content frome worker thread : %@",str);
        }

        // 保存子线程的port供以后使用
        [self storeDistantPort:distantPort];
    }
    else
    {
        // 处理其他消息
        // 获取消息内容
        NSMutableArray *arr = [[portMessage valueForKeyPath:@"components"] mutableCopy];
        for (int i = 0; i < arr.count; i++) {
            NSData *data = [arr objectAtIndex:i];
            NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"content frome worker thread : %@",str);
        }
    }
}

- (void)storeDistantPort:(NSPort *)distantPort {
    [self.distantPorts addObject:distantPort];
}

@end
