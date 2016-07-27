//
//  ViewController.m
//  GCDDemo
//
//  Created by xiabob on 16/7/27.
//  Copyright © 2016年 xiabob. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self gcdMethod7];
}

- (void)gcdMethod1 {
    //自动添加到group中
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"2");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
    });
    
    //会阻塞当前线程
    //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"1、2、3打印完了");
    });
}

- (void)gcdMethod2 {
    //手动添加到group中
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);
    //注意dispatch_group_enter和dispatch_group_leave要匹配
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"1");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"3");
        dispatch_group_leave(group);
    });
    
    //会阻塞当前线程
    //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"1、2、3打印完了");
    });
}

- (void)gcdMethod3 {
    //自动添加到group中
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);
    //这种情况无法做到1、2、3打印完成后，再执行dispatch_group_notify中block的代码
    //因为dispatch_group_async里面的block是马上返回的，它会认为当前任务已经执行完了
    //使用手动添加的方式可以解决，使用信号量也可以解决
    dispatch_group_async(group, queue, ^{
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"1");
        });
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"2");
        });
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"3");
        });
    });
    
    //会阻塞当前线程
    //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"1、2、3打印完了");
    });
}

//手动添加
- (void)gcdMethod4 {
    //手动添加到group中
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);
    //dispatch_group_enter和dispatch_group_leave更多是这样用
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"1");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"2");
            dispatch_group_leave(group);
        });
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"3");
            dispatch_group_leave(group);
        });
    });
    
    //会阻塞当前线程
    //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"1、2、3打印完了");
    });
}

//信号量
- (void)gcdMethod5 {
    //自动添加到group中
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"1");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"2");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"3");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"1、2、3打印完了");
    });
}

//dispatch_barrier_async
- (void)gcdMethod6 {
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:0.1];
        NSLog(@"1");
    });

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:0.1];
        NSLog(@"2");

    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:0.1];
        NSLog(@"3");
    });
    
    dispatch_barrier_async(queue, ^{
       NSLog(@"1、2、3打印完了");
    });
}

//死锁
- (void)gcdMethod7 {
    dispatch_queue_t queue = dispatch_queue_create("com.xiabob.gcd",
                                                   DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"1");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"2");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"3");
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });

    dispatch_barrier_async(queue, ^{
        NSLog(@"死锁，永远不会执行到这");
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
