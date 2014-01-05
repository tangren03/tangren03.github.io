---
layout: post
title: "使用GoAgent翻墙"
date: 2013-11-30 14:17:16 +0800
comments: true
keywords: GoAgent，翻墙
categories: Tools
---
> 天朝上国，长城伟岸<br>
> 茫茫世界，何止一墙

互联网本是个开放的世界，互联网的本质就是开放、交流和分享，无奈身在天朝，一堵伟岸的墙将我们与一些美好的事物隔离开来。有压迫的地方就总有反抗，有技术的地方就总有解决方法。虽然我们置身墙内，但还是有方法绕过这道墙去领略外面的世界，也就是我们俗称的翻墙。现在的翻墙方法有很多，网上也有一些翻墙工具下载，但大多不稳定，稳定的就要收费。既然我们是搞技术的，那就用技术手段来翻墙吧。本次要介绍的就是使用GoAgent来实现翻墙。以下操作均在Mac OS X 10.9上完成,Windows用户操作基本类似。

<!--More-->

## GoAgent是什么
GoAgent是使用Python编写的网络软件，可以运行在Windows/Mac/Linux/Android/iTouch/iPhone/iPad/webOS/OpenWRT/Maemo上

## 使用GoAgent有什么好处
简单来说，使用GoAgent翻墙最大的好处就是稳定，不会像一些翻墙软件一样出现时常掉线的情况。俗话说，好不好，只有自己用了才知道！

## 如何使用GoAgent
### 一、申请Google App Engine
Google App Engine是一个网络服务挂载，我们可以将自己的服务挂载在上面，首先，我们进入[Google App Engine](https://appengine.google.com/)，如果你有gmail账户，则直接登录即可，登录成功后我们新建一个Application

![1](/images/2013/11/goagent/1.png)

新建成功后就可以看到如下信息

![2](/images/2013/11/goagent/2.png)

进入Application列表我们就可以看到刚才创建的应用了。Application一列显示的就是App ID，最后一列显示了当前应用的状态，由于这是一个新应用，所以状态为None-Deployed。到这里，Google App Engine我们就配置好了。

### 二、安装配置GoAgent
进入[GoAgent官网](https://code.google.com/p/goagent/)下载GoAgent压缩包，并解压到用户根目录下，进入GoAgent/local目录，找到proxy.ini文件并用编辑器打开。

![1](/images/2013/11/goagent/3.png)

打开proxy.ini后找到appid一栏，将默认的值修改成之前注册的Google App Engine的App ID，然后保存。

![1](/images/2013/11/goagent/4.png)

接下来用命令行进入GoAgent目录下的server文件夹，然后运行python uploader.zip命令将我们的应用上传到Google App Engine。

```xml
cd GoAgent/server
python uploader.zip
```
命令执行后，会要求我们输入APPID，输入我们在Google App Engine创建的App ID。

![1](/images/2013/11/goagent/5.png)

输入完AppID后回车，接着会要我们输入Emial，此处输入你的Gmail邮箱地址，接下来就是输入密码。输入密码这里需要注意，如果你的Gmail开启了```两步验证```，那么你需要到Google账户设置-安全性-两步验证里去获取临时密码，如果你没有设置两步验证，那这里的密码就输入你的Gmial邮箱密码。

![1](/images/2013/11/goagent/6.png)

点击“管理您的应用专用密码”进入下面界面

![1](/images/2013/11/goagent/7.png)

在输入框中输入描述点击生成密码就会跳转到另外的界面，同时会看到为你生成的密码，将这个密码输入到前面的密码输入中（不要带空格），最后回车，就开始上传了。上传工程后你会看到Complete update...等信息。

接下来命令行进入/GoAgent/local目录，运行python proxy.py命令，就开启GoAgent服务了。

```xml
cd GoAgent/local
python proxy.py
```
如果运行上述命令后你看到有WARNING信息输出，提示权限问题，这时可以找到GoAgent/local目录下CA.cer文件，双击安装这个证书，在钥匙串中就可以看到这个证书了，双击打开，并且修改权限为总是信任，重启命令窗口再运行上述命令就可以了。

![1](/images/2013/11/goagent/8.png)

### 三、设置浏览器代理插件
Chrome可以安装这个插件[SwitchySharp](https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm)，然后下载并在SwitchySharp设置中导入已经配置好的文件[SwitchyOptions.bak](https://code.google.com/p/wwqgtxx-GoAgent/downloads/detail?name=SwitchyOptions.bak&can=2&q=)

![1](/images/2013/11/goagent/9.png)

导入成功后就可以看到配置信息了

![1](/images/2013/11/goagent/10.png)

FirFox可以安装[FoxyProxy](https://addons.mozilla.org/zh-cn/firefox/addon/foxyproxy-standard/)插件。到这里，所有的安装和设置我们都已经完成了，接下来我们就看看如何使用GoAgent来进行翻墙。

#### 四、平时使用GoAgent翻墙
1、打开命令行窗口，运行下列命令开启GoAgent服务

```xml
cd GoAgent/local
python proxy.py
```
2、打开Chrome浏览器，将地址栏右侧的蓝色地球点开，选择代理为GoAgent

![1](/images/2013/11/goagent/11.png)

好了，输入youtube.com，尽情去享受墙外的世界吧！

![1](/images/2013/11/goagent/12.png)

![1](/images/2013/11/goagent/13.png)

3、不用的时候切换代理然后关闭命令行窗口即可，需要注意的是，一个Google App Engine上得Application一天只提供1G的流量限制，但是，我们可以最多申请10个Application，如果1G不够用，你可以多申请几个，然后在之前提到的proxy.ini文件中appid一项添加App ID即可，多个之间用|分割。

> 本次关于GoAgent翻墙的介绍就到此结束了，有不足之处还望指正，如果过程中有问题可以在下面留言讨论！

另外这有个叫[GoAgentX](https://github.com/ohdarling/GoAgentX)的东东，感兴趣的自己去折腾吧！

[More Tips About GoAgent](https://code.google.com/p/GoAgent/)

