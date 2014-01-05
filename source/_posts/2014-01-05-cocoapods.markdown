---
layout: post
title: "使用CocoaPods管理依赖库"
date: 2014-01-05 20:16:17 +0800
comments: true
categories: iOS
---
> 工欲善其事，必先利其器

![](/images/2014/01/cocoapods/1.png)

本篇内容将介绍Mac和iOS开发中必备的一个依赖库管理工具[CocoaPods](https://github.com/CocoaPods/CocoaPods)。

<!--More-->

## CocoaPods是什么
在iOS开发中势必会用到一些第三方依赖库，比如大家都熟悉的ASIHttpRequest、AFNetworking、JSONKit等。使用这些第三方类库能极大的方便项目的开发，但是，集成这些依赖库需要我们手动去配置，例如集成ASIHttpRequest库时除了加入源码以外还需要手动去添加一些系统的framework，CFNetwork、MobileCoreServices等，如果这些第三方库发生了更新，还需要手动去更新项目。这就显得非常麻烦。有麻烦自然有解决办法，CocoaPods就是为了解决这个问题而生的。通过CocoaPods，我们可以将第三方的依赖库统一管理起来，配置和更新只需要通过简单的几行命令即可完成，大大的提高了实际开发中的工作效率，使我们的主要精力集中到更重要的事情上去。

## 安装CocoaPods
我的环境为Mac OS X 10.9.1，安装CocoaPods之前，先确保本地有Ruby环境，因为CocoaPods运行于Ruby之上，默认情况下，Mac是自带了Ruby环境的，可以通过命令行```ruby -v```查看当前Ruby的版本，我用的是1.9.3p448。接下来我们就可以通过如下命令安装CocoaPods了。

```
$ sudo gem install cocoapods
```
输入上述命令后可能会无响应，那是因为你身在天朝，伟大的墙拦住了你的去路，不知为什么，cocoapods.org这种无害产物也要被墙。不过没关系，我们可以通过淘宝的Ruby镜像来访问Cocoapods，在终端输入如下命令将Ruby镜像替换为淘宝的。

```
$ gem sources --remove https://rubygems.org/
$ gem sources -a http://ruby.taobao.org/
```

完成后可以通过如下命令来查看当前的Ruby镜像是否已经指向了淘宝的。

```
$ gem sources -l
```

如果输出结果是如下这样，那说明这一步就成功了。

```
*** CURRENT SOURCES ***

http://ruby.taobao.org/
```

接下来就可以重新运行安装命令来安装CocoaPods了，根据你的网络情况，几秒或十几秒后安装过程就完成了，总的来说，安装过程还是比较简单的。如果其中你遇到了什么问题，请自行Google解决，都能找到你想要的答案。

## 使用CocoaPods
我们通过集成JSONKit类库来演示如何使用CocoaPods来做依赖库管理。首先，建立一个xcode工程，命名为CocoaPodsTest，现在的工程结构如下图所示。

![](/images/2014/01/cocoapods/2.png)

这里我们要集成JSONKit，可以先通过如下命令来判断其是否支持CocoaPods。

```
$ pod search JSONKit
```

执行后通过输出结果可以看到JSONKit是支持CocoaPods的，注意红框标记的内容，这是待会我们配置xcode时需要的信息，这条配置项就是告诉CocoaPods去下载和管理哪一个第三方库。

![](/images/2014/01/cocoapods/3.png)

检测完毕后我们来到工程CocoaPodsTest的目录下，新建一个名为Podfile的文件（这里通过命令行创建）

```
$ vim Podfile
```

这个Podfile文件的作用是配置依赖库信息，就是告诉CocoaPods去下载和管理哪些依赖库，文件创建好以后，打开文件并加入如下内容。（vim打开文件后按i进入插入模式，编辑完成后按esc退出编辑模式，接着输入:wq保存并退出文件）

![](/images/2014/01/cocoapods/4.png)

这时候，工程目录下就会有一个Podfile文件了，注意必须和.xcodeproj在同一个目录下。接下来就可以使用CocoaPods来安装并管理JSONKit库了，确保命令行当前路径是在CocoaPodsTest目录下，运行如下命令。

```
$ pod install
```

安装完成后会提示如下信息，并且我们的工程目录下会多出一个.xcworkspace结尾的文件，命令行信息绿色部分提醒我们“从此使用CocoaPodsTest.xcworkspace来打开项目”。

![](/images/2014/01/cocoapods/5.png)

通过CocoaPodsTest.xcworkspace来打开项目，这时，我们的项目工程结构就会变成下图这样，多出一个名为Pods的依赖工程，打开Pods文件夹后，发现JSONKit已经在里面了

![](/images/2014/01/cocoapods/6.png)

这时候就可以在项目文件中引入JSONKit.h了，这时候如果你发现import的时候没有提示JSONKit的文件，可以在target-Build Settings下修改“User Header Search Paths”项，新增${SRCROOT}并选择rcursive，如下图。

![](/images/2014/01/cocoapods/7.png)

设置完成后就可以在文件中直接引用第三方库的文件并使用了。

![](/images/2014/01/cocoapods/8.png)

到此，新建工程并使用CocoaPods来管理依赖库的过程就完成了，如果是直接使用已有CocoaPods的项目，则需要首先运行一下pod update命令来更新项，然后照样通过.xcworkspace来打开工程。

如果需要依赖多个第三方类库，只需要修改Podfile文件的配置，然后运行pod update命令即可，比如新增一个AFNetworking的依赖库，首先执行pod search AFNetworking查看一下AFNetworking的配置信息，修改Podfile文件，在后面增加AFNetworking的对应配置信息，然后运行pod update命令就完成了对AFNetworking的集成。

![](/images/2014/01/cocoapods/9.png)

添加AFNetworking库后的目录结构如下。

![](/images/2014/01/cocoapods/10.png)

如果类库有更新，查看更新配置并执行pod update即可简单完成了，从此从手动更新繁重的体力劳动中解脱出来。

简单小结一下：

- 安装CocoaPods
- 新建项目并在工程根目录下新建Podfile文件，配置需要管理的第三方库
- 运行pod install下载安装第三方库


###### 更多内容请参考[CocoaPods Guides](http://guides.cocoapods.org/)


