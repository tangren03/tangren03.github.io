---
layout: post
title: "苹果开发者账号那些事儿（三）"
date: 2013-11-28 19:52
comments: true
keywords: 
description: 苹果开发者账号,iOS
categories: iOS
---
> 这是一篇教程<br>
> 这里有手把手教学<br>

这是苹果开发者账号相关系列第三篇，本篇主要介绍Provisioning Profile，如果你还没有看过前两篇，可以先看看：

- <a href="http://ryantang.me/blog/2013/08/28/apple-account-1/" target="_blank">苹果开发者账号那些事儿（一）</a>
- <a href="http://ryantang.me/blog/2013/09/03/apple-account-2/" target="_blank">苹果开发者账号那些事儿（二）</a>

<!--More-->

## 什么是Provisioning Profile？

从字面翻译，Provisioning Profile就是配置文件的意思，它在开发者账号体系中所扮演的角色也是配置和验证的作用。如果你有开发者账号，可以打开你的开发者控制台，在首页可以看到如下界面。如果你没有开发者账号，那就看图片意会吧！：）

![0](/images/2013/11/apple_account_3/0.png)

现在开发者控制台相比之前在界面布局上已经进行了改版，更加直观，也更加美观。红框标记的地方我们可以看到Provisioning Profile文件夹图标，点击进去，就来到了所有证书和配置文件的管理控制中心。我们可以在最下方看到标记为Provisioning Profiles的区域，这里就是我们管理iOS或者Mac应用程序Provisioning Profile的地方啦。

![1](/images/2013/11/apple_account_3/1.png)

点击右上方的“+”号会提示我们新建什么类型的Provisioning Profile，可以看到，Provisioning Profile分为两大类，一类是Development，一类是Distribution，前者是创建我们在开发环境下的配置文件，不能进行发布，后者可以创建发布到App Store或者以Ad Hoc发布的配置文件。创建Development下得Provisioning Profile后，我们可以在真机上对App进行开发和调试。在Distribution下的Provisioning Profile，我们可以选择创建发布到应用商店的配置文件，另外就是Ad Hoc方式下的配置文件。Ad Hoc是指在不发布到App Store的情况下，可以将发布状态下的App装在指定的一些真机上进行测试，但是这里指定的设备数量是有限的（99台）。

到这里，我们已经知道Provisioning Profile有两类，一类是开发状态下的，一类是发布状态下得。那Provisioning Profile里面究竟有些什么东西呢，我们接着往下看。

![1](/images/2013/11/apple_account_3/2.png)

我们选择创建一个Development状态下的Provisioning Profile，首先需要我们填写App ID，我们知道，每一个应用都有唯一的App ID，这个ID就好比我们应用程序的身份证，通过下图可以看到关于App ID的构成。

![1](/images/2013/11/apple_account_3/3.png)

现在，App ID由一个Apple产生的Team ID作为前缀，后面跟的其实就是我们在Xcode中设置的Bundle ID，其实就相当于包名（Android里面也是利用应用包名来唯一标记App）。通过这种方式，我们就将一个指定的App与一个Provisioning Profile进行绑定了，也就是说这个Provisioning Profile只能作为这一个App的开发配置文件。那我们每一次开发新应用的时候就得重新来新建Provisioning Profile，这显得非常麻烦，好在Apple已经为我们想到了这一点，我们可以通过通配符来标记App ID，这样我们可以只创建一个开发配置文件就可以来测试所有我们开发的App了，下图是使用通配符标记的App ID格式。

![1](/images/2013/11/apple_account_3/4.png)

关于App ID的创建，可以到证书配置管理控制台Identifiers模块下App IDs栏目下进行创建，这里就不再详细赘述了。App ID选好了，我们继续下面的步骤。这时，提示会要求我们选择Certificates。

![1](/images/2013/11/apple_account_3/5.png)

那什么是Certificates呢？你可以在<a href="http://ryantang.me/blog/2013/09/03/apple-account-2/" target="_blank">苹果开发者账号那些事儿（二）</a>中得到详细的答案。如果你现在不想看，那简单的说，Certificates就是一个来验证你是合法开发者的证书文件，这里通常是对你进行开发的Mac进行授权。我们可以选择一个经过验证的Certificate来配置这个Provisioning Profile。选择完毕后我们就可以进行下一步了。这时，提示会要求我们选择Device。

![1](/images/2013/11/apple_account_3/6.png)

选择Device也就是说我们希望这个Provisioning Profile对哪些设备进行授权，只有选中的设备，才能使用这个配置文件来进行真机调试，否则，装了也没有，因为别人压根没对你授权。设备选择完毕后，我们继续下面的步骤，这时，提示就会要求我们输入这个Provisioning Profile的名字了。

![1](/images/2013/11/apple_account_3/7.png)

在统计信息中我们可以看到，Provisioning Profile的类型为Development类型，选择了一个指定的App ID，指定了一个Certificates，另外指定了一台设备，这样，我们的Provisioning Profile就配置完成了。这时到配置文件列表我们可以看到刚刚生成的这个配置文件，显示为Active已激活，另外要说的是，每一个Provisioning Profile都有一个有效期，通常是一年，过期后就得重新验证一下，不需要重新生成，只需手动验证一下即可，点击查看详情。

![1](/images/2013/11/apple_account_3/8.png)

这里，我们可以看到比之前的详情更丰富的信息，其中Enabled Service中例举的信息是在配置App ID的时候选择的，作用是为这个配置文件申请诸如消息推送和应用内购买的权限。另外，Expires指明了这个配置文件的过期时间，最后Status就显示状态为Activie，如果不可用的话会显示Invalid。如果发现配置文件过期，就像之前说的，手动验证一下即可。最后，可以将Provisioning Profile下载到本地，下载完成后，我们就可以看到一个扩展名为.mobileprovision的文件，打开Xcode，连上设配，双击这个配置文件，这个配置文件就被安装到我们的测试设备中了，通过Xcode的Device窗口可以查看这台测试设备所有的Provisioning Profile。到这里，我们已经知道了Provisioning Profile是用来做验证授权的，也知道了它其实是装在我们的测试设备上的，当然，你也知道了如何去创建它。那么，接下来我们就来看看Provisioning Profile的内部结构图。

![1](/images/2013/11/apple_account_3/9.png)

这里，拿Ad Hoc方式的配置文件来举例，按照之前说的，Ad Hoc能够在不发布到App Store的前提下允许指定的设备安装App，那这个配置文件中肯定就包含Devices信息，同时也包含App ID，另外还包含一个发布状态下的Certificate。到这里，或许你会有疑问，正式发布状态下的配置文件应该是怎样的，首先要说的是，正式发布App时，Provisioning Profile是不需要提前安装到用户手机上的，如果这样的话，那估计Apple就傻了。在正式发布到Apple Store时，发布状态的Provisioning Profile已经以签名的方式和App进行了绑定，有一点不同的是，发布状态的Provisioning Profile不需要指定Device，因为它不知道将被哪些设备使用，下图是发布状态下的配置文件结构。

![1](/images/2013/11/apple_account_3/10.png)

最后，如果是Company类型的开发者账号，可以生成一个供团队使用的Team Provisioning Profile，通过这个配置文件，团队内成员可以共用一个配置文件来进行开发调试，当然，App ID得指定成通配类型的。

![1](/images/2013/11/apple_account_3/11.png)

这里需要注意的是，每一个苹果开发者账号只有一个Agent权限，就就是说，最终真正有权限发布到App Store的人就是这个开发者账号的拥有者，他的身份类型就是Agent，另外还有两种身份类型，一种是Admin，一种是Member，关于更多团队账号角色的信息，你可以参考<a href="https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/ManagingYourTeam/ManagingYourTeam.html#//apple_ref/doc/uid/TP40012582-CH16-SW1" target="_blank">这里</a>。

## 总结
通过上面的内容，你是否已经能够回答最开始提出的问题呢？什么是Provisioning Profile？这里做一个简单的总结：

- Provisioning Profile是一个安装在测试设备上的配置文件，文件扩展名为.mobileprovision
- Provisioning Profile有两种类型，一种是Development、一种是Distribution，分别对应开发状态和发布状态的配置文件
- 配置Provisioning Profile之前需要先设置好Certificates、App ID、Devices等信息
- Provisioning Profile的有效期为12个月，过期后得手动验证方可继续使用

内容就到这里了，要想理解的更透彻，还是实际去操作和实验来的快。如果你是Xcode5了，进到Preferences里面，选择Accounts选项卡，将你的Apple ID添加到Xcode里面，然后到工程General和Build Settings里面去折腾吧。后面的事，你就自己琢磨吧！：）

![1](/images/2013/11/apple_account_3/13.png)

![1](/images/2013/11/apple_account_3/14.png)

> 本期内容就到这里了，有不足之处，欢迎指正，如果你希望经常收到一些有趣的内容，欢迎微信扫描网页右边的二维码关注我的微信公众账号“Android及iOS开发汇总”。


Reference From [Apple Developer Center](https://developer.apple.com/library/mac/documentation/IDEs/Conceptual/AppDistributionGuide/Introduction/Introduction.html)

