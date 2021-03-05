//
//  ViewController.m
//  RunLoop_CustomSource0
//
//  Created by jianqin_ruan on 2021/3/2.
//

#import "ViewController.h"
#import "RunLoopSource.h"
#import "fishhook.h"

@interface ViewController ()
@property (nonatomic, strong) RunLoopContext *context;
@property (nonatomic, strong) UITextView *logView;
@end

//ssize_t writev(int, const struct iovec *, int);
static NSMutableString *logString = nil;
static ssize_t (*orig_writev)(int , const struct iovec *, int);
ssize_t new_writev(int filedes, const struct iovec *iov, int iocnt) {
    if (!logString) {
        logString = [NSMutableString string];
    }
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < iocnt; i++) {
        char *c = (char *)iov[i].iov_base;
        [string appendString:[NSString stringWithCString:c encoding:NSUTF8StringEncoding]];
    }
    ssize_t result = orig_writev(filedes, iov, iocnt);
    dispatch_async(dispatch_get_main_queue(), ^{
        logString = [[logString stringByAppendingString:[NSString stringWithFormat:@"%@\n",string]] mutableCopy];
        [((ViewController *)[UIApplication sharedApplication].windows.firstObject.rootViewController) refreshLogView];
    });
    return result;
}

@implementation ViewController

+ (void)load {
    struct rebinding writev_rebinding = {"writev", new_writev, (void *)&orig_writev};
    struct rebinding rebs[] = {writev_rebinding};
    rebind_symbols(rebs, 1);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _configureUI];
}

- (void)_configureUI {
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
    b1.backgroundColor = [UIColor grayColor];
    b1.layer.cornerRadius = 5;
    b1.clipsToBounds = YES;
    [b1 setTitle:@"Add Source" forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b1 addTarget:self action:@selector(_addSource) forControlEvents:UIControlEventTouchUpInside];
    b1.frame = CGRectMake(10, 80, 1, 1);
    [b1 sizeToFit];
    [self.view addSubview:b1];
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    b2.backgroundColor = [UIColor grayColor];
    b2.layer.cornerRadius = 5;
    b2.clipsToBounds = YES;
    [b2 setTitle:@"Fire Source" forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b2 addTarget:self action:@selector(_fireSource) forControlEvents:UIControlEventTouchUpInside];
    b2.frame = CGRectMake(10 + b1.frame.size.width + 10, 80, 1, 1);
    [b2 sizeToFit];
    [self.view addSubview:b2];
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom];
    b3.backgroundColor = [UIColor grayColor];
    b3.layer.cornerRadius = 5;
    b3.clipsToBounds = YES;
    [b3 setTitle:@"Fire Source" forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b3 addTarget:self action:@selector(_removeSource) forControlEvents:UIControlEventTouchUpInside];
    b3.frame = CGRectMake(10 + b1.frame.size.width + 10 + b2.frame.size.width + 10, 80, 1, 1);
    [b3 sizeToFit];
    [self.view addSubview:b3];
    
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(10, b1.frame.origin.y + b1.frame.size.height + 20, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - (b1.frame.origin.y + b1.frame.size.height + 40))];
    self.logView.editable = NO;
    self.logView.textColor = [UIColor whiteColor];
    self.logView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.logView];
    
    UIButton *clear = [UIButton buttonWithType:UIButtonTypeCustom];
    clear.backgroundColor = [UIColor grayColor];
    clear.layer.cornerRadius = 5;
    clear.clipsToBounds = YES;
    [clear setTitle:@"Clear" forState:UIControlStateNormal];
    [clear setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clear addTarget:self action:@selector(_clear) forControlEvents:UIControlEventTouchUpInside];
    clear.frame = CGRectMake(10 + b1.frame.size.width + 10 + b2.frame.size.width + 10 + b3.frame.size.width + 10, 80, 1, 1);
    [clear sizeToFit];
    [self.view addSubview:clear];
}

- (void)refreshLogView {
    self.logView.text = logString;
    [self.logView scrollRectToVisible:CGRectMake(0, self.logView.contentSize.height-15, self.logView.contentSize.width, 10) animated:YES];
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

- (void)_clear {
    logString = [NSMutableString stringWithFormat:@"%@",@""];
    self.logView.text = @"";
    [self.logView scrollRectToVisible:CGRectMake(0, self.logView.contentSize.height-15, self.logView.contentSize.width, 10) animated:YES];
}

@end
