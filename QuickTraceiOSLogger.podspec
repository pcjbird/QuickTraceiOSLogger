Pod::Spec.new do |s|
    s.name             = "QuickTraceiOSLogger"
    s.version          = "2.0.8"
    s.summary          = "A real time iOS log trace tool, view iOS log with pc web browser under local area network, which will automatically scroll like xcode. 一个实时的iOS日志跟踪工具，在局域网中使用 PC Web 浏览器查看 iOS 日志，它将像xcode一样自动滚动。"
    s.description      = <<-DESC
    A real time iOS log trace tool, view iOS log with pc web browser under local area network, which will automatically scroll like xcode. 一个实时的iOS日志跟踪工具，在局域网中使用 PC Web 浏览器查看 iOS 日志，它将像xcode一样自动滚动。
    在测试 iOS App 过程中，有很多时候我们需要一边操作一边查看输出日志。对于有 MAC 机的来说，当然在 XCode 下自己打包测试查看日志那是非常方便的，但是大部分的测试是没有 MAC 机的。 虽然开发也有将日志写入文件，但是每次操作完了再去打开文件查看，非常不方便。
    那有没有一种类似xcode输出日志的方式呢？
    答案就是今天要说的这个： 直接用浏览器实时查看输出的log信息。
    DESC
    s.homepage         = "https://github.com/pcjbird/QuickTraceiOSLogger"
    s.license          = 'MIT'
    s.author           = {"pcjbird" => "pcjbird@hotmail.com"}
    s.source           = {:git => "https://github.com/pcjbird/QuickTraceiOSLogger.git", :tag => s.version.to_s}
    s.social_media_url = 'https://www.lessney.com'
    s.requires_arc     = true
    s.documentation_url = 'https://github.com/pcjbird/QuickTraceiOSLogger/blob/master/README.md'
    s.screenshot       = 'https://github.com/pcjbird/QuickTraceiOSLogger/blob/master/logo.png'

    s.platform         = :ios, '9.0'
    s.frameworks       = 'Foundation', 'UIKit'
#s.preserve_paths   = ''
    s.source_files     = 'QuickTraceiOSLogger/*.{h,m}'
    s.public_header_files = 'QuickTraceiOSLogger/QuickTraceiOSLogger.h', 'QuickTraceiOSLogger/QuickiOSLogServer.h', 'QuickTraceiOSLogger/QuickiOSHttpServerLogger.h'

    s.dependency 'XLFacility.optimize'
    s.dependency 'YYWebImage'

    s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }


end
