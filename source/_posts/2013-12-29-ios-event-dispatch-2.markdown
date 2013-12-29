---
layout: post
title: "iOS事件机制(二)"
date: 2013-12-29 10:20:43 +0800
comments: true
categories: iOS
---
本篇内容接上一篇[iOS事件机制(一)](http://ryantang.me/blog/2013/12/07/ios-event-dispatch-1/)，本次主要介绍iOS事件中的多点触控事件和手势事件。

从上一篇的内容我们知道，在iOS中一个事件用一个UIEvent对象表示，UITouch用来表示一次对屏幕的操作动作，由多个UITouch对象构成了一个UIEvent对象。另外，```UIResponder```是所有响应者的父类，UIView、UIViewController、UIWindow、UIApplication都直接或间接的集成了UIResponder。关于事件响应者链的传递机制在上一篇中也有阐述，如果你还不是很了解，可以先看看[iOS事件机制(一)](http://ryantang.me/blog/2013/12/07/ios-event-dispatch-1/)。

<!--More-->

## 事件处理方法
UIResponder中定义了一系列对事件的处理方法，他们分别是：

- -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
- -(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
- -(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
- -(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event

从方法名字可以知道，他们分别对应了屏幕事件的开始、移动、结束和取消几个阶段，前三个阶段理解都没问题，最后一个取消事件的触发时机是在诸如突然来电话或是系统杀进程时调用。这些方法的第一个参数定义了UITouch对象的一个集合(NSSet)，它的数量表示了这次事件是几个手指的操作，目前iOS设备支持的多点操作手指数最多是5。第二个参数是当前的UIEvent对象。下图展示了一个UIEvent对象与多个UITouch对象之间的关系。

![](/images/2013/12/ios_event_dispatch/11.png)

### 一、点击事件
首先，新建一个自定义的View继承于UIView，并实现上述提到的事件处理方法，我们可以通过判断UITouch的tapCount属性来决定响应单击、双击或是多次点击事件。

```c MyView.m
#import "MyView.h"
@implementation MyView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *aTouch in touches) {
        if (aTouch.tapCount == 2) {
            // 处理双击事件
            [self respondToDoubleTapGesture];
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)respondToDoubleTapGesture
{
    NSLog(@"respondToDoubleTapGesture");
}

@end
```
### 二、滑动事件
滑动事件一般包括上下滑动和左右滑动，判断是否是一次成功的滑动事件需要考虑一些问题，比如大部分情况下，用户进行一次滑动操作，这次滑动是否是在一条直线上？或者是否是基本能保持一条直线的滑动轨迹。或者判断是上下滑动还是左右滑动等。另外，滑动手势一般有一个起点和一个终点，期间是在屏幕上画出的一个轨迹，所以需要对这两个点进行判断。我们修改上述的MyView.m的代码来实现一次左右滑动的事件响应操作。

```c MyView.m
#import "MyView.h"

#define HORIZ_SWIPE_DRAG_MIN  12    //水平滑动最小间距
#define VERT_SWIPE_DRAG_MAX    4    //垂直方向最大偏移量

@implementation MyView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    // startTouchPosition是一个CGPoint类型的属性，用来存储当前touch事件的位置
    self.startTouchPosition = [aTouch locationInView:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint currentTouchPosition = [aTouch locationInView:self];
    
    //  判断水平滑动的距离是否达到了设置的最小距离，并且是否是在接近直线的路线上滑动（y轴偏移量）
    if (fabsf(self.startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN &&
        fabsf(self.startTouchPosition.y - currentTouchPosition.y) <= VERT_SWIPE_DRAG_MAX)
    {
        // 满足if条件则认为是一次成功的滑动事件，根据x坐标变化判断是左滑还是右滑
        if (self.startTouchPosition.x < currentTouchPosition.x) {
            [self rightSwipe];//右滑响应方法
        } else {
            [self leftSwipe];//左滑响应方法
        }
        //重置开始点坐标值
        self.startTouchPosition = CGPointZero;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//当事件因某些原因取消时，重置开始点坐标值
    self.startTouchPosition = CGPointZero;
}

-(void)rightSwipe
{
    NSLog(@"rightSwipe");
}
    
-(void)leftSwipe
{
    NSLog(@"leftSwipe");
}

@end
```
### 三、拖拽事件
在屏幕上我们可以拖动某一个控件(View)进行移动，这种事件成为拖拽事件，其实现原理就是在不改变View的大小尺寸的前提下改变View的显示坐标值，为了达到动态移动的效果，我们可以在move阶段的方法中进行坐标值的动态更改，还是重写MyView.m的事件处理方法，这次在touchesMove方法中进行处理。

```c MyView.m
#import "MyView.h"
@implementation MyView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    //获取当前触摸操作的位置坐标
    CGPoint loc = [aTouch locationInView:self];
    //获取上一个触摸点的位置坐标
    CGPoint prevloc = [aTouch previousLocationInView:self];
    
    CGRect myFrame = self.frame;
    //改变View的x、y坐标值
    float deltaX = loc.x - prevloc.x;
    float deltaY = loc.y - prevloc.y;
    myFrame.origin.x += deltaX;
    myFrame.origin.y += deltaY;
    //重新设置View的显示位置
    [self setFrame:myFrame];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
```
### 四、双指缩放
之前提到过UIEvent包含了一系列的UITouch对象构成一次事件，当设计多点触控操作时，可与对UIEvent对象内的UITouch对象进行处理，比如实现一个双指缩放的功能。

```c MyView.m
#import "MyView.h"
@implementation MyView
{
    BOOL pinchZoom;
    CGFloat previousDistance;
    CGFloat zoomFactor;
}

-(id)init
{
    self = [super init];
    if (self) {
        pinchZoom = NO;
        //缩放前两个触摸点间的距离
        previousDistance = 0.0f;
        zoomFactor = 1.0f;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(event.allTouches.count == 2) {
        pinchZoom = YES;
        NSArray *touches = [event.allTouches allObjects];
        //接收两个手指的触摸操作
        CGPoint pointOne = [[touches objectAtIndex:0] locationInView:self];
        CGPoint pointTwo = [[touches objectAtIndex:1] locationInView:self];
        //计算出缩放前后两个手指间的距离绝对值（勾股定理）
        previousDistance = sqrt(pow(pointOne.x - pointTwo.x, 2.0f) +
                                pow(pointOne.y - pointTwo.y, 2.0f));
    } else {
        pinchZoom = NO;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(YES == pinchZoom && event.allTouches.count == 2) {
        NSArray *touches = [event.allTouches allObjects];
        CGPoint pointOne = [[touches objectAtIndex:0] locationInView:self];
        CGPoint pointTwo = [[touches objectAtIndex:1] locationInView:self];
        //两个手指移动过程中，两点之间距离
        CGFloat distance = sqrt(pow(pointOne.x - pointTwo.x, 2.0f) +
                                pow(pointOne.y - pointTwo.y, 2.0f));
        //换算出缩放比例
        zoomFactor += (distance - previousDistance) / previousDistance;
        zoomFactor = fabs(zoomFactor);
        previousDistance = distance;
        
        //缩放
        self.layer.transform = CATransform3DMakeScale(zoomFactor, zoomFactor, 1.0f);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(event.allTouches.count != 2) {
        pinchZoom = NO;
        previousDistance = 0.0f;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
```
上面实现的方式有一点不足之处就是必须两个手指同时触摸按下才能达到缩放的效果，并不能达到相册里面那样一个手指触摸后，另一个手指按下也可以缩放。如果需要达到和相册照片缩放的效果，需要同时控制begin、move、end几个阶段的事件处理。这个不足就留给感兴趣的同学自己去实现了。
