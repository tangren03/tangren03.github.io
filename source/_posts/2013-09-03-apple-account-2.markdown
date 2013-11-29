---
layout: post
title: "苹果开发者账号那些事儿（二）"
date: 2013-09-03 21:24
comments: true
keywords: 苹果开发者账号,iOS
description: 
categories: iOS
---
> 这是一篇教程<br>
> 这里有手把手教学<br>


## 一、关于证书
苹果使用密文签名技术来验证App的合法性，不管是iOS应用还是Mac应用都需要相应的签名证书来作为测试或发布App用。这里主要谈谈iOS的证书，当然，Mac的证书也基本类似。

在开发iOS应用的时候，我们需要签名证书（```开发证书```）来验证，并允许我们在真机上对App进行测试。另外，在发布App到App store的时候，我们也需要证书(```发布证书```)来做验证。那么什么是签名证书，如何获取签名证书，下面听我慢慢道来。

<!--More-->

首先，证书（```Certificate```）是用来证明某一件事是否成立的，好比拿到的获奖证书，是证明参加比赛并获奖的凭证。类似，在iOS开发中，用证书来证明你是否具有某些权限或者能力来做某事。代码签名验证允许我们的操作系统来判断是谁对App进行了签名，在安装了Xcode后，Xcode会在项目编译期间使用你的代码签名验证，这个验证由一个由Apple认证过的公钥-私钥对组成，私钥存储在你的钥匙串中（Mac本地，在系统实用工具中），公钥包含在证书（Certificates）中，证书在本地钥匙串和开发者账号中都有存储，这种公钥-私钥验证授权的方式在很多地方都有使用到，比如Git中的SSH协议也是通过这种方式来确认访问权限。另外，还有一个我们可以叫做媒介证书的证书来确保我们的证书（Certificates）是经过授权而发布的。如下图所示：

![1](/images/2013/09/apple_account_2/1.png)

当安装好Xcode时，媒介证书（Intermediate Certificate）就已经安装到我们的钥匙串中去了。通过在开发者账号（Developer Account）和本地（Mac）都经过验证的证书（Certificate）我们就可以利用合法的证书进行App的测试和发布了。

## 二、请求证书
在为App签名前，我们需要向Apple请求签名证书，前提是你已经注册了开发者计划并付费。

1、打开Xcode并进入右上角Organizer窗口，选中顶部第一个名为Devices的Tab，如下图：

![2](/images/2013/09/apple_account_2/2.png)

2、点击菜单栏Editor并选择Refresh from Developer Portal

3、输入开发者账号用户名和密码并点击“Log in”，如下图：

![3](/images/2013/09/apple_account_2/3.png)

4、完成后点击“Submit Request”按钮，此时Xcode会向开发者后台请求相应的证书，证书包括开发证书（Development）和发布证书（Distribution）。窗口如下图所示：

![4](/images/2013/09/apple_account_2/4.png)

5、请求完毕后，Xcode会询问是否需要导出开发者证书，选择“Export”导出。前面的介绍中我们提到过，私钥（Private key）是存储在本地的，证书（Certificate）随着公钥（Public key）存储在开发者账号后台，公钥=私钥对完成对一个开发者和一台开发Mac设备的授权，所以，当我们创建证书时就需要马上备份我们的证书，当切换Mac进行作业时，我们只需要导入我们的私钥证书即可（公钥证书在本地和开发者中心都存储有）。

![5](/images/2013/09/apple_account_2/5.png)

6、导出过程中会要求你对导出的证书设置密码，下次导入此证书时需要输入该密码，所以需要记住此处设置的密码。导出的证书扩展名为.developerprofile，当下次切换Mac进行开发时，，导入该证书即可。

![6](/images/2013/09/apple_account_2/6.png)

导入.developerprofile证书：

![7](/images/2013/09/apple_account_2/7.png)

## 三、验证证书

1、在Xcode Organizer中左侧TEAMS选项卡中可以看到两个证书显示其中，一个是开发证书（Development），一个是发布证书（Distribution），如果开发者证书验证授权成功，则在证书上的小人头像会显示绿色小钩。

![8](/images/2013/09/apple_account_2/8.png)

2、当请求了开发者证书后，会自动在钥匙串中（系统实用工具-钥匙串访问）显示开发证书和发布证书。当选中一个证书时，顶部的说明信息包括了证书发行商和授权信息，同样如果看到绿色打钩说明证书已经安装成功。

![9](/images/2013/09/apple_account_2/9.png)

3、在开发者后台查看开发证书，登陆Developer后台以后进入Certificates选项卡，分别在Development和Distribution选项卡中查看开发证书和发布证书。此时，证书的信息应该和在Xcode中一致。

![10](/images/2013/09/apple_account_2/10.png)

## 四、回顾总结
在上面的讨论中，我们介绍了签名证书以及如何请求及验证证书。在iOS开发中，总的来说主要包括两个证书，一个是开发证书（Development certificates）用来验证哪些设备能用来测试App，在开发测试阶段使用这个证书。另一个是发布证书（Distribution certificates），用来验证是否能向App store提交App审核和发布。如果是公司团队账号，发布证书能在具有发布权限的团队成员间共享。以下是官方对证书类型和名字的一个列表统计，比较详细的例举了证书类型、名字以及简要描述。

![11](/images/2013/09/apple_account_2/11.png)

> 后记：本次关于苹果开发者账号证书相关的介绍就到此结束了，不足之处望大家指正和补充。下篇将主要介绍Provisioning Profile的二三事。欢迎继续关注。
