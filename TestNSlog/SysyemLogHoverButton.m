//
//  SysyemLogHoverButton.m
//  TestNSlog
//
//  Created by 林通 on 2017/4/25.
//  Copyright © 2017年 yohunl. All rights reserved.
//

#import "SysyemLogHoverButton.h"
#import "HttpServerLogger.h"
@implementation SysyemLogHoverButton
+ (void)load
{
    __weak id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIApplicationDidFinishLaunchingNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
         SysyemLogHoverButton *btn = [SysyemLogHoverButton shared];
        
         [[[UIApplication sharedApplication]keyWindow]addSubview:btn];
         [[NSNotificationCenter defaultCenter] removeObserver:observer];
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



- (void)event:(UITapGestureRecognizer *)gesture
{
    CGRect rect = self.frame;
    CGPoint center = self.center ;
    if(self.isOpen){
       [[HttpServerLogger shared]stopServer];
    }else{
        [[HttpServerLogger shared]startServer];
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
