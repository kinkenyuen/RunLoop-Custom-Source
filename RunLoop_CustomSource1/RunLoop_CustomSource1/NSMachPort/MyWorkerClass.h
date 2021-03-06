//
//  MyWorkerClass.h
//  RunLoop_CustomSource1
//
//  Created by jianqin_ruan on 2021/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kCheckinMessage 100

@interface MyWorkerClass : NSObject
- (void)LaunchThreadWithPort:(NSPort *)port;
@end

NS_ASSUME_NONNULL_END
