# iOS仿抖音app 

抖音demo适配了iphone、ipad，同时兼容iOS8.0至iOS12.0系统。当前抖音demo使用Object-C语言编写，Swift版本请点击[这里](https://github.com/sshiqiao/douyin-ios-swift)。

## 结构

本项目共分为三个部分。第一部分为抖音个人主页实现，包含NSOperationQueue多队列解析webp动图、网络资源二级缓存框架搭建。第二部分围绕AVPlayerLayer展开，涉及网络视频边播放边下载、UITableView控制多个视频源播放。第三部分则为WebSocket实现IM即时聊天，其中穿插文本计算、表情编辑等功能。三个部分都涉及网络请求、json数据模型转换以及手势、动画效果处理。

## 展示图

![image](https://github.com/sshiqiao/douyin-ios-objectc/blob/master/screenshot/demo1.gif)
![image](https://sshiqiao.github.io/assets/demo2.gif)
![image](https://sshiqiao.github.io/assets/demo3.gif)
![image](https://sshiqiao.github.io/assets/demo5.gif)

抖音demo使用说明文档地址请点击[这里](https://sshiqiao.github.io/document/douyin-objectc.html)，文档结构如下所示：

## 目录

[iOS仿抖音app介绍](https://sshiqiao.github.io/document/douyin-objectc.html#1)
- [x] [1.1 引言](https://sshiqiao.github.io/document/douyin-objectc.html#1.1)
- [x] [1.2 展示图](https://sshiqiao.github.io/document/douyin-objectc.html#1.2)
- [x] [1.3 结构总览](https://sshiqiao.github.io/document/douyin-objectc.html#1.3)
- [x] [1.4 iTunes资源获取](https://sshiqiao.github.io/document/douyin-objectc.html#1.4)
- [x] [1.5 Charles数据采集](https://sshiqiao.github.io/document/douyin-objectc.html#1.5)
- [x] [1.6 网络请求API接口](https://sshiqiao.github.io/document/douyin-objectc.html#1.6)
- [x] [1.7 第三方库使用](https://sshiqiao.github.io/document/douyin-objectc.html#1.7)

[抖音个人主页](https://sshiqiao.github.io/document/douyin-objectc.html#2)
- [x] [2.1 布局、接口分析](https://sshiqiao.github.io/document/douyin-objectc.html#2.1)
- [x] [2.2 UICollectionView指定元素固定原理](https://sshiqiao.github.io/document/douyin-objectc.html#2.2)
- [x] [2.3 UICollectionView指定元素下拉缩放原理](https://sshiqiao.github.io/document/douyin-objectc.html#2.3)
- [x] [2.4 谷歌libwebp库解析webp图片](https://sshiqiao.github.io/document/douyin-objectc.html#2.4)
- [x] [2.5 网络资源二级缓存](https://sshiqiao.github.io/document/douyin-objectc.html#2.5)

[抖音短视频列表](https://sshiqiao.github.io/document/douyin-objectc.html#3)
- [x] [3.1 布局、接口分析](https://sshiqiao.github.io/document/douyin-objectc.html#3.1)
- [x] [3.2 AVPlayerLayer实现网络视频边下载边播放](https://sshiqiao.github.io/document/douyin-objectc.html#3.2)
- [x] [3.3 UITableView实现视频源自动播放](https://sshiqiao.github.io/document/douyin-objectc.html#3.3)
- [x] [3.4 悬浮于软键盘之上的UITextView](https://sshiqiao.github.io/document/douyin-objectc.html#3.4)
- [x] [3.5 控件手势冲突处理](https://sshiqiao.github.io/document/douyin-objectc.html#3.5)

[IM即时聊天](https://sshiqiao.github.io/document/douyin-objectc.html#4)
- [x] [4.1 布局、接口分析](https://sshiqiao.github.io/document/douyin-objectc.html#4.1)
- [x] [4.2 Websocket实现即时聊天](https://sshiqiao.github.io/document/douyin-objectc.html#4.2)
- [x] [4.3 文本长宽计算汇总](https://sshiqiao.github.io/document/douyin-objectc.html#4.3)
- [x] [4.4 表情编辑功能实现](https://sshiqiao.github.io/document/douyin-objectc.html#4.4)

## 作者

Qiao Shi, [sqshiqiao@gmail.com](sqshiqiao@gmail.com)  
