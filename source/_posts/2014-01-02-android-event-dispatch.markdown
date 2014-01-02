---
layout: post
title: "Android事件传递机制"
date: 2014-01-02 10:12:13 +0800
comments: true
keywords: Android,事件
categories: Android
---
###### 本文为InfoQ中文站特供稿件，首发地址为：[http://www.infoq.com/cn/articles/android-event-delivery-mechanism](http://www.infoq.com/cn/articles/android-event-delivery-mechanism)。如需转载，请与InfoQ中文站联系。

> 运用的前提是掌握</br>
> 掌握的本质是理解

本篇内容将结合Android源码来分析Android的事件传递机制。众所周知，点按、滑动、触摸构成了Android等智能设备的基本操作，几乎所有的应用都通过对触摸屏的操作来进行应用程序的使用。那么，在Android中，触摸事件是如何响应及传递的呢，通过本篇内容你将有一个初步的了解。

#### 实验环境
- OS X 10.9
- Eclipse(ADT)
- Android源码版本：API Level 19（Android 4.4）

<!--More-->

## Android事件构成
在Android中，事件主要包括点按、长按、拖拽、滑动等，点按又包括单击和双击，另外还包括单指操作和多指操作。所有这些都构成了Android中得事件响应。总的来说，所有的事件都由如下三个部分作为基础：

- 按下（ACTION_DOWN）
- 移动（ACTION_MOVE）
- 抬起（ACTION_UP）

所有的操作事件首先必须执行的是按下操作（ACTION_DOWN），之后所有的操作都是以按下操作作为前提，当按下操作完成后，接下来可能是一段移动（ACTION_MOVE）然后抬起（ACTION_UP），或者是按下操作执行完成后没有移动就直接抬起。这一系列的动作在Android中都可以进行控制。

我们知道，所有的事件操作都发生在触摸屏上，而在屏幕上与我们交互的就是各种各样的视图组件（View），在Android中，所有的视图都继承于View，另外通过各种布局组件（ViewGroup）来对View进行布局，ViewGroup也继承于View。所有的UI控件例如Button、TextView都是继承于View，而所有的布局控件例如RelativeLayout、容器控件例如ListView都是继承于ViewGroup。所以，我们的事件操作主要就是发生在View和ViewGroup之间，那么View和ViewGroup中主要有哪些方法来对这些事件进行响应呢？记住如下3个方法，我们通过查看View和ViewGroup的源码可以看到：

```java View.java
public boolean dispatchTouchEvent(MotionEvent event)
public boolean onTouchEvent(MotionEvent event) 
```

```java ViewGroup.java
public boolean dispatchTouchEvent(MotionEvent event)
public boolean onTouchEvent(MotionEvent event) 
public boolean onInterceptTouchEvent(MotionEvent ev)
```

在View和ViewGroup中都存在dispatchTouchEvent和onTouchEvent方法，但是在ViewGroup中还有一个onInterceptTouchEvent方法，那这些方法都是干嘛的呢？别急，我们先看看他们的返回值。这些方法的返回值全部都是```boolean```型，为什么是boolean型呢，看看本文的标题，“事件传递”，传递的过程就是一个接一个，那到了某一个点后是否要继续往下传递呢？你发现了吗，“是否”二字就决定了这些方法应该用boolean来作为返回值。没错，这些方法都返回true或者是false。在Android中，所有的事件都是从开始经过传递到完成事件的消费，这些方法的返回值就决定了某一事件是否是继续往下传，还是被拦截了，或是被消费了。

接下来就是这些方法的参数，都接受了一个```MotionEvent```类型的参数，MotionEvent继承于InputEvent，用于标记各种动作事件。之前提到的ACTION_DOWN、ACTION_MOVE、ACTION_UP都是MotinEvent中定义的常量。我们通过MotionEvent传进来的事件类型来判断接收的是哪一种类型的事件。到现在，这三个方法的返回值和参数你应该都明白了，接下来就解释一下这三个方法分别在什么时候处理事件。

- ```dispatchTouchEvent```方法用于事件的分发，Android中所有的事件都必须经过这个方法的分发，然后决定是自身消费当前事件还是继续往下分发给子控件处理。返回true表示不继续分发，事件没有被消费。返回false则继续往下分发，如果是ViewGroup则分发给onInterceptTouchEvent进行判断是否拦截该事件。
- ```onTouchEvent```方法用于事件的处理，返回true表示消费处理当前事件，返回false则不处理，交给子控件进行继续分发。
- ```onInterceptTouchEvent```是ViewGroup中才有的方法，View中没有，它的作用是负责事件的拦截，返回true的时候表示拦截当前事件，不继续往下分发，交给自身的onTouchEvent进行处理。返回false则不拦截，继续往下传。这是ViewGroup特有的方法，因为ViewGroup中可能还有子View，而在Android中View中是不能再包含子View的（iOS可以）。

到目前为止，Android中事件的构成以及事件处理方法的作用你应该比较清楚了，接下来我们就通过一个Demo来实际体验实验一下。

## Android事件处理
首先在Eclipse新建一个工程，并新建一个类RTButton继承Button，用来实现我们对按钮事件的跟踪。

```java RTButton.java
public class RTButton extends Button {
	public RTButton(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("RTButton---dispatchTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("RTButton---dispatchTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("RTButton---dispatchTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.dispatchTouchEvent(event);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("RTButton---onTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("RTButton---onTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("RTButton---onTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.onTouchEvent(event);
	}
}
```

在RTButton中我重写了dispatchTouchEvent和onTouchEvent方法，并获取了MotionEvent各个事件状态，打印输出了每一个状态下的信息。然后在activity_main.xml中直接在根布局下放入自定义的按钮RTButton。

```xml activity_main.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/myLayout"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >
    
    <com.ryantang.eventdispatchdemo.RTButton 
        android:id="@+id/btn"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Button"/>

</LinearLayout>
```

接下来在Activity中为RTButton设置onTouch和onClick的监听器来跟踪事件传递的过程，另外，Activity中也有一个dispatchTouchEvent方法和一个onTouchEvent方法，我们也重写他们并输出打印信息。

```java MainActivity.java
public class MainActivity extends Activity {
	private RTButton button;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		button = (RTButton)this.findViewById(R.id.btn);
		button.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					System.out.println("RTButton---onTouch---DOWN");
					break;
				case MotionEvent.ACTION_MOVE:
					System.out.println("RTButton---onTouch---MOVE");
					break;
				case MotionEvent.ACTION_UP:
					System.out.println("RTButton---onTouch---UP");
					break;
				default:
					break;
				}
				return false;
			}
		});
		
		button.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				System.out.println("RTButton clicked!");
			}
		});
		
	}

	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("Activity---dispatchTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("Activity---dispatchTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("Activity---dispatchTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.dispatchTouchEvent(event);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("Activity---onTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("Activity---onTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("Activity---onTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.onTouchEvent(event);
	}
}
```

代码部分已经完成了，接下来运行工程，并点击按钮，查看日志输出信息，我们可以看到如下结果：

![](/images/2013/12/android_event_dispatch/2.png)

通过日志输出可以看到，首先执行了Activity的dispatchTouchEvent方法进行事件分发，在```MainActivity.java```代码第55行，dispatchTouchEvent方法的返回值是super.dispatchTouchEvent(event)，因此调用了父类方法，我们进入```Activity.java```的源码中看看具体实现。


```java Activity.java
	/**
     * Called to process touch screen events.  You can override this to
     * intercept all touch screen events before they are dispatched to the
     * window.  Be sure to call this implementation for touch screen events
     * that should be handled normally.
     * 
     * @param ev The touch screen event.
     * 
     * @return boolean Return true if this event was consumed.
     */
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            onUserInteraction();
        }
        if (getWindow().superDispatchTouchEvent(ev)) {
            return true;
        }
        return onTouchEvent(ev);
    }
    
```

从源码中可以看到，dispatchTouchEvent方法只处理了ACTION_DOWN事件，前面提到过，所有的事件都是以按下为起点的，所以，Android认为当ACTION_DOWN事件没有执行时，后面的事件都是没有意义的，所以这里首先判断ACTION_DOWN事件。如果事件成立，则调用了onUserInteraction方法，该方法可以在Activity中被重写，在事件被分发前会调用该方法。该方法的返回值是void型，不会对事件传递结果造成影响，接着会判断getWindow().superDispatchTouchEvent(ev)的执行结果，看看它的源码：


```java Activity.java
    /**
     * Used by custom windows, such as Dialog, to pass the touch screen event
     * further down the view hierarchy. Application developers should
     * not need to implement or call this.
     *
     */
    public abstract boolean superDispatchTouchEvent(MotionEvent event);
```

通过源码注释我们可以了解到这是个抽象方法，用于自定义的Window，例如自定义Dialog传递触屏事件，并且提到开发者不需要去实现或调用该方法，系统会完成，如果我们在MainActivity中将dispatchTouchEvent方法的返回值设为true，那么这里的执行结果就为true，从而不会返回执行onTouchEvent(ev)，如果这里返回false，那么最终会返回执行onTouchEvent方法，由此可知，接下来要调用的就是onTouchEvent方法了。别急，通过日志输出信息可以看到，ACTION_DOWN事件从Activity被分发到了RTButton，接着执行了onTouch和onTouchEvent方法，为什么先执行onTouch方法呢？我们到RTButton中的dispatchTouchEvent看看View中的源码是如何处理的。

```java View.java
	/**
     * Pass the touch screen motion event down to the target view, or this
     * view if it is the target.
     *
     * @param event The motion event to be dispatched.
     * @return True if the event was handled by the view, false otherwise.
     */
    public boolean dispatchTouchEvent(MotionEvent event) {
        if (mInputEventConsistencyVerifier != null) {
            mInputEventConsistencyVerifier.onTouchEvent(event, 0);
        }

        if (onFilterTouchEventForSecurity(event)) {
            //noinspection SimplifiableIfStatement
            ListenerInfo li = mListenerInfo;
            if (li != null && li.mOnTouchListener != null && (mViewFlags & ENABLED_MASK) == ENABLED
                    && li.mOnTouchListener.onTouch(this, event)) {
                return true;
            }

            if (onTouchEvent(event)) {
                return true;
            }
        }

        if (mInputEventConsistencyVerifier != null) {
            mInputEventConsistencyVerifier.onUnhandledEvent(event, 0);
        }
        return false;
    }
```

挑选关键代码进行分析，可以看代码第16行，这里有几个条件，当几个条件都满足时该方法就返回true，当条件li.mOnTouchListener不为空时，通过在源码中查找，发现mOnTouchListener实在以下方法中进行设置的。

```java View.java
	/**
     * Register a callback to be invoked when a touch event is sent to this view.
     * @param l the touch listener to attach to this view
     */
    public void setOnTouchListener(OnTouchListener l) {
        getListenerInfo().mOnTouchListener = l;
    }
```

这个方法就已经很熟悉了，就是我们在```MainActivity.java```中为RTButton设置的onTouchListener，条件(mViewFlags & ENABLED_MASK) == ENABLED判断的是当前View是否是ENABLE的，默认都是ENABLE状态的。接着就是li.mOnTouchListener.onTouch(this, event)条件，这里调用了onTouch方法，该方法的调用就是我们在```MainActivity.java```中为RTButton设置的监听回调，如果该方法返回true，则整个条件都满足，dispatchTouchEvent就返回true，表示该事件就不继续向下分发了，因为已经被onTouch消费了。

如果onTouch返回的是false，则这个判断条件不成立，接着执行onTouchEvent(event)方法进行判断，如果该方法返回true，表示事件被onTouchEvent处理了，则整个dispatchTouchEvent就返回true。到这里，我们就可以回答之前提出的“为什么先执行onTouch方法”的问题了。到目前为止，ACTION_DOWN的事件经过了从Activity到RTButton的分发，然后经过onTouch和onTouchEvent的处理，最终，ACTION_DOWN事件交给了RTButton得onTouchEvent进行处理。

当我们的手（我这里用的Genymotion然后用鼠标进行的操作，用手的话可能会执行一些ACTION_MOVE操作）从屏幕抬起时，会发生ACTION_UP事件。从之前输出的日志信心中可以看到，ACTION_UP事件同样从Activity开始到RTButton进行分发和处理，最后，由于我们注册了onClick事件，当onTouchEvent执行完毕后，就调用了onClick事件，那么onClick是在哪里被调用的呢？继续回到```View.java```的源代码中寻找。由于onTouchEvent在```View.java```中的源码比较长，这里就不贴出来了，感兴趣的可以自己去研究一下，通过源码阅读，我们在ACTION_UP的处理分支中可以看到一个```performClick()```方法，从这个方法的源码中可以看到执行了哪些操作。


```java View.java
	/**
     * Call this view's OnClickListener, if it is defined.  Performs all normal
     * actions associated with clicking: reporting accessibility event, playing
     * a sound, etc.
     *
     * @return True there was an assigned OnClickListener that was called, false
     *         otherwise is returned.
     */
    public boolean performClick() {
        sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_CLICKED);

        ListenerInfo li = mListenerInfo;
        if (li != null && li.mOnClickListener != null) {
            playSoundEffect(SoundEffectConstants.CLICK);
            li.mOnClickListener.onClick(this);
            return true;
        }

        return false;
    }
```

在if分支里可以看到执行了li.mOnClickListener.onClick(this);这句代码，这里就执行了我们为RTButton实现的onClick方法，所以，到目前为止，可以回答前一个“onClick是在哪里被调用的呢？”的问题了，onClick是在onTouchEvent中被执行的，并且，onClick要后于onTouch的执行。

到此，点击按钮的事件传递就结束了，我们结合源代码窥探了其中的执行细节，如果我们修改各个事件控制方法的返回值又会发生什么情况呢，带着这个问题，进入下一节的讨论。

## Android事件拦截
从上一节分析中，我们知道了在Android中存在哪些事件类型，事件的传递过程以及在源码中对应哪些处理方法。我们可以知道在Android中，事件是通过层级传递的，一次事件传递对应一个完整的层级关系，例如上节中分析的ACTION_DOWN事件从Activity传递到RTButton，ACTION_UP事件也同样。结合源码分析各个事件处理的方法，也可以明确看到事件的处理流程。

之前提过，所有事件处理方法的返回值都是boolean类型的，现在我们来修改这个返回值，首先从Aactivity开始，根据之前的日志输出结果，首先执行的是Activity的dispatchTouchEvent方法，现在将之前的返回值super.dispatchTouchEvent(event)修改为true，然后重新编译运行并点击按钮，看到如下的日志输出结果。

![](/images/2013/12/android_event_dispatch/1.png)

可以看到，事件执行到dispatchTouchEvent方法就没有再继续往下分发了，这也验证了之前的说法，返回true时，不再继续往下分发，从之前分析过的Activity的dispatchTouchEvent源码中也可知，当返回true时，就没有去执行onTouchEvent方法了。

接着，将上述修改还原，让事件在Activity这继续往下分发，接着就分发到了RTButton，将RTButton的dispatchTouchEvent方法的返回值修改为true，重新编译运行并查看输出日志结果。

![](/images/2013/12/android_event_dispatch/3.png)

从结果可以看到，事件在RTButton的dispatchTouchEvent方法中就没有再继续往下分发了。接着将上述修改还原，将RTButton的onTouchEvent方法返回值修改为true，让其消费事件，根据之前的分析，onClick方法是在onTouchEvent方法中被调用的，事件在这被消费后将不会调用onClick方法了，编译运行，得到如下日志输出结果。

![](/images/2013/12/android_event_dispatch/4.png)

跟分析结果一样，onClick方法并没有被执行，因为事件在RTButton的onTouchEvent方法中被消费了。下图是整个事件传递的流程图。

![](/images/2013/12/android_event_dispatch/7.png)

到目前为止，Android中的事件拦截机制就分析完了。但这里我们只讨论了单布局结构下单控件的情况，如果是嵌套布局，那情况又是怎样的呢？接下来我们就在嵌套布局的情况下对Android的事件传递机制进行进一步的探究和分析。

## Android嵌套布局事件传递
首先，新建一个类RTLayout继承于LinearLayout，同样重写dispatchTouchEvent和onTouchEvent方法，另外，还需要重写onInterceptTouchEvent方法，在文章开头介绍过，这个方法只有在ViewGroup和其子类中才存在，作用是控制是否需要拦截事件。这里不要和dispatchTouchEvent弄混淆了，后者是控制对事件的分发，并且后者要先执行。

那么，事件是先传递到View呢，还是先传递到ViewGroup的？通过下面的分析我们可以得出结论。首先，我们需要对工程代码进行一些修改。

```java RTLayout.java
public class RTLayout extends LinearLayout {
	public RTLayout(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("RTLayout---dispatchTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("RTLayout---dispatchTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("RTLayout---dispatchTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.dispatchTouchEvent(event);
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("RTLayout---onInterceptTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("RTLayout---onInterceptTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("RTLayout---onInterceptTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.onInterceptTouchEvent(event);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			System.out.println("RTLayout---onTouchEvent---DOWN");
			break;
		case MotionEvent.ACTION_MOVE:
			System.out.println("RTLayout---onTouchEvent---MOVE");
			break;
		case MotionEvent.ACTION_UP:
			System.out.println("RTLayout---onTouchEvent---UP");
			break;
		default:
			break;
		}
		return super.onTouchEvent(event);
	}
}
```

同时，在布局文件中为RTButton添加一个父布局，指明为自定义的RTLayout，修改后的布局文件如下。

```xml activity_main.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >

    <com.ryantang.eventdispatchdemo.RTLayout
        android:id="@+id/myLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent" >

        <com.ryantang.eventdispatchdemo.RTButton
            android:id="@+id/btn"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Button" />
    </com.ryantang.eventdispatchdemo.RTLayout>

</LinearLayout>
```

最后，我们在Activity中也为RTLayout设置onTouch和onClick事件，在MainActivity中添加如下代码。

```java MainActivity.java
	rtLayout.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					System.out.println("RTLayout---onTouch---DOWN");
					break;
				case MotionEvent.ACTION_MOVE:
					System.out.println("RTLayout---onTouch---MOVE");
					break;
				case MotionEvent.ACTION_UP:
					System.out.println("RTLayout---onTouch---UP");
					break;
				default:
					break;
				}
				return false;
			}
		});
		
	rtLayout.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				System.out.println("RTLayout clicked!");
			}
		});
```

代码修改完毕后，编译运行工程，同样，点击按钮，查看日志输出结果如下：

![](/images/2013/12/android_event_dispatch/5.png)

从日志输出结果我们可以看到，嵌套了RTLayout以后，事件传递的顺序变成了Activity->RTLayout->RTButton，这也就回答了前面提出的问题，Android中事件传递是从ViewGroup传递到View的，而不是反过来传递的。

从输出结果第三行可以看到，执行了RTLayout的onInterceptTouchEvent方法，该方法的作用就是判断是否需要拦截事件，我们到ViewGroup的源码中看看该方法的实现。

```java ViewGroup.java
public boolean onInterceptTouchEvent(MotionEvent ev) {
        return false;
    }
```

该方法的实现很简单，只返回了一个false。那么这个方法是在哪被调用的呢，通过日志输出分析可知它是在RTLayout的dispatchTouchEvent执行后执行的，那我们就进到dispatchTouchEvent源码里面去看看。由于源码比较长，我将其中的关键部分截取出来做解释说明。


```java ViewGroup.java
// Check for interception.
final boolean intercepted;
            if (actionMasked == MotionEvent.ACTION_DOWN
                    || mFirstTouchTarget != null) {
                final boolean disallowIntercept = (mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0;
                if (!disallowIntercept) {
                    intercepted = onInterceptTouchEvent(ev);
                    ev.setAction(action); // restore action in case it was changed
                } else {
                    intercepted = false;
                }
            } else {
                // There are no touch targets and this action is not an initial down
                // so this view group continues to intercept touches.
                intercepted = true;
            }
```

从这部分代码中可以看到onInterceptTouchEvent调用后返回值被赋值给intercepted，该变量控制了事件是否要向其子控件分发，所以它起到拦截的作用，如果onInterceptTouchEvent返回false则不拦截，如果返回true则拦截当前事件。我们现在将RTLayout中的该方法返回值修改为true，并重新编译运行，然后点击按钮，查看输出结果如下。

![](/images/2013/12/android_event_dispatch/6.png)

可以看到，我们明明点击的按钮，但输出结果显示RTLayout点击事件被执行了，再通过输出结果分析，对比上次的输出结果，发现本次的输出结果完全没有RTButton的信息，没错，由于onInterceptTouchEvent方法我们返回了true，在这里就将事件拦截了，所以他不会继续分发给RTButton了，反而交给自身的onTouchEvent方法执行了，理所当然，最后执行的就是RTLayout的点击事件了。

## 总结
以上我们对Android事件传递机制进行了分析，期间结合系统源码对事件传递过程中的处理情况进行了探究。通过单布局情况和嵌套布局情况下的事件传递和处理进行了分析，现总结如下：

- Android中事件传递按照从上到下进行层级传递，事件处理从Activity开始到ViewGroup再到View。
- 事件传递方法包括```dispatchTouchEvent```、```onTouchEvent```、```onInterceptTouchEvent```，其中前两个是View和ViewGroup都有的，最后一个是只有ViewGroup才有的方法。这三个方法的作用分别是负责事件分发、事件处理、事件拦截。
- onTouch事件要先于onClick事件执行，onTouch在事件分发方法dispatchTouchEvent中调用，而onClick在事件处理方法onTouchEvent中被调用，onTouchEvent要后于dispatchTouchEvent方法的调用。


>后记：本文结合Android系统源码对事件传递机制进行了深入剖析，结合实例分析了事件传递和处理过程。不足之处还望指正。

