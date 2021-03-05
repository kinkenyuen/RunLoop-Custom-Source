//
//  ViewController.m
//  RunLoop_CustomSource0
//
//  Created by jianqin_ruan on 2021/3/2.
//

#import "ViewController.h"
#import "RunLoopSource.h"

@interface ViewController ()
@property (nonatomic, strong) RunLoopContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _configureUI];
}

- (void)_configureUI {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b1 setTitle:@"Add Source" forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b1 addTarget:self action:@selector(_addSource) forControlEvents:UIControlEventTouchUpInside];
    b1.frame = CGRectMake(0, screenWidth, 1, 1);
    [b1 sizeToFit];
    b1.center = CGPointMake(screenWidth * 0.5, 80);
    [self.view addSubview:b1];
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b2 setTitle:@"Fire Source" forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b2 addTarget:self action:@selector(_fireSource) forControlEvents:UIControlEventTouchUpInside];
    b2.frame = CGRectMake(0, screenWidth, 1, 1);
    [b2 sizeToFit];
    b2.center = CGPointMake(screenWidth * 0.5, 80 + screenHeight / 3 );
    [self.view addSubview:b2];
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b3 setTitle:@"Fire Source" forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b3 addTarget:self action:@selector(_removeSource) forControlEvents:UIControlEventTouchUpInside];
    b3.frame = CGRectMake(0, screenWidth, 1, 1);
    [b3 sizeToFit];
    b3.center = CGPointMake(screenWidth * 0.5, 80 + screenHeight / 3 * 2);
    [self.view addSubview:b3];
}

- (void)_addSource {
    RunLoopSource *source = [[RunLoopSource alloc] init];
    self.context = [[RunLoopContext alloc] initWithSource:source andLoop:[[NSRunLoop currentRunLoop] getCFRunLoop]];
    [self.context.source addToCurrentRunLoop];
    BOOL isContainSource = CFRunLoopContainsSource(self.context.runLoop, self.context.source.runLoopSource, kCFRunLoopDefaultMode);
    if (YES == isContainSource) {
        NSLog(@"kk | source is added to main thread runloop");
    }
}

- (void)_fireSource {
    [self.context.source fireCommandsOnRunLoop:self.context.runLoop];
}

- (void)_removeSource {
    [self.context.source invalidate];
}

@end
