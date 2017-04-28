//
//  SysyemLogHoverButton.m
//  TestNSlog
//
//  Created by 林通 on 2017/4/25.
//  Copyright © 2017年 yohunl. All rights reserved.
//

#import "SysyemLogHoverButton.h"
#import "HttpServerLogger.h"



int printf(const char * __restrict format, ...)
{
    va_list args;
    va_start(args,format);
    NSLogv([NSString stringWithUTF8String:format], args) ;
    va_end(args);
    return 1;
}

@implementation SysyemLogHoverButton


+ (void)redirectLog
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"dr.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (void)load
{
    __weak id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIApplicationDidFinishLaunchingNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
         if(isatty(STDOUT_FILENO)) {  //真机调试
             return;
         }
#if (TARGET_IPHONE_SIMULATOR)
         // 在模拟器的情况下、
         return;
#endif
         //只在真机并且离线的时候执行以下命令
         [self redirectLog];
         SysyemLogHoverButton *btn = [SysyemLogHoverButton shared];
         [[[UIApplication sharedApplication]keyWindow]addSubview:btn];
     }];
  
}

+ (instancetype)shared
{
    static SysyemLogHoverButton *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.frame = CGRectMake(0, 0, 50, 50);
        _instance.layer.cornerRadius = 25;
        _instance.backgroundColor = [UIColor redColor];
        _instance.layer.shadowColor=[UIColor grayColor].CGColor;
        _instance.layer.shadowOffset=CGSizeMake(2, 2);
        _instance.layer.shadowOpacity=1;
        [_instance addPan];
        [_instance addTap];
        [_instance addText];
    });
    return _instance;
}


-(void)addText{
    UILabel *textView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    textView.text = @"开";
    self.label = textView;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:17];
    [self addSubview:self.label];
    self.label.textColor = [UIColor whiteColor];
    self.label.center = CGPointMake(self.frame.size.height/2, self.frame.size.height/2);
    
}

-(void)addTap
{
    self.userInteractionEnabled = YES;
     UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event:)];
    [self addGestureRecognizer:tapGesture];
    
}

-(void)addPan
{
    //创建一个可以拖动的UIView对象
    [self setBackgroundColor:[UIColor redColor]];
    //创建手势
    UIPanGestureRecognizer *panGR =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectDidDragged:)];
    //限定操作的触点数
    [panGR setMaximumNumberOfTouches:1];
    [panGR setMinimumNumberOfTouches:1];
    //将手势添加到draggableObj里
    [self addGestureRecognizer:panGR];
    [self setTag:100];
}

- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged ) {
        //注意，这里取得的参照坐标系是该对象的上层View的坐标。
        CGPoint offset = [sender translationInView:[[UIApplication sharedApplication]keyWindow]];
        UIView *draggableObj = [self viewWithTag:100];
        //通过计算偏移量来设定draggableObj的新坐标
        [draggableObj setCenter:CGPointMake(draggableObj.center.x + offset.x, draggableObj.center.y + offset.y)];
        //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
        [sender setTranslation:CGPointMake(0, 0) inView:self];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        CGPoint offset = [sender translationInView:[[UIApplication sharedApplication]keyWindow]];
        UIView *draggableObj = [self viewWithTag:100];
        //通过计算偏移量来设定draggableObj的新坐标
        int x = draggableObj.center.x + offset.x;
        int y = draggableObj.center.y + offset.y;
        int sw = [[UIApplication sharedApplication]keyWindow].frame.size.width;
        int sh = [[UIApplication sharedApplication]keyWindow].frame.size.height;
        int mx = x > sw /2 ? sw - x : x;
        int my = y > sh /2 ? sh - y : y;
        BOOL flag = mx > my;
        int sMin = 25;
        if(flag){
            sMin = y > sh /2?sh - 25:25;
        }else{
            sMin = x > sw /2?sw - 25:25;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [draggableObj setCenter:CGPointMake(flag?draggableObj.center.x + offset.x:sMin,!flag? draggableObj.center.y + offset.y:sMin)];
        }];
        //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
        [sender setTranslation:CGPointMake(0, 0) inView:self];
    }
}

-(void )showToastView
{
    UIWindow *window = [[UIApplication sharedApplication]keyWindow];
    if(self.toastLable == nil){
        UILabel *toast = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
        self.toastLable = toast;
        id webServer = [[HttpServerLogger shared]valueForKey:@"webServer"];
        NSString *url = [webServer valueForKey:@"serverURL"];
        
        self.toastLable.text = @"请在同一Wifi下打开 游览器：输入您的ip+端口号8080查看log日志:";
       NSString *toastText = [NSString stringWithFormat:@"%@%@",self.toastLable.text,url];
        self.toastLable.text = toastText;
        self.toastLable.textColor = [UIColor whiteColor];
        self.toastLable.numberOfLines = 0;
        toast.center = window.center;
        toast.backgroundColor = [UIColor redColor];
        toast.layer.shadowColor=[UIColor grayColor].CGColor;
        toast.layer.shadowOffset=CGSizeMake(2, 2);
        toast.layer.shadowOpacity=1;
    }
    [window addSubview:self.toastLable];
}

- (void)event:(UITapGestureRecognizer *)gesture
{
    CGRect rect = self.frame;
    CGPoint center = self.center ;
    double delayInSeconds = 3.0;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
     dispatch_queue_t concurrentQueue =dispatch_get_main_queue();
    //推迟两纳秒执行
   
   
    if(self.isOpen){
       [[HttpServerLogger shared]stopServer];
        
    }else{
        [[HttpServerLogger shared]startServer];
        [ self showToastView];
        if(self.toastLable.superview){
            dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
                [self.toastLable removeFromSuperview];
            });
        }
    }
    self.isOpen = !self.isOpen;
    self.label.text = self.isOpen?@"关":@"开";
   
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, 60, 60);
        self.center = center;
        self.label.center = CGPointMake(self.frame.size.height/2, self.frame.size.height/2);
    } completion:^(BOOL finished) {
        if(finished){
            [UIView animateWithDuration:0.1 animations:^{
                self.frame = rect;
                self.center = center;
                self.label.center = CGPointMake(self.frame.size.height/2, self.frame.size.height/2);
            } completion:^(BOOL finished) {
                if(finished){
                    self.userInteractionEnabled = YES;
                }
               
            }];
        }
    }];
   
}
@end
