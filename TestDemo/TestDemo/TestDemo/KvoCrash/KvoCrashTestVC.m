//
//  KvoCrashTestVC.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/19.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "KvoCrashTestVC.h"
#import "Person.h"

@interface KvoCrashTestVC ()
@property (nonatomic, strong) Person *p;
@end

@implementation KvoCrashTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"KvoCrashTestVC";
    NSArray *titles = @[@"移除了未注册的观察者",
                        @"重复移除多次，移除次数多于添加次数",
                        @"重复添加多次，被观察多次",
                        @"被观察者 dealloc 时仍然注册着 KVO",
                        @"观察者 dealloc 时仍然注册着 KVO",
                        @"观察者没有实现观察方法",
                        @"添加或者移除时 keypath 为空字符串"];
    [self addBtnsWithTitles:titles];
    self.p = [[Person alloc]init];
}
// MARK: test
- (void)test0 {
    // 移除了未注册的观察者
    /**
     * Thread 1: "Cannot remove an observer <KvoCrashTestVC 0x7fd210e0c770> for the key path \"name\" from <Person 0x600002956f80> because it is not registered as an observer."
     */
    // 注意remove时尽量避免使用removeObserver:forKeyPath:方法，详情如下官方文档。
    /* Register or deregister as an observer of the value at a key path relative to the receiver. The options determine what is included in observer notifications and when they're sent, as described above, and the context is passed in observer notifications as described above. You should use -removeObserver:forKeyPath:context: instead of -removeObserver:forKeyPath: whenever possible because it allows you to more precisely specify your intent. When the same observer is registered for the same key path multiple times, but with different context pointers each time, -removeObserver:forKeyPath: has to guess at the context pointer when deciding what exactly to remove, and it can guess wrong.
    */
    [self.p removeObserver:self forKeyPath:@"name" context:NULL];
}
- (void)test1 {
    // 重复移除多次，移除次数多于添加次数
    /**
     * Thread 1: "Cannot remove an observer <KvoCrashTestVC 0x7ffb0961bd90> for the key path \"name\" from <Person 0x6000002ca260> because it is not registered as an observer."
     */
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:self forKeyPath:@"name" options:options context:NULL];
    self.p.name = @"jack";
    [self.p removeObserver:self forKeyPath:@"name" context:NULL];
    [self.p removeObserver:self forKeyPath:@"name" context:NULL];
}
- (void)test2 {
    // 重复添加多次，被观察多次
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:self forKeyPath:@"name" options:options context:NULL];
    [self.p addObserver:self forKeyPath:@"name" options:options context:NULL];
    self.p.name = @"jack";
}
- (void)test3 {
    // 被观察者 dealloc 时仍然注册着 KVO
    /**
     * iOS 11之前会崩溃
     */
    Person *p = [[Person alloc]init];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [p addObserver:self forKeyPath:@"name" options:options context:NULL];
    p.name = @"jack";
}
- (void)test4 {
    // 观察者 dealloc 时仍然注册着 KVO
    /**
     * Thread 1: EXC_BAD_ACCESS (code=EXC_I386_GPFLT)
     */
    KvoCrashTestVC *obj = [[KvoCrashTestVC alloc]init];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:obj forKeyPath:@"name" options:options context:NULL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.p.name = @"jack";
    });
}
- (void)test5 {
    // 观察者没有实现观察方法
    // 测试时，把下面的observeValueForKeyPath:ofObject:change:context:方法注释掉
    /**
     * Thread 1: "<KvoCrashTestVC: 0x7faccc511c00>: An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.\nKey path: name\nObserved object: <Person: 0x600000835c60>\nChange: {\n    kind = 1;\n    new = jack;\n    old = \"<null>\";\n}\nContext: 0x0"
     */
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:self forKeyPath:@"name" options:options context:NULL];
    self.p.name = @"jack";
}
- (void)test6 {
    // 添加或者移除时 keypath 为空字符串
    /**
     * Thread 1: "-[__NSCFConstantString characterAtIndex:]: Range or index out of bounds"
     */
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:self forKeyPath:@"" options:options context:NULL];
    [self.p removeObserver:self forKeyPath:@"" context:NULL];
    self.p.name = @"jack";
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"object = %@ \n keyPath = %@ \n change = %@ \n context = %@", object, keyPath, change, context);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
