//
//  ViewController.m
//  WKMainThreadMonitor
//
//  Created by Jacky Walker on 2019/8/28.
//  Copyright © 2019 Jacky Walker. All rights reserved.
//

#import "ViewController.h"
#import "WKMainThreadMonitor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[WKMainThreadMonitor sharedMonitor] startWithDuration:1.0 timeInterval:0.001];
    NSLog(@"before sleep");
    sleep(2.0);
    NSLog(@"after sleep");
        // Do any additional setup after loading the view.
    
//    while (1) {
//        int t = 0;
//        t = 12;
//    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"before sleep");
    sleep(1.2);
    NSLog(@"after sleep");


}
@end
