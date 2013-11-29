---
layout: post
title: "Android推送服务——百度云推送"
date: 2013-08-06 15:59
comments: true
keywords: 百度云推送, Android
description: 
publish: false
categories: Android
---
本文已授权InfoQ进行转载：[http://www.infoq.com/cn/articles/baidu-android-cloud-push](http://www.infoq.com/cn/articles/baidu-android-cloud-push)

> 身在天朝，置身墙内<br>
> 或是自给，或是出走

## 一、推送服务简介
消息推送，顾名思义，是由一方主动发起，而另一方与发起方以某一种方式建立连接并接收消息。在Android开发中，这里的发起方我们把它叫做```推送服务器（Push Server）```，接收方叫做```客户端（Client）```。相比通过轮询来获取新消息或通知，推送无论是在对客户端的资源消耗还是设备耗电量来说都比轮询要好，所以，目前绝大多数需要及时消息推送的App都采用Push的方式来进行消息通知。

![push](/images/2013/08/baidu_push_service/1.jpg)

<!--more-->

身在天朝，置身墙内！Android生态系统原本提供了类似于Apple iOS推送服务```APNS```的```GCM(Google Cloud Messaging for Android)```，以前叫```C2DM```,但是由于某些原因，导致这项服务在国内不是很好使，为了弥补这个不足，并且我朝各大同胞又想使用Android推送服务，所以国内各大平台陆续推出了```GCM```的替代品，今天要介绍的就是其中一家，由百度提供的云推送。另外，国内做消息推送服务的还有极光推送和个推等，他们的客户包括新浪微博、淘宝等国内一线大公司。

推送的实现技术简单来说就是利用Socket维持Client和Server间的一个TCP长连接，通过这种方式能大大降低由轮询方式带来的Device的耗电量和数据访问流量。目前，百度云推送提供的推送服务支持的单一消息体大小是4k，如果超过4k，则建议在消息内携带服务请求URL进行二次请求。目前，百度云推送针对Android端提供通知推送，文本消息推送以及富媒体推送。

## 二、使用场景
#### 1. 单播消息推送
Push Server向指定的设备（Device）或是用户（User）推送消息，一个用户对应一个```userID```，一个User可能拥有多台Device，我们希望向同一个userID推送消息时，他所有绑定了userID的Device都能收到消息。百度云推送给出的解决方案是通过Client向Push Server注册，并在Client端的监听端口取得Push Server返回的	```channelID```和```userID```，```channelID```指定一个终端，在向Push Server注册的过程中，Device可以发送IMIE码或者UUID作为唯一标示，在Push Server注册后再返回给Client生成的```channelID```和```userID```。这两个ID获取到后由开发者自行维护，注册完毕后，Push Server维护一个注册设备列表，这个列表维护了```userID```和```channelID```以及与Device对应的关系，当需要向指定的设备或用户推送消息时，Push Server会首先遍历这个设备列表，通过这两个ID来做唯一性判断并找到需要推送消息的Device，然后就可以进行消息推送了。

![push](/images/2013/08/baidu_push_service/2.jpg)

实例：用户A发表问题时，记录问题id及其对应的A的userID（或channelID），用户B发表问题回答时，通过服务端API向问题id对应的userID（或channelID）指向的Device推送答案。

#### 2. 分组消息推送
百度云推送通过对Client设置标签（Tag）的方式来进行用户分组，Tag的产生方式可以是由Client维护也可以由Server收集，Push Server针对不同的Tag进行推送过滤，最终将消息推送到指定的Client。无论是由Client主动设置的Tag还是由Server根据用户使用习惯收集的，都由Push Server进行统一管理，在基于Tag的分组消息推送实现上，Push Server首先根据指定Tag从所有Tag下遍历出的对应的已注册的Device，从而可以获得与Device对应的```userID```和```channelID```，继而可以针对指定Tag进行分组消息推送。对比单播消息推送，分组消息推送在推送周期上势必要长一些，并且在待推消息列表的维护上也需要做一些处理，哪些消息是推送成功的，哪些是失败的，这需要接收消息推送的Client在接收到消息后给Push Server一个消息回执，这样就保证了消息送达的准确性，如果消息推送失败，则分组列表里的待推消息会继续推送，直到推送消息成功。另外，在消息推送的实时性上，分组消息推送对比单播消息推送会根据分组消息队列的先后存在一个消息接收的延时，好比现在微信公众账号的推送，就是一个分组消息推送的实例，在消息接收的时效性上对比单播推送存在一定的延时性。

另外，还有一类消息推送使用场景，就是广播消息，该类型可以理解为分组消息的一个特列，即向所有的Tag对应的Client推送消息。广播消息是对全体集合的一个消息推送，在消息队列维护和消息推送时效性上比单个或几个Tag的分组推送成本要高。

实例：给应用提供喜好设置页面，用户勾选不同的类别，触发对应Tag的设置，这种方式是由Client主动维护Tag。或者用户阅读了某个类别的图书，触发对应Tag的设置，在服务端，给指定类别的图书设置Tag，后续会根据服务端收集的Tag给应用推送该Tag下的新书信息，这种方式就是由服务端来维护Tag分组。

## 三、百度云推送Android_SDK
百度提供了完整的Demo帮助开发者集成云推送服务，推送服务SDK通过.jar包和.so文件的方式可以集成到我们自己的工程中。在此之前，需要到百度开发者中心进行应用注册并获取```API Key```，这个作为使用推送服务应用的唯一标示，具体流程我就不赘述了，需要使用的话可以直接访问```百度开发者中心```进行查看。

下面主要看看Android_SDK的整体概览和内部运行机制：

![structure](/images/2013/07/baidu_push_service/1.png)

上图是百度云推送Android_SDK的框架图，通过SDK可以绕过复杂的Push HTTP/HTTPS API直接和Push服务器进行交互，主要提供如下功能：

- Push服务初始化以及Client注册绑定
- 创建或删除标签（Tag）
- 接收Push Server的通知并提供自定义展现消息方式
- 推送统计分析功能，包括通知的点击和删除统计以及应用使用情况统计
- 富媒体推送

在Android端，总共实现了三个Receiver和一个Service，其中，一个Receiver是用来处理注册绑定后接收服务端返回的channelID等信息：

```xml
<receiver android:name="com.baidu.android.pushservice.RegistrationReceiver"android:process=": bdservice_v1"><intent-filter><action android:name="com.baidu.android.pushservice.action.METHOD " /><action android:name="com.baidu.android.pushservice.action.BIND_SYNC " /> 
</intent-filter><intent-filter><action android:name="android.intent.action.PACKAGE_REMOVED"/> <data android:scheme="package" /></intent-filter> 
</receiver>
```

第二个Receiver是用于接收系统消息以保证PushService正常运行：

```xml
<receiver android:name="com.baidu.android.pushservice.PushServiceReceiver" android:process=": bdservice_v1"><intent-filter><action android:name="android.intent.action.BOOT_COMPLETED" /><action android:name="android.net.conn.CONNECTIVITY_CHANGE" /><action android:name="com.baidu.android.pushservice.action.notification.SHOW" /> <action android:name="com.baidu.android.pushservice.action.media.CLICK" /></intent-filter></receiver>
```

第三个Receiver就是开发者自己实现的用来接收并处理推送消息：

```xml
<receiver android:name="your.package.PushMessageReceiver"> <intent-filter><!-- 接收 push 消息 --><action android:name="com.baidu.android.pushservice.action.MESSAGE" /><!-- 接收 bind、setTags 等 method 的返回结果 --><action android:name="com.baidu.android.pushservice.action.RECEIVE" /></intent-filter> 
</receiver>
```

一个Service就是在后台运行的用于保障与Push Server维持长连接并做相关处理的后台服务：

```xml
<service android:name="com.baidu.android.pushservice.PushService"android:exported="true" android:process=" bdservice_v1"/> <!-- push service end -->
```
在开发者自己需要处理的广播接收器中，可以对接收到的推送消息进行处理，Push消息通过 action为com.baidu.android.pushservice.action.MESSAGE的Intent把数据发送给客户端your.package.PushMessageReceiver，消息格式由应用自己决定，PushService只负责把服务器下发的消息以字符串格式透传给客户端。接口调用回调通过action为com.baidu.android.pushservice.action.RECEIVE的Intent 返回给your.package.PushMessageReceiver。


```java PushMessageReceiver.java
/**
 * Push消息处理receiver
 * @Author Ryan
 * @Create 2013-8-6 下午5:59:38
 */
public class PushMessageReceiver extends BroadcastReceiver {
	public static final String TAG = PushMessageReceiver.class.getSimpleName();

	@Override
	public void onReceive(final Context context, Intent intent) {

		if (intent.getAction().equals(PushConstants.ACTION_MESSAGE)) {
			//获取消息内容
			String message = intent.getExtras().getString(
					PushConstants.EXTRA_PUSH_MESSAGE_STRING);
			//消息的用户自定义内容读取方式
			Log.i(TAG, "onMessage: " + message);

		} else if (intent.getAction().equals(PushConstants.ACTION_RECEIVE)) {
			//处理绑定等方法的返回数据
			//PushManager.startWork()的返回值通过PushConstants.METHOD_BIND得到
			
			//获取方法
			final String method = intent
					.getStringExtra(PushConstants.EXTRA_METHOD);
			//方法返回错误码。若绑定返回错误（非0），则应用将不能正常接收消息。
			//绑定失败的原因有多种，如网络原因，或access token过期。
			//请不要在出错时进行简单的startWork调用，这有可能导致死循环。
			//可以通过限制重试次数，或者在其他时机重新调用来解决。
			final int errorCode = intent
					.getIntExtra(PushConstants.EXTRA_ERROR_CODE,
							PushConstants.ERROR_SUCCESS);
			//返回内容
			final String content = new String(
					intent.getByteArrayExtra(PushConstants.EXTRA_CONTENT));
			
			//用户在此自定义处理消息,以下代码为demo界面展示用	
			Log.d(TAG, "onMessage: method : " + method);
			Log.d(TAG, "onMessage: result : " + errorCode);
			Log.d(TAG, "onMessage: content : " + content);
			
		} 
	}

}
```

通过在入口Activity的onCreate方法中进行推送服务的注册绑定后，即可在推送管理后台或是自己的应用服务器上进行消息推送的操作了。

```java
PushManager.startWork(getApplicationContext(),PushConstants.LOGIN_TYPE_API_KEY, "you_api_key");
```

另外，云推送提供php、java等Server端的SDK供开发者在自己的服务器上实现推送服务进行定制化管理和操作。

## 四、单服务单通道机制
百度云推送实现了单服务单通道的机制，如果在一台Device上安装了多款Push SDK的应用，不会为每个应用都创建PushService，而是会采用多应用共享一个PushService的模式。这样既能减少资源消耗也能降低网络流量。PushService运行于一个独立进程，没有和主进程运行于同一进程，所以主进程不需要常驻内存，当有新的Push消息时，PushService会通过Intent发送消息给主进程进行处理。通过Intent，以指定目标应用包名的方式，发送私有消息给应用。应用即不能接收不属于自己的消息，也不能截取别人的消息，同时又降低了消耗，如下为示意图：

![structure](/images/2013/07/baidu_push_service/2.png)

> 后记：如今，国内提供Android推送服务的还有很多家，例如个推和极光推送等，实现的原理大同小异，开发者可以根据自身需要进行选择。身在天朝，置身墙内，用不到GCM，就创造Android Push Service for China自给，或者，出走！ 
