---
layout: post
title: "Android模拟神器——Genymotion"
date: 2013-08-16 15:35
comments: true
categories: Android
---
> 纠结的时光总会过去，<br>
> 美好和光明就在前方！

![logo](/images/2013/08/genymotion/logo.png)

刚开始接触Android开发的同学不免都接触过Android自带的模拟器，启动慢、操作卡、没法用，基本属于摆设状态。这是大家对Android模拟器的普遍印象，时至今日，终于出现了一款神器来改变这一印象，那就是<a href = http://www.genymotion.com/ target = _blank >Genymotion</a>，Genymotion是一个基于虚拟机的Android模拟环境，包括了除电话和短信外大部分Android真机的功能，其流畅性和使用体验完全不亚于真机，是Android开发者、测试人员等非常有力的工具。它支持Window、MacOS、Linux，今天的话题就是Genymotion的特性和在Mac上的安装及使用。

<!--More-->

## 一、基本特性
- 支持OpenGL加速以提供良好的3D表现
- 能从Google Play下载和安装应用
- 提供电量控制、GPS和加速传感器控制模拟
- 和ADB完美结合，能像传统模拟器和真机一样通过命令行控制模拟器
- 提供丰富的自定义属性，包括屏幕分辨率、内存大小和CPU控制等
- 能在Eclipse上进行应用开发和调试
- 支持多模拟器运行

## 二、安装
- 1.Genymotion依赖于虚拟机VirtualBox，它是Oracle公司开发的一套虚拟机运行环境，和VMware类似。所以，安装之前我们先需要安装<a href = https://www.virtualbox.org/wiki/Downloads target = _blank >VirtualBox</a>。
- 2.安装完VirtualBox后就可以到<a href = https://cloud.genymotion.com/page/launchpad/download/ target = _blank >Genymotion下载</a>页下载安装包了（在此需要先注册Genymotion的使用账号）。下载完成后双击dmg文件并将Genymotion和Genymotion shell拖入Application文件夹中，至此，便完成了Genymotion的下载和安装。
- 3.到Application文件夹中找到Genymotion并双击运行，可以看到如下界面，从列表中选择一个准备安装的虚拟机点击Add(这一步需要登陆之前注册的账号)，然后便会下载该模拟器需要的安装文件和配置信息：

![1](/images/2013/08/genymotion/1.png)

下载完成后点击Next：

![3](/images/2013/08/genymotion/3.png)

- 4.下载完成后就可以看到我们选择的模拟器已经存在于我们的虚拟机列表中了，运行前，先要启动一下VirtualBox然后在点击窗口中的Play图标，后续使用时直接点击Play即可启动Android模拟器了。

运行VirtualBox：

![7](/images/2013/08/genymotion/7.png)

运行安装好的Android模拟器，点击右边的小显示器图标可以配置模拟器的显示分辨率：

![4](/images/2013/08/genymotion/4.png)

- 5.启动后会要求配置Android SDK的路径，选择并确定SDK的安装目录，然后点击OK，至此，Genymotion的下载和安装就完成了。

配置Android SDK路径：

![5](/images/2013/08/genymotion/5.png)

Android模拟器运行效果：

![6](/images/2013/08/genymotion/6.png)

## 支持
Genymotion支持Eclipse和IntelliJ插件，可以直接通过Eclipse进行项目开发和调试，同时，也可以通过ADB命令行对模拟器进行相应的操作。

Eclipse连接Genymotion模拟器：

![2](/images/2013/08/genymotion/2.png)

更多功能请参阅官方[User Guide](https://cloud.genymotion.com/page/doc/)

> 后记：Genymotion的出现可以说是一场革命，改变了开发者对Android模拟器以往糟糕表现的看法。Genymotion基于VirtualBox虚拟机搭建，所以如果本机配置够高的话，用Genymotion来取代真机进行测试和开发是完全可以的（大部分项目），另外，不足的是Genymotion目前支持的模拟器类型有限，相信后期会不断的新增和优化！

