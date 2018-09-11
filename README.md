##### 今天使用第三方的时候出现了bug，最后发现是`UIApplication` `openURL`的问题。

现象描述：当连接`xcode`运行项目时，`app`界面会卡住一会，然后才有响应；当断开`xcode`时，`app`界面会卡住一会，然后闪退。

崩溃日志：

    Exception Type:  EXC_CRASH (SIGKILL)
    Exception Codes: 0x0000000000000000, 0x0000000000000000
    Exception Note:  EXC_CORPSE_NOTIFY
    Termination Reason: Namespace SPRINGBOARD, Code 0x8badf00d
    Triggered by Thread:  0
    
    Filtered syslog:
    None found
    
    Thread 0 name:  Dispatch queue: com.apple.main-thread
    Thread 0 Crashed:
    0   libsystem_kernel.dylib        	0x000000018d48b224 mach_msg_trap + 8
    1   libsystem_kernel.dylib        	0x000000018d48b09c mach_msg + 72
    2   libdispatch.dylib             	0x000000018d37cee4 _dispatch_mach_send_and_wait_for_reply + 540
    3   libdispatch.dylib             	0x000000018d37d2e8 dispatch_mach_send_with_result_and_wait_for_reply + 56
    4   libxpc.dylib                  	0x000000018d5a4edc xpc_connection_send_message_with_reply_sync + 196
    5   Foundation                    	0x000000018f0b09cc __NSXPCCONNECTION_IS_WAITING_FOR_A_SYNCHRONOUS_REPLY__ + 12
    6   Foundation                    	0x000000018f0b0070 -[NSXPCConnection _sendInvocation:withProxy:remoteInterface:withErrorHandler:timeout:userInfo:] + 2940
    7   CoreFoundation                	0x000000018e4b2d54 ___forwarding___ + 404
    8   CoreFoundation                	0x000000018e3aed4c _CF_forwarding_prep_0 + 92
    9   MobileCoreServices            	0x000000018fe64fb8 -[LSApplicationWorkspace openURL:withOptions:error:] + 248
    10  UIKit                         	0x000000019486acac -[UIApplication _openURL:] + 144
    11  CouponPurchase                	0x000000010085d27c 0x100000000 + 8770172
    12  CouponPurchase                	0x0000000100100dac 0x100000000 + 1052076
    13  CouponPurchase                	0x00000001003bf108 0x100000000 + 3928328
    14  CouponPurchase                	0x0000000100381008 0x100000000 + 3674120
    15  CouponPurchase                	0x00000001003be370 0x100000000 + 3924848
    16  CouponPurchase                	0x00000001003be184 0x100000000 + 3924356
    17  CouponPurchase                	0x00000001003be2f0 0x100000000 + 3924720
    18  CouponPurchase                	0x0000000100368cac 0x100000000 + 3574956
    19  CouponPurchase                	0x0000000100368a60 0x100000000 + 3574368
    20  CoreFoundation                	0x000000018e4b2d54 ___forwarding___ + 404
    21  CoreFoundation                	0x000000018e3aed4c _CF_forwarding_prep_0 + 92
    22  UIKit                         	0x000000019486bc28 __45-[UIApplication _applicationOpenURL:payload:]_block_invoke + 752
    23  UIKit                         	0x000000019486b6b0 -[UIApplication _applicationOpenURL:payload:] + 644
    24  UIKit                         	0x0000000194874474 -[UIApplication _handleNonLaunchSpecificActions:forScene:withTransitionContext:completion:] + 6260
    25  UIKit                         	0x0000000194877bb4 __88-[UIApplication _handleApplicationLifecycleEventWithScene:transitionContext:completion:]_block_invoke + 

注意这里的异常是` __NSXPCCONNECTION_IS_WAITING_FOR_A_SYNCHRONOUS_REPLY__ + 12`，等待同步回复。

而且，我注意到一个现象，每当走我自己的路由协议，然后在调用第三方的时候就会出现，而如果直接调用第三方方法就不会出现。

所以，定位到了路由相关的地方。而上面信息中有`UIApplication _openURL:] + 144`信息。所以，猜测是这个方法多次调用，由于方法没有完成导致的同步等待。

如果你在网上搜一下`openURL:`，就会出现关于 调用`openURL:`方法响应慢的解决办法 这些信息。具体的解决办法就是加一个延时。

下面列出测试用例：

为了重现bug，先给项目添加一个`ms`协议，然后添加如下代码：

    - (void)test_111
    {
        NSLog(@"111 - start");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
        NSLog(@"222 - end");
        
        // 打印日志
        /*
         2018-09-11 17:34:45.106242+0800 TestOpenUrl[10813:16592945] 111 - start
         2018-09-11 17:34:55.161707+0800 TestOpenUrl[10813:16592945] 222 - end
         */
    }
    
可以看到，这里日志时间相差了10秒钟。
***
如果使用了延时呢？

    - (void)test_222
    {
        NSLog(@"222 - start");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxxx"]];
        });
        NSLog(@"222 - end");
        
        // 打印日志
        /*
         2018-09-11 17:36:24.810128+0800 TestOpenUrl[10896:16598430] 222 - start
         2018-09-11 17:36:24.853829+0800 TestOpenUrl[10896:16598430] 222 - end
         */
    }

可以看到，这里时间间隔就变得很短了。确实解决了卡顿的问题。
***

其实还有一种解决方法：

    - (void)test_333
    {
        NSLog(@"333 - start");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxx"] options:nil completionHandler:nil];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxx"] options:nil completionHandler:nil];
         NSLog(@"333 - end");
        
        // 打印日志
        /*
         2018-09-11 17:37:17.812804+0800 TestOpenUrl[10945:16601725] 333 - start
         2018-09-11 17:37:17.813552+0800 TestOpenUrl[10945:16601725] 333 - end
         */
    }
    
使用新的api也能够解决这个问题。但是该api必要在iOS9以上使用。所以如果你的项目需要适配iOS9以下的系统，还是乖乖的加上延时吧。
***

虽然延时可以解决这个问题，但是我一直觉得不靠谱，到底延时多久才好呢？其实该问题的关键就是如何知道`openURL:`方法执行完毕的时机。如果等到`openURL:`执行完毕之后再调用`openURL:`方法，就不会出现问题。而`openURL:`执行完毕的时机，我费尽心思，还是拿不到。。。。

如果哪位大神知道，烦请告知。

上面完整测试用例在[这里](https://github.com/jianghui1/TestOpenUrl)。
