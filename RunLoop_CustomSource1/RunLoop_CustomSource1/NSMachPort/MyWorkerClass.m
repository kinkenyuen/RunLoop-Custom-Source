//
//  MyWorkerClass.m
//  RunLoop_CustomSource1
//
//  Created by jianqin_ruan on 2021/3/6.
//

#import "MyWorkerClass.h"

@interface MyWorkerClass () <NSPortDelegate>
@property (nonatomic, strong) NSPort *remotePort;//主线程的port
@property (nonatomic, strong) NSPort *myPort;//子线程本地的port
@property (nonatomic, strong) NSMutableArray *arr;
@end

@implementation MyWorkerClass

- (void)LaunchThreadWithPort:(NSPort *)port {
    @autoreleasepool {
        //1. 保存主线程传入的port
        self.remotePort = port;
        
        //2. 设置子线程名字
        [[NSThread currentThread] setName:@"MyWorkerClassThread"];
        
        //3. 开启runloop
        [[NSRunLoop currentRunLoop] run];
        
        //4. 创建自己port
        self.myPort = [NSPort port];
        
        //5.
        self.myPort.delegate = self;
        
        //6. 将自己的port添加到runloop
        //作用1、防止runloop执行完毕之后推出
        //作用2、接收主线程发送过来的port消息
        [[NSRunLoop currentRunLoop] addPort:self.myPort forMode:NSDefaultRunLoopMode];
        
        //7. 完成向主线程port发送消息
        [self sendPortMessage];
    }
}

- (void)sendPortMessage {
    NSString *str1 = @"aaa111";
    NSString *str2 = @"bbb222";
    self.arr = [[NSMutableArray alloc] initWithArray:@[[str1 dataUsingEncoding:NSUTF8StringEncoding],[str2 dataUsingEncoding:NSUTF8StringEncoding]]];
    //发送消息到主线程，操作1
//    [self.remotePort sendBeforeDate:[NSDate date] msgid:kCheckinMessage components:self.arr from:self.myPort reserved:0];
    
    //发送消息到主线程，操作2
    [self.remotePort sendBeforeDate:[NSDate date] components:self.arr from:self.myPort reserved:0];
}

@end
