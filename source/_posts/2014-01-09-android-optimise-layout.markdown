---
layout: post
title: "Android布局优化"
date: 2014-01-24 20:42:44 +0800
comments: true
categories: Android
---

###### 本文为InfoQ中文站特供稿件，首发地址为：[http://www.infoq.com/cn/articles/android-optimise-layout](http://www.infoq.com/cn/articles/android-optimise-layout)。如需转载，请与InfoQ中文站联系。

![](/images/2014/01/android_optimise_layout/0.png)

在Android开发中，我们常用的布局方式主要有LinearLayout、RelativeLayout、FrameLayout等，通过这些布局我们可以实现各种各样的界面。与此同时，如何正确、高效的使用这些布局方式来组织UI控件，是我们构建优秀Android App的主要前提之一。本篇内容就主要围绕Android布局优化来讨论在日常开发中我们使用常用布局需要注意的一些方面，同时介绍一款SDK自带的UI性能检测工具HierarchyViewer。

<!--More-->

## 布局原则
通过一些惯用、有效的布局原则，我们可以制作出加载效率高并且复用性高的UI。简单来说，在Android UI布局过程中，需要遵守的原则包括如下几点：

- 尽量多使用RelativeLayout，不要使用绝对布局AbsoluteLayout；
- 将可复用的组件抽取出来并通过< include />标签使用；
- 使用< ViewStub />标签来加载一些不常用的布局；
- 使用< merge />标签减少布局的嵌套层次；

由于Android的碎片化程度很高，市面上存在的屏幕尺寸也是各式各样，使用RelativeLayout能使我们构建的布局适应性更强，构建出来的UI布局对多屏幕的适配效果越好，通过指定UI控件间的相对位置，使在不同屏幕上布局的表现能基本保持一致。当然，也不是所有情况下都得使用相对布局，根据具体情况来选择和其他布局方式的搭配来实现最优布局。

####  1、< include />的使用
在实际开发中，我们经常会遇到一些共用的UI组件，比如带返回按钮的导航栏，如果为每一个xml文件都设置这部分布局，一是重复的工作量大，二是如果有变更，那么每一个xml文件都得修改。还好，Android为我们提供了< include />标签，顾名思义，通过它，我们可以将这些共用的组件抽取出来单独放到一个xml文件中，然后使用< include />标签导入共用布局，这样，前面提到的两个问题都解决了。例如上面提到的例子，新建一个xml布局文件作为顶部导航的共用布局。


```xml common_navitationbar.xml

<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@android:color/white"
    android:padding="10dip" >

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentLeft="true"
        android:text="Back"
        android:textColor="@android:color/black" />
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        android:text="Title"
        android:textColor="@android:color/black" />

</RelativeLayout>

```

然后我们在需要引入导航栏的布局xml中通过< include />导入这个共用布局。


```xml main.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >
    
    <include 
        android:layout_alignParentTop="true"
        layout="@layout/common_navitationbar" />
    
</RelativeLayout>
```

通过这种方式，我们既能提高UI的制作和复用效率，也能保证制作的UI布局更加规整和易维护。布局完成后我们运行一下，可以看到如下布局效果，这就是我们刚才完成的带导航栏的界面。

![](/images/2014/01/android_optimise_layout/1.png)

接着我们进入sdk目录下的tools文件夹下，找到HierarchyViewer并运行（此时保持你的模拟器或真机正在运行需要进行分析的App），双击我们正在显示的这个App所代表的进程。

![](/images/2014/01/android_optimise_layout/3.png)

接下来便会进入hierarchyviewer的界面，我们可以在这里很清晰看到正在运行的UI的布局层次结构以及它们之间的关系。

![](/images/2014/01/android_optimise_layout/4.png)

分析刚刚我们构建的导航栏布局，放大布局分析图可以看到，被include进来的common_navitationbar.xml根节点是一个RelativeLayout，而包含它的主界面main.xml根节点也是一个RelativeLayout，它前面还有一个FrameLayout等几个节点，FrameLayout就是Activity布局中默认的父布局节点，再往上是一个LinearLayout，这个LinearLayout就是包含Activity布局和状态栏的整个屏幕显示的布局父节点，这个LinearLayout还有一个子节点就是ViewStub，关于这个节点我们在后面会详细介绍。

![](/images/2014/01/android_optimise_layout/2.png)

#### 2、< merge />的使用

<merge>标签的作用是合并UI布局，使用该标签能降低UI布局的嵌套层次。该标签的主要使用场景主要包括两个，第一是当xml文件的根布局是FrameLayout时，可以用merge作为根节点。理由是因为Activity的内容布局中，默认就用了一个FrameLayout作为xml布局根节点的父节点，这一点可以从上图中看到，main.xml的根节点是一个RelativeLayout，其父节点就是一个FrameLayout，如果我们在main.xml里面使用FrameLayout作为根节点的话，这时就可以使用merge来合并成一个FrameLayout，这样就降低了布局嵌套层次。

我们修改一下main.xml的内容，将根节点修改为merge标签。


```xml main.xml

<merge xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:background="@android:color/darker_gray"
    android:layout_height="match_parent" >
    
    <include layout="@layout/common_navitationbar" />
    
</merge>

```

重新运行并打开HierarchyViewer查看此时的布局层次结构，发现之前多出来的一个RelativeLayout就没有了，直接将common_navigationbar.xml里面的内容合并到了main.xml里面。

![](/images/2014/01/android_optimise_layout/5.png)

使用< merge />的第二种情况是当用include标签导入一个共用布局时，如果父布局和子布局根节点为同一类型，可以使用merge将子节点布局的内容合并包含到父布局中，这样就可以减少一级嵌套层次。首先我们看看不使用merge的情况。我们新建一个布局文件common_navi_right.xml用来构建一个在导航栏右边的按钮布局。


```xml common_navi_right.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content" >

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentRight="true"
        android:text="Ok"
        android:textColor="@android:color/black" />
    
</RelativeLayout>
```

然后修改common_navitationbar.xml的内容，添加一个include，将右侧按钮的布局导入：

```xml common_navitationbar.xml

<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@android:color/white"
    android:padding="10dip" >

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentLeft="true"
        android:text="Back"
        android:textColor="@android:color/black" />
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        android:text="Title"
        android:textColor="@android:color/black" />
        
    <include layout="@layout/common_center" />

</RelativeLayout>

```

运行后的效果如下图，在导航栏右侧添加了一个按钮“ok”

![](/images/2014/01/android_optimise_layout/6.png)

然后再运行HierarchyViewer看看现在的布局结构，发现common_navi_right.xml作为一个布局子节点嵌套在了common_navitationbar.xml下面。

![](/images/2014/01/android_optimise_layout/7.png)

这时我们再将common_navi_right.xml的根节点类型改为merge。

```xml common_navi_right.xml
<merge xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content" >

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentRight="true"
        android:text="Ok"
        android:textColor="@android:color/black" />
    
</merge>
```

重新运行并打开HierarchyViewer查看布局结构，发现之前嵌套的一个RelativeLayout就没有了，这就是使用merge的效果，能降低布局的嵌套层次。

![](/images/2014/01/android_optimise_layout/8.png)

#### 3、< ViewStub />的使用
也许有不少同学对ViewStub还比较陌生，首先来看看ViewStub在官方文档里是怎么介绍的：

A ViewStub is an invisible, zero-sized View that can be used to lazily inflate layout resources at runtime. When a ViewStub is made visible, or when inflate() is invoked, the layout resource is inflated. The ViewStub then replaces itself in its parent with the inflated View or Views. Therefore, the ViewStub exists in the view hierarchy until setVisibility(int) or inflate() is invoked. The inflated View is added to the ViewStub's parent with the ViewStub's layout parameters.

大致意思是：ViewStub是一个不可见的，能在运行期间延迟加载的大小为0的View，它直接继承于View。当对一个ViewStub调用inflate()方法或设置它可见时，系统会加载在ViewStub标签中引入的我们自己定义的View，然后填充在父布局当中。也就是说，在对ViewStub调用inflate()方法或设置visible之前，它是不占用布局空间和系统资源的。它的使用场景可以是在我们需要加载并显示一些不常用的View时，例如一些网络异常的提示信息等。

我们新建一个xml文件用来显示一个提示信息：

```xml common_msg.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content" >

   <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        android:background="@android:color/white"
        android:padding="10dip"
        android:text="Message"
        android:textColor="@android:color/black" />
    
</RelativeLayout>
```

然后在main.xml里面加入ViewStub的标签引入上面的布局：

```xml main.xml
<merge xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:background="@android:color/darker_gray"
    android:layout_height="match_parent" >
    
    <include layout="@layout/common_navitationbar" />
    
    <ViewStub
        android:id="@+id/msg_layout"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:layout="@layout/common_msg" />
    
</merge>
```

修改MainActivity.java的代码，我们这里设置为点击右上角按钮的时候显示自定义的common_msg.xml的内容。

```java MainActivity.java
public class MainActivity extends Activity {

	private View msgView;
	private boolean flag = true;
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        this.findViewById(R.id.rightButton).setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				System.out.print("111");
				if(flag){
					showMsgView();
				}else{
					closeMsgView();
				}
				flag = !flag;
			}
		});
    }
    
    private void showMsgView(){
    	if(msgView != null){
    		msgView.setVisibility(View.VISIBLE);
    		return;
    	}
    	ViewStub stub = (ViewStub)findViewById(R.id.msg_layout);
        msgView = stub.inflate();
    }
    
    private void closeMsgView(){
    	if(msgView != null){
    		msgView.setVisibility(View.GONE);
    	}
    }
}
```

代码中我们通过flag来切换显示和隐藏common_msg.xml的内容，然后我们运行一下并点击右上角按钮来切换，效果如下：

![](/images/2014/01/android_optimise_layout/9.png)

## 总结
好了，到目前为止，我们就介绍了Android中关于布局优化的一些内容以及工具HierarchyViewer的使用。将前文提及的布局原则再列一下，欢迎大家补充更多的关于Android布局优化的实用原则。

- 尽量多使用RelativeLayout，不要使用绝对布局AbsoluteLayout；
- 将可复用的组件抽取出来并通过< include />标签使用；
- 使用< ViewStub />标签来加载一些不常用的布局；
- 使用< merge />标签减少布局的嵌套层次；


