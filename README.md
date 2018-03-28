![logo](logo.png)
[![Build Status](http://img.shields.io/travis/pcjbird/QuickTraceiOSLogger/master.svg?style=flat)](https://travis-ci.org/pcjbird/QuickTraceiOSLogger)
[![Pod Version](http://img.shields.io/cocoapods/v/QuickTraceiOSLogger.svg?style=flat)](http://cocoadocs.org/docsets/QuickTraceiOSLogger/)
[![Pod Platform](http://img.shields.io/cocoapods/p/QuickTraceiOSLogger.svg?style=flat)](http://cocoadocs.org/docsets/QuickTraceiOSLogger/)
[![Pod License](http://img.shields.io/cocoapods/l/QuickTraceiOSLogger.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![CocoaPods](https://img.shields.io/cocoapods/at/QuickTraceiOSLogger.svg)](https://github.com/pcjbird/QuickTraceiOSLogger)
[![GitHub release](https://img.shields.io/github/release/pcjbird/QuickTraceiOSLogger.svg)](https://github.com/pcjbird/QuickTraceiOSLogger/releases)

# QuickTraceiOSLogger
### A real time iOS log trace tool, view iOS log with pc web browser under local area network, which will automatically scroll like xcode. 一个实时的iOS日志跟踪工具，在局域网中使用 PC Web 浏览器查看 iOS 日志，它将像xcode一样自动滚动。

## 特性 / Features

1. 一边操作一边查看输出日志，实时日志跟踪，无须手动刷新。
2. 适用所有浏览器，无需配备 Mac 电脑。
3. 无需数据线连接电脑。
4. 支持多台电脑同时监听日志，支持多种日志跟踪方式，例如 telnet 等。

## 演示 / Demo

<p align="center"><img src="demo.jpg" title="demo"></p>

##  安装 / Installation

方法一：`QuickTraceiOSLogger` is available through CocoaPods. To install it, simply add the following line to your Podfile:

```
pod 'QuickTraceiOSLogger'
```

## 使用 / Usage
  
  ```
      #import <QuickTraceiOSLogger/QuickTraceiOSLogger.h>
      
      - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
            // Override point for customization after application launch.
            [QuickiOSLogServer start];
            XLOG_INFO(@"您正在使用 iOS 远程日志查看服务！");
            return YES;
      }
  ```


## 关注我们 / Follow us
  
<a href="https://itunes.apple.com/cn/app/iclock-一款满足-挑剔-的翻页时钟与任务闹钟/id1128196970?pt=117947806&ct=com.github.pcjbird.QuickTraceiOSLogger&mt=8"><img src="https://github.com/pcjbird/AssetsExtractor/raw/master/iClock.gif" width="400" title="iClock - 一款满足“挑剔”的翻页时钟与任务闹钟"></a>    
  
[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/pcjbird/QuickTraceiOSLogger)
[![Twitter Follow](https://img.shields.io/twitter/follow/pcjbird.svg?style=social)](https://twitter.com/pcjbird)

