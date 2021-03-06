//
//  ViewController.m
//  RunLoop_CustomSource1
//
//  Created by jianqin_ruan on 2021/3/6.
//

#import "ViewController.h"
#import "MainThreadStuff.h"

@interface ViewController ()
@property (nonatomic, strong) MainThreadStuff *stuff;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.stuff = [[MainThreadStuff alloc] init];
    [self.stuff launchThread];
}


@end
