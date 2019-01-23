Pod::Spec.new do |s|
  s.name               = 'gxclient-ios'
  s.version            = '1.0.0'
  s.summary            = 'gxclient-ios is an implementation of GXChain protocol in Objective-C.'
    s.description  = <<-DESC
                   gxclient-ios is a toolkit to work with GXChain.
                   DESC
  s.homepage           = 'https://github.com/gxchain/gxclient-ios'
  s.license            = 'BSD'
  s.authors            = { 'lanhaoxiang' => 'lanhaoxiang@qq.com'}
  s.source             = { :git => 'https://github.com/gxchain/gxclient-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source_files = 'gxclient-ios/**/*.{h,m}'
  s.resource     = 'gxclient-ios/gxclient.bundle'
  s.public_header_files = 'gxclient-ios/**/*.h'
  s.exclude_files = ['gxclient-iosTests/**/*.{h,m}']
  s.requires_arc  = true
  s.framework    = 'Foundation'
  s.ios.framework = 'UIKit'
  s.osx.framework = 'AppKit'
  s.dependency 'OpenSSL-Universal'
  s.dependency 'AFNetworking'
end